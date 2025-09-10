# Whole-genome assembly of the Frog-eating ratsnake (*Oocatochus rufodorsatus*)
*Oocatochus rufodorsatus* PacBio HiFi genome assembly. Workflow adapted from: https://github.com/danielagarciacobos4/PacBio_GenomeAssembly_annotation

1. __Basic structure of a SLURM job script__
2. __*k*-mer analysis of raw reads using jellyfish__
3. __Genome assembly using hifiasm__
4. __BUSCO__
5. __Genome stats with QUAST__

## 1) Basic structure of a SLURM job script
A typical SLURM job script has a structure similar to this:

```
#!/bin/sh
#SBATCH --job-name your_job_name
#SBATCH --nodes=1
#SBATCH --mem=60gb
#SBATCH --cpus-per-task=30
#SBATCH --time=50:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your_email@address.com
#SBATCH --output=output_name-%j-%x.out
#SBATCH --error=errfile_name-%j-%x.err

source ~/.bash_profile
conda activate my_conda_env

package_name parameters .....
```

- __#!/bin/sh:__ The shebang line. This specific syntax (#!/bin/sh) runs the script with the default shell. If #!/bin/bash is used, the script is run with bash shell
- __#SBATCH:__ These lines are for the SLURM job scheduler
- __--job-name:__ Pretty self-explanatory - specifies your job name
- __--nodes=n:__ Run a job on n number of compute nodes
- __--mem=ngb:__ Allocate n gigabytes of RAM to each node requested
- __--cpus-per-task=n:__ Run task with n threads
- __--time=nn:nn:nn:__ Maximum runtime for a job is allowed to run
- __--mail-type=ALL:__ Sends email for all job-related events, such as job start, failure, completion, etc.
- __--mail-user=your_email@address.com:__ An email address to which all job-related notifications will be directed to
- __--output=output_name-%j-%x.out:__ "output_name" is a prefix for your output file, "%j" is the job ID assigned by SLURM, "%x" is the job name you specified with "--job-name", and ".out" is file extension 
- __--error=errfile_name-%j-%x.err:__ Outputs an error file
- __source ~/.bash_profile:__ Reload the shell's environment settings
- __conda activate my_conda_env:__ Activates the conda environment for your assembly project, for example to access specific packages not already available in the cluster as a module. In the jellyfish and hifiasm job scripts below, I activate a conda environment called "mytools", which contains both jellyfish and hifiasm. I created this environment because jellyfish and hifiasm were not available as modules on Mendel HPC

Create and activate new conda environment like so:
```
conda create -n new_conda_env
conda activate new_conda_env
```


## 2) *k*-mer analysis of raw reads using jellyfish
Use the following script to submit a jellyfish job to Mendel

```
#!/bin/sh
#SBATCH --job-name yshin_kmer_oocatochus
#SBATCH --nodes=1
#SBATCH --mem=60gb
#SBATCH --cpus-per-task=30
#SBATCH --time=50:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yshin@amnh.org
#SBATCH --output=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/jellyfish_outfiles/jellyfish-%j-%x.out
#SBATCH --error=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/jellyfish_errfiles/jellyfish-%j-%x.err

source ~/.bash_profile
conda activate mytools

jellyfish count -m 21 -s 1G -o /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/jellyfish_outfiles/Oocatochus_rufodorsatus_kmer.jf \ <(zcat /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/24ORCC001.hifireads.fastq.gz)
jellyfish histo /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/jellyfish_outfiles/Oocatochus_rufodorsatus_kmer.jf -t 38 > /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/jellyfish_outfiles/Oocatochus_rufodorsatus_kmer.histo
```

### Breakdown of the input parameters:
- jellyfish count: Tells jellyfish to start *k*-mer counting
- -m 21: Specifies *k*-mer length of 21 nucleotides. Every substring of length 21 is counted
- -s 1G: Determines memory allocation. 1G is usually appropriate for vertebrate genomes
- -o Oocatochus_rufodorsatus_kmer.jf: Output file prefix in jellyfish binary format
- <(zcat /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/24ORCC001.hifireads.fastq.gz): jellyfish cannot handle gzipped files directly. zcat decompresses the gzipped FASTQ file without creating a new file on the disk ("<(...)" acts as a temporary file)

## 3) Genome assembly with hifiasm
Use the following script to submit a hifiasm job to Mendel

```
#!/bin/sh
#SBATCH --job-name yshin_hifiasm_oocatochus
#SBATCH --nodes=1
#SBATCH --mem=60gb
#SBATCH --cpus-per-task=30
#SBATCH --time=40:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yshin@amnh.org
#SBATCH --output=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/hifiasm_outfiles/assembly-%j-%x.out
#SBATCH --error=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/hifiasm_errfiles/assembly-%j-%x.err

#conda init

source ~/.bash_profile
conda activate mytools

hifiasm -o /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/hifiasm_outfiles/Oocatochus_rufodorsatus_v1.asm -t 30 /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/24ORCC001.hifireads.fastq.gz
```

## 4) BUSCO analysis of the assembled genome
After running hifiasm, you will get a whole bunch of output files. We need a FASTA file of the assembled contigs. But hifiasm will only output .gfa files. So you need to convert .gfa file to .fa file using the line below (obviously use your own file names and paths)

```
awk '/^S/{print ">"$2"\n"$3}' assembly.gfa > assembly.fa
```

Then, run BUSCO with:

```
#!/bin/sh
#SBATCH --job-name yshin_oocatochus_busco
#SBATCH --nodes=10
#SBATCH --mem=100gb
#SBATCH --time=100:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yshin@amnh.org
#SBATCH --output=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/busco_outfiles/busco-%j-%x.out
#SBATCH --error=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/busco_errfiles/busco-%j-%x.err

# conda init

source ~/.bash_profile
conda activate mytools

Oocatochus_assembly="/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/hifiasm_outfiles/Oocatochus_rufodorsatus_v1.asm.bp.p_ctg.fa"
busco -m genome -i $Oocatochus_assembly -o /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/busco_outfiles/Oocatochus_BUSCO -l /home/yshin/mendel-nas1/snake_genome_ass/busco/sauropsida_odb10 -f --metaeuk --offline --download_path /home/yshin/mendel-nas1/snake_genome_ass/busco
```
__*NOTE:*__ If you intend to run BUSCO in offline mode, make sure to download the BUSCO sauropsida dataset before running the analysis. The dataset will be downloaded as a compressed file. Unpack this file in whatever directory you want to use, and *make sure* to specify the path to unpacked BUSCO file under the -l parameter. Otherwise the analysis will crash.  

## 5) Genome stats with QUAST
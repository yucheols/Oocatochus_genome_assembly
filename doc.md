# Whole-genome assembly of the Frog-eating ratsnake (*Oocatochus rufodorsatus*)
*Oocatochus rufodorsatus* PacBio HiFi genome assembly. Workflow adapted from: https://github.com/danielagarciacobos4/PacBio_GenomeAssembly_annotation

1. *k*-mer analysis of raw reads using jellyfish
2. Genome assembly using hifiasm
3. BUSCO

## Basic structure of a job script
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

package_name parameters .....
```

- #!/bin/sh: The shebang line. This specific syntax (#!/bin/sh) runs the script with the default shell. If #!/bin/bash is used, the script is run with bash shell
- #SBATCH: These lines are for the SLURM job scheduler
- --job-name: Pretty self-explanatory - specifies your job name
- --nodes=n: Run a job on n number of compute nodes
- --mem=ngb: Allocate n gigabytes of RAM to each node requested
- --cpus-per-task=n: Run task with n threads
- --time=nn:nn:nn: Maximum runtime for a job is allowed to run
- --mail-type=ALL: Sends email for all job-related events, such as job start, failure, completion, etc.
- --mail-user=your_email@address.com: An email address to which all job-related notifications will be directed to
- --output=output_name-%j-%x.out: "output_name" is a prefix for your output file, "%j" is the job ID assigned by SLURM, "%x" is the job name you specified with "--job-name", and ".out" is file extension 

## A) *k*-mer analysis of raw reads using jellyfish
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
#SBATCH --output=jellyfish-%j-%x.out

source ~/.bash_profile
conda activate mytools

jellyfish count -m 21 -s 1G -o Oocatochus_rufodorsatus_kmer.jf \ <(zcat /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/24ORCC001.hifireads.fastq.gz)
jellyfish histo Oocatochus_rufodorsatus_kmer.jf -t 38 > Oocatochus_rufodorsatus_kmer.histo
```

### Breakdown of the input parameters:
- jellyfish count: Tells jellyfish to start *k*-mer counting
- -m 21: Specifies *k*-mer length of 21 nucleotides. Every substring of length 21 is counted
- -s 1G: Determines memory allocation. 1G is usually appropriate for vertebrate genomes
- -o Oocatochus_rufodorsatus_kmer.jf: Output file prefix in jellyfish binary format
- <(zcat /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/24ORCC001.hifireads.fastq.gz): jellyfish cannot handle gzipped files directly. zcat decompresses the gzipped FASTQ file without creating a new file on the disk ("<(...)" acts as a temporary file)

## B) Genome assembly with hifiasm
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
#SBATCH --output=assembly-%j-%x.out

#conda init

source ~/.bash_profile
conda activate mytools

hifiasm -o Oocatochus_rufodorsatus_v1.asm -t 30 /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/24ORCC001.hifireads.fastq.gz
```

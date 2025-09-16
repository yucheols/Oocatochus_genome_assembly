# Whole-genome assembly of the Frog-eating ratsnake (*Oocatochus rufodorsatus*)
*Oocatochus rufodorsatus* PacBio HiFi genome assembly. Workflow adapted from: https://github.com/danielagarciacobos4/PacBio_GenomeAssembly_annotation and https://github.com/amandamarkee/actias-luna-genome

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
- __*NOTE:*__ In order for jellyfish to run, you need to explicitly tell SLURM to use bash (#!/bin/bash) rather than your default shell (#!/bin/sh)

```
#!/bin/bash  
# the above shebang line explicitly tells SLURM to use bash
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

### Visualizing jellyfish histogram in R 

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
#SBATCH --nodes=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=100gb
#SBATCH --time=100:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yshin@amnh.org
#SBATCH --output=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/busco_outfiles/busco-%j-%x.out
#SBATCH --error=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/busco_errfiles/busco-%j-%x.err

# conda init

source ~/.bash_profile
conda activate mytools

cd /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/busco_outfiles/

Oocatochus_assembly="/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/hifiasm_outfiles/Oocatochus_rufodorsatus_v1.asm.bp.p_ctg.fa"
busco -m genome -i $Oocatochus_assembly -o Oocatochus_BUSCO -l /home/yshin/mendel-nas1/snake_genome_ass/busco/sauropsida_odb10 -f --metaeuk --offline --download_path /home/yshin/mendel-nas1/snake_genome_ass/busco
```
__*NOTE:*__ If you intend to run BUSCO in offline mode, make sure to download the BUSCO sauropsida dataset before running the analysis. The dataset will be downloaded as a compressed file. Unpack this file in whatever directory you want to use, and *make sure* to specify the path to unpacked BUSCO file under the -l parameter. Otherwise the analysis will crash.  

### Visualizing BUSCO results in R
Use the script below to visualize BUSCO results, using the *cogeqc* R package.

```
#####  visualize BUSCO results in R

# clean working environment
rm(list = ls(all.names = T))
gc()

# load packages
library(cogeqc)

### load BUSCO results
# read as lines
busco <- cogeqc::read_busco('Rdata/busco/')
print(busco)

# plot
plot_busco(busco)
```
This will give you a plot that looks like this:

![Rplot1](/R/Rplots/busco_plot.png)



## 5) Genome stats with QUAST
Run the script below on Mendel to get reference-free stats for your genome assembly (e.g., N50, L50, # of contigs, etc.)
QUAST has several different parameters. For example:
 - -o: output directory
 - -r: path to a reference genome

At this time, we are only interested in getting the reference-free stats. So we do not need to flag the -r parameter.

```
#!/bin/sh
#SBATCH --job-name yshin_O_rufo_quast
#SBATCH --nodes=1
#SBATCH --mem=60gb
#SBATCH --cpus-per-task=30
#SBATCH --time=40:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yshin@amnh.org
#SBATCH --output=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/quast_outfiles/quast_assembly-%j-%x.out
#SBATCH --error=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/quast_errfiles/quast_assembly-%j-%x.err

#conda init

source ~/.bash_profile
conda activate quast

quast.py /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/hifiasm_outfiles/Oocatochus_rufodorsatus_v1.asm.bp.p_ctg.fa -o /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/quast_outfiles
```

The above script should run smoothly. Now, move the QUAST output files from Mendel to your local device for easier viewing and data visualization. Since these files are inside a directory and we want to move the whole directory, the regular scp does not work here. Instead, use scp -r

```
scp -r yshin@mendel.sdmz.amnh.org:/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/quast_outfiles ./outfiles
```
The below explanations were given by __*the one and only*  Dr. Amanda Markee__ regarding the concepts of L50 and N50 (https://github.com/amandamarkee) 
- __L50:__ N of puzzle pieces to reach 50% of your estimated genome size (lower L50 = less pieces = more contiguous = better assembly)
- __N50:__ N of base pairs to reach 50% of your estimated genome size (higher N50 = more base pairs = longer squences = better assembly)

### Visualizing QUAST results in R
We can visualize QUAST result using R. This is not necessary but I thought it would be a fun practice.

For example, in R, we can plot N50 and N75 using ggplot2
```
#####  visualize QUAST reference-free results in R

# clean working environment
rm(list = ls(all.names = T))
gc()

# load packages
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(forcats)

###  load the QUAST result report .tsv file
quast_out <- read_tsv('//wsl.localhost/Ubuntu/home/yshin/Oocatochus_genome_assembly/outfiles/quast_outfiles/report.tsv', show_col_types = F)
quast_out <- quast_out %>% rename(metric = Assembly, 
                                  value = Oocatochus_rufodorsatus_v1.asm.bp.p_ctg)

print(quast_out)

###  keep metrics of interest
key_metrics <- quast_out %>%
  filter(metric %in% c('Total length', '# contigs', 'Largest contig', 'GC (%)', 'N50', 'N75', 'L50', 'L75'))

print(key_metrics)

###  plot N50 and N75 // N50 is given in bp == use mutate() and divide up the raw value of N50 by 1e6 (10^6) to convert the value to Mb 
quast_out %>%
  filter(metric %in% c('N50', 'N75')) %>%
  mutate(value_mb = value / 1e6,
         metric = fct_relevel(metric, 'N50', 'N75')) %>%
  ggplot(aes(x = metric, y = value_mb, fill = metric)) +
  geom_col(width = 0.6, color = 'black', size = 1.0) +
  xlab('Metric') + ylab('Value (Mb)') +
  theme_classic() +
  theme(legend.position = 'none',
        panel.border = element_rect(fill = NA),
        panel.grid.major = element_line(),
        axis.text = element_text(size = 16),
        axis.title = element_text(size = 19),
        axis.title.x = element_text(margin = margin(t = 20)),
        axis.title.y = element_text(margin = margin(r = 20)))

```
This will produce a plot that looks like:
![Rplot2](/R/Rplots/Fig_N50_N70.png)
# Whole-genome assembly of the Frog-eating ratsnake (*Oocatochus rufodorsatus*)
*Oocatochus rufodorsatus* PacBio HiFi genome assembly. Workflow adapted from: https://github.com/danielagarciacobos4/PacBio_GenomeAssembly_annotation

1. *k*-mer analysis of raw reads using jellyfish
2. Genome assembly using hifiasm
3. BUSCO

## *k*-mer analysis of raw reads using jellyfish
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

## Genome assembly with hifiasm
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

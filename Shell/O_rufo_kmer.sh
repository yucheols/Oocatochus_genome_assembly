#!/bin/bash  
# the above shebang line explicitly tells SLURM to use bash
#SBATCH --job-name=yshin_kmer_oocatochus
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

# create a temp directory
TMPDIR=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/tmp_$SLURM_JOB_ID
mkdir -p $TMPDIR

# decompress in tempdir
zcat /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/24ORCC001.hifireads.fastq.gz > $TMPDIR/24ORCC001.hifireads.fastq

# run jellyfish
jellyfish count -m 21 -s 1G -o /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/jellyfish_outfiles/Oocatochus_rufodorsatus_kmer.jf $TMPDIR/24ORCC001.hifireads.fastq
jellyfish histo -t 30 /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/jellyfish_outfiles/Oocatochus_rufodorsatus_kmer.jf > /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/jellyfish_outfiles/Oocatochus_rufodorsatus_kmer.histo

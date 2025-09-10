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

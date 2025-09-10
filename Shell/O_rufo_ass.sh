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
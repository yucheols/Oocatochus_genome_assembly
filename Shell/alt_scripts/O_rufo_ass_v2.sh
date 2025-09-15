#!/bin/sh
#SBATCH --job-name yshin_hifiasm_oocatochus
#SBATCH --nodes=1
#SBATCH --mem=60gb
#SBATCH --cpus-per-task=30
#SBATCH --time=40:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yshin@amnh.org
#SBATCH --output=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/CHANGE_DIR/assembly-%j-%x.out
#SBATCH --error=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/CHANGE_DIR/assembly-%j-%x.err

#conda init

# hifiasm with extended options to output alternate assembly (so you get primary and alternate assemblies, rather than one primary, hap1, and hap2)
# MAKE SURE TO CREATE A NEW, DEISGNATED OUTPUT FOLDER BEFORE RUNNING THIS SCRIPT !!!!!!!!!!!
# PUT EVERYTHING ASSOCIATED WITH THIS RUN TO A NEW FOLDER !!!!!!!

source ~/.bash_profile
conda activate mytools

hifiasm -o /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/hifiasm_outfiles/Oocatochus_rufodorsatus_v2.asm --primary -t 30 /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/24ORCC001.hifireads.fastq.gz
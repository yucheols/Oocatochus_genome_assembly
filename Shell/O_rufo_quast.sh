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


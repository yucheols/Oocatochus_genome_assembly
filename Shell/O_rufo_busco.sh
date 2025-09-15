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

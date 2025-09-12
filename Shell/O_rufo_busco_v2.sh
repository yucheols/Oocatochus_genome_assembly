#!/bin/sh
#SBATCH --job-name yshin_oocatochus_busco_v2
#SBATCH --nodes=1
#SBATCH --mem=40gb
#SBATCH --time=144:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yshin@amnh.org
#SBATCH --output=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/busco_v2/busco_outfiles_v2/busco-%j-%x.out
#SBATCH --error=/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/busco_v2/busco_errfiles_v2/busco-%j-%x.err

source ~/.bash_profile
conda activate mytools

Oocatochus_assembly="/home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/hifiasm_outfiles/Oocatochus_rufodorsatus_v1.asm.bp.p_ctg.fa"
busco -m genome -i $Oocatochus_assembly -o /home/yshin/mendel-nas1/snake_genome_ass/Oocatochus/Shell/busco_v2/busco_outfiles_v2/Oocatochus_BUSCO -l /home/yshin/mendel-nas1/snake_genome_ass/busco/sauropsida_odb10 -f --metaeuk --offline --download_path /home/yshin/mendel-nas1/snake_genome_ass/busco

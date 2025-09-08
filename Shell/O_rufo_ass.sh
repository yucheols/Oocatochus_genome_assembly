#!/bin/bash
#SBATCH --job-name yshin_hifiasm_20250908
#SBATCH --nodes=1
#SBATCH --mem=50gb
#SBATCH --tasks-per-node=1
#SBATCH --time=30:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yshin@amnh.org
#SBATCH --output=slurm-%j-%x.out
#conda init
source ~/.bash_profile
conda activate
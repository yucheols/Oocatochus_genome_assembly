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
  mutate()
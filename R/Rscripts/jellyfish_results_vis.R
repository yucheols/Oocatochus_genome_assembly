#####  visualize jellyfish histogram in R

# clean working environment
rm(list = ls(all.names = T))
gc()

# load packages
library(ggplot2)

# load histogram file
jf_hist <- read.table('Rdata/jellyfish/Oocatochus_rufodorsatus_kmer.histo')
head(jf_hist)

# fix column names
colnames(jf_hist) = c('Coverage', 'Frequency')
head(jf_hist)

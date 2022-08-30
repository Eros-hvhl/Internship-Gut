# make tax metadata table of sample

# usage: Rscript tax_meta <input.metadata> <output.txt>

args = commandArgs(trailingOnly=TRUE)
metadata <- read.table(args[1], sep = '\t')
c.metadata <- cbind(substring(metadata[['V1']],2),
                    substring(metadata[['V2']],2))
colnames(c.metadata)<- c('taxon', 'class')
samplename<-gsub('fna/([A-Za-z0-9]+)_meta.txt','\\1', args[1])
sample <- rep(samplename,nrow(c.metadata))
c.metadata<-cbind(sample,c.metadata)
write.table(c.metadata, args[2], sep = '\t')
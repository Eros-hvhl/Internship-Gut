#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = TRUE)
# Generate Biom style txt file and convert to binary
# note : biom is a binary format so convert after script call
# - biom convert -i otu_table.txt -o new_otu_table.biom --to-hdf5 --table-type="OTU table" --process-obs-metadata taxonomy

otu_df <-read.csv(args[1],fileEncoding="UTF-8-BOM",
                  check.names = FALSE, sep = '\t', header = F)

integ <- read.csv(args[2],sep ='\t',header = F)
integ[,2]<-substring(integ[,2],2) # popping all '<'
integ[,1]<-substring(integ[,1],2)

#useless but for clarity, small operation
colnames(otu_df)<-c('tax','count')
colnames(integ)<-c('otu_name','tax')

# merge op by tax
merged <- merge(integ,otu_df,by='tax')
# DROP UNCLASSIFIED HERE
merged <- merged[-(which(merged$tax == 'Unclassified')),]


biom_formatted <- merged[,c('otu_name','count')]
samplename<-gsub("BIOM/(.*?).biom","\\1",args[3])
colnames(biom_formatted)<-c('#OTU ID', samplename)

write.table(biom_formatted,args[3],sep='\t' ,row.names = FALSE,col.names=T,quote = FALSE)



# new script to reassembly OTU naming with species data from mmz identification
# append all renamed OTUs
# extract header -> reload all data select unique vector ids.
# usage: Rscript relabel.r <input.metadata> <input.mp_data> <output>
# output as 'output.txt'

#-----------
# metadata , tab seperated, fasta header style needs to be popped.
args = commandArgs(trailingOnly=TRUE)
metadata <- read.table(args[1], sep = '\t')
c.metadata <- cbind(substring(metadata[['V1']],2),
                    substring(metadata[['V2']],2))
colnames(c.metadata)<- c('sequence', 'tax.mmz')
# metabolic potential nice and clean for dsp.
mp_data <- read.table(args[2],
                      header = T, check.names = F)
# keeping the data as single string (k=Bacteria;p=Bacteroidetes [...]) is easier for matching.
# but for later melting this can be parsed out.
# default merge function returns an inner join frame.
meta_mp <- merge(c.metadata, mp_data, by = 'sequence')
#write op.
write.table(meta_mp, args[3], sep = '\t')
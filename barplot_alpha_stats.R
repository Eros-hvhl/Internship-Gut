#testing something with general alpha diverstiy levels across groups.
library(ggplot2)
library(viridis)
library(ggpubr)
library(rstatix)
library(ggplot2)
library(ggprism)
library(patchwork)
library(magrittr)

sampledata<-read.csv("C:/Users/Eros/Desktop/metadata.txt",sep="\t")
# first time encountering "quote" field in read table, cool I guess.
mmz_alpha<-read.table("C:/Users/Eros/Desktop/merged_a_div.csv",quote=NULL,sep="\t")
mmz_alpha<-apply(mmz_alpha, 2, function(x)gsub('"',"",x))

# new metadata with samples to include, if sample data is available!
    # note : this line is dynamically changed with the present metadata in ppl
INC <- read.csv("C:/Users/Eros/Desktop/new_metadata.csv")
INC <- INC[INC$TO_INCLUDE,]

# even more hilarity: need to filter out the 2 samples? something wrong
    #fk this survey data mess

# automated to see if ID's occur twice.
id_vec <- names(which(table(selection$id)==2))

#mutations to work with due to the painfull shit
mmz_alpha[,2]<-as.numeric(mmz_alpha[,2])
mmz_alpha[,1]<-toupper(mmz_alpha[,1])
sampledata$sample<-toupper(sampledata$sample)
mmz_alpha <- as.data.frame(mmz_alpha)
colnames(mmz_alpha)<- c("sample", "shannon")

# selection of data included with alpha and grouping.
aplha_frame<-merge(sampledata,mmz_alpha)
selection<-aplha_frame[which(c(toupper(INC$ID_BL),toupper(INC$ID_END)) %!in% toupper(colnames(otu))),]


# trim the singles
selection <- selection[which(selection$id %in% id_vec),]

# histograms to check if the samples are normally distributed

selection %>% 
  ggplot(aes(x=as.numeric(shannon), fill = group))+
  geom_histogram( color="#e9ecef", alpha=0.6, position = 'identity') +
  scale_fill_manual(values= viridis(2,option="A"),
                    labels=c("Baseline", "post intervention")) +
  labs(fill="treatment", y = "count", x = " Shannon-index")+
  ggtitle("Histograms of Shannon indices before and after dietary intervention")
# not normally distributed? and much overlap.
    # in some cases it looks like there was a reduction, might be interesting


# basic means of before and after group resulting in 2x2 df.
mean.selection = data.frame(matrix(nrow = 2,ncol = 2))
colnames(mean.selection) = c("group","value")
mean.selection$group <- c("A","B")
# note: messy code, perhaps an intermediary but works fine.

bl<- as.numeric(selection$shannon[selection$group == "A"])
end<- as.numeric(selection$shannon[selection$group == "B"])


mean.selection$value <- c(mean(bl),mean(end))
mean.selection$sd <- c(sd(bl),sd(end))

# aside from the hists, Shapiro-Wilk test confirms not too much deviation...
shapiro.test(summary(bl))
shapiro.test(summary(end))


# not significant in this setup but good to include.
stat.test<-t.test(bl, end, paired = TRUE, alternative = "two.sided")
df_p_val <- data.frame(
  group1 = "A",
  group2 = "B",
  x = c(2, 3),
  label = signif(stat.test$p.value, digits = 3),
  y.position = c(7, 7))

p1 <- p + add_pvalue(df_p_val,
                     xmin = "group1",
                     xmax =  "group2",
                     label = "label",
                     y.position = 7) 


# generating plot barplot + error bars.
ggplot(data=mean.selection, aes(x=group, y=value)) +
geom_bar(stat = "identity",width = 0.5, fill = viridis(1, a = 0.7, option = "C"))+
  geom_text(nudge_x = .15, aes(label=round(value,digits = 3)), vjust=-0.3, size=3.5,)+
geom_errorbar( aes(x=group, ymin=value-sd, ymax=value+sd), width=0.2,
                 colour="black", alpha=0.7, size=1.2)+
labs(title= "Barplots of mean Shannon indices before and after dietary intervention",
     x = "Treatment", y = "Shannon index")+
  scale_x_discrete(labels= c("A" = "Baseline", "B" = "After intervention"))+
  scale_y_continuous(expand = expansion(mult = c(0, 0.1)))+
  add_pvalue(df_p_val, label = "p = {label}")
  
# box plots!

selection$shannon<-as.numeric(selection$shannon)

ggplot(selection, aes(x=group,y=shannon))+
  geom_boxplot(fill = viridis(1,a=0.7,option="C"))+
  labs(title= "Barplots of mean Shannon indices before and after dietary intervention",
       x = "Treatment", y = "Shannon index")+
  scale_x_discrete(labels= c("A" = "Baseline", "B" = "After intervention"))+
  scale_y_continuous(expand = expansion(mult = c(0, 0.1)))+
  add_pvalue(df_p_val, label = "p = {label}")

# OPTIONAL SAVING AND TURNING INTO MODULE


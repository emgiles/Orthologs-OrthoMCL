#Venn diagram of orthologous groups

getwd()
setwd("/Users/emily/Dropbox/School/Thesis/Genomics-Ch1/OrthoMCL")

#install.packages("VennDiagram")
#install.packages("UpSetR")
#install.packages("extrafont")
#install.packages("ggVennDiagram")

library(VennDiagram)
library(UpSetR)
library(extrafont)
library(ggVennDiagram)
#font_import()
fonts()

getwd()
setwd("/Users/emily/Dropbox/School/Thesis/Genomics-Ch1/OrthoMCL")

###### VENN DIAGRAM #####
df<- read.table("named_groups_1.5_freq.txt",  header=T, sep="\t")
head(df)
df.2 = data.frame(df$OG_name, df$scurscur, df$scurviri, df$scurzebr)
head(df.2)
str(df.2)
summary(df.2)

###Determine total genes in dataframe by summing all columns
df.2.2 <- data.frame(colSums(Filter(is.numeric, df.2)))
head(df.2.2)
genes.2 <- colSums(df.2.2)

###Dataframe representing the intersection of all three species orthologs
df.3 <- subset(df.2, df.scurscur>0 & df.scurviri>0 & df.scurzebr>0)
head(df.3)
str(df.3)
#Determine how many genes in this dataframe by summing all columns
df.3.2 <- data.frame(colSums(Filter(is.numeric, df.3)))
head(df.3.2)
genes.3 <- colSums(df.3.2)

###Dataframe representing the intersection of Sscurscur and Scurviri
df.4 <- subset(df.2, df.scurscur>0 & df.scurviri>0 & df.scurzebr==0)
head(df.4)
str(df.4)
#Determine how many genes in this dataframe by summing all columns
df.4.2 <- data.frame(colSums(Filter(is.numeric, df.4)))
head(df.4.2)
genes.4 <- colSums(df.4.2)

###Dataframe representing the intersection of scurscur and scurzebr
df.5 <- subset(df.2, df.scurscur>0 & df.scurviri==0 & df.scurzebr>0)
head(df.5)
str(df.5)
#Determine how many genes in this dataframe by summing all columns
df.5.2 <- data.frame(colSums(Filter(is.numeric, df.5)))
head(df.5.2)
genes.5 <- colSums(df.5.2)

###Dataframe representing the intersection of Sscurviri and Scurzebr
df.6 <- subset(df.2, df.scurscur==0 & df.scurviri>0 & df.scurzebr>0)
head(df.6)
str(df.6)
#Determine how many genes in this dataframe by summing all columns
df.6.2 <- data.frame(colSums(Filter(is.numeric, df.6)))
head(df.6.2)
genes.6 <- colSums(df.6.2)

###Dataframe representing the orthologous groups unique to of scurscur
df.7 <- subset(df.2, df.scurscur>0 & df.scurviri==0 & df.scurzebr==0)
head(df.7)
str(df.7)
#Determine how many genes in this dataframe by summing all columns
df.7.2 <- data.frame(colSums(Filter(is.numeric, df.7)))
head(df.7.2)
genes.7 <- colSums(df.7.2)

###Dataframe representing the orthologous groups unique to of Sscurviri
df.8 <- subset(df.2, df.scurscur==0 & df.scurviri>0 & df.scurzebr==0)
head(df.8)
str(df.8)
#Determine how many genes in this dataframe by summing all columns
df.8.2 <- data.frame(colSums(Filter(is.numeric, df.8)))
head(df.8.2)
genes.8 <- colSums(df.8.2)

###Dataframe representing the orthologous groups unique to of Sscurzebr
df.9 <- subset(df.2, df.scurscur==0 & df.scurviri==0 & df.scurzebr>0)
head(df.9)
str(df.9)
#Determine how many genes in this dataframe by summing all columns
df.9.2 <- data.frame(colSums(Filter(is.numeric, df.9)))
head(df.9.2)
genes.9 <- colSums(df.9.2)

###Create Venn Diagram of Orthogroup intersections. Area 1 - 3 come from that derived above.

area.ss <- genes.3+genes.4+genes.5+genes.7
area.sv <- genes.3+genes.4+genes.6+genes.8
area.sz <- genes.3+genes.6+genes.5+genes.9
pdf("venn_diagram_genes_9nov2023.pdf")
venn.genes <- draw.triple.venn(area1=area.ss, area2=area.sv, area3=area.sz, 
                               n12=genes.4+genes.3, n23=genes.6+genes.3, n13=genes.5+genes.3, n123=genes.3, 
                               category=c("S. scurra","S. viridula","S. zebrina"),
                               col="white",fill=c("#FB61D7","#A58AFF","#00B6EB"),
                               alpha = 0.50,
                               cex = 1,
                               fontfamily = "sans",
                               cat.cex = 1.5,
                               cat.fontfamily = "sans",
                               cat.fontface = "italic",
                               print.mode=c("raw","percent"), sigdigs=2)
dev.off() 
getwd()

##Write tables for GO enrichement analysis
#Dataframe representing genes unique to scurscur
head(df.7)
#Format to be the same as that needed by OrthoMCL parsers
colnames(df.7) <- c("OG_name", "scurscur", "scurviri", "scurzebr")
#Write table to wkdir
write.table(df.7, file='named_groups_1.5_freq_scurscur_uniqueOGs.txt', row.names=FALSE, quote=FALSE, sep='\t')

#Dataframe representing genes unique to scurviri
head(df.8)
#Format to be the same as that needed by OrthoMCL parsers
colnames(df.8) <- c("OG_name", "scurscur", "scurviri", "scurzebr")
#Write table to wkdir
write.table(df.8, file='named_groups_1.5_freq_scurviri_uniqueOGs.txt', row.names=FALSE, quote=FALSE, sep='\t')

#Dataframe representing genes unique to scurzebr
head(df.9)
#Format to be the same as that needed by OrthoMCL parsers
colnames(df.9) <- c("OG_name", "scurscur", "scurviri", "scurzebr")
#Write table to wkdir
write.table(df.9, file='named_groups_1.5_freq_scurzebr_uniqueOGs.txt', row.names=FALSE, quote=FALSE, sep='\t')


###### UPSET PLOT ######
orthogroups<- read.table("named_groups_1.5_freq.txt",  header=T, sep="\t")
head(orthogroups)
str(orthogroups)
summary(orthogroups)
data<- orthogroups[2:8] #remove orthologous group distinction
head(data)
str(data)
data[data > 0] <- 1 #Makes data binary
head(data)
colnames(data) <- c("H.rubra", "H.rufescens", "L.gigantea", "P.vulgata", "S.scurra", "S.viridula", "S.zebrina")

pdf("upset_7sp.pdf")
upset(data, order.by ="freq",
      keep.order=TRUE,
      show.numbers=FALSE,
      sets = c("H.rufescens","H.rubra","P.vulgata","L.gigantea","S.zebrina", "S.viridula","S.scurra"),
      sets.bar.color= group.colors)
dev.off()
      


group.colors <- c(Halirufe = "#F8766D", Halirubr = "#C49A00", patevulg = "#53B400", Lottgiga = "#00C094",Scurzebr ="#00B6EB", Scurviri = "#A58AFF",Scurscur = "#FB61D7")

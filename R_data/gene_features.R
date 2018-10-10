# installing stuff
source("https://bioconductor.org/biocLite.R")
biocLite("dplyr")
biocLite("tidyr")
biocLite("ggplot2")
biocLite("RColorBrewer")
biocLite("ggthemes")
# open libs
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)
library(ggthemes)

#change according to install location
setwd("D:/GIT_Represetorys_for_coding/R_data")

## read table
mut.tidy <- read.table("genetable.csv", sep=";", header = TRUE)

## set heatmap value as factor (so each gets one colour)
g <- sapply(mut.tidy, is.integer)
mut.tidy[g] <- lapply(mut.tidy[g], as.factor)

# plotting
gg <- ggplot(mut.tidy, aes(y=sample, x=gene, fill=mutated)) + geom_tile(color="white", size=0.5)
#gg <- gg + coord_equal()
#gg <- gg + labs(x="genes", y="plasmid type", title="Genmap of KPC plasmids")
gg <- gg + labs(x="", y="Plasmid type")
gg <- gg + theme_hc()
gg <- gg + theme(axis.text.x=element_text(angle = 270, vjust=0.5, hjust = 0))
gg <- gg + theme(legend.position="none")
gg <- gg + scale_fill_manual(values=c("#eaeaea", "#5D737E", "#CC8B86", "#7FC6A4", "#4a42e5", "#815777"))
gg <- gg + facet_grid(year ~ label, scales = "free", space = "free")
gg


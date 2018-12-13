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

## read table
df.plasmids <- read.table("genetable.csv", sep=";", header = TRUE)

## set heatmap value as factor (so each gets one colour)
g <- sapply(df.plasmids, is.integer)
df.plasmids[g] <- lapply(df.plasmids[g], as.factor)
## correct to beta
df.plasmids.clean <- data.frame(lapply(df.plasmids, function(x) {gsub("Î²", "ß", x)}))
# plotting

#tiff("figure_2.tiff",height = 1500, width = 700)
png("figure_2.png",height = 1500, width = 700, antialias)
#svg("figure_2.svg",height = 18, width = 8)

ggplot(df.plasmids.clean, aes(y=sample, x=gene, fill=mutated)) + 
  geom_tile(color="white", size=0.5) + 
  labs(x="", y="Plasmid type") + 
  theme_hc() + 
  theme(axis.text.x=element_text(angle = 270, vjust=0.5, hjust = 0)) + 
  theme(legend.position="none") + 
  scale_fill_manual(values=c("#eaeaea", "#5D737E", "#CC8B86", "#7FC6A4", "#4a42e5", "#815777")) + 
  facet_grid(year ~ label, scales = "free", space = "free")

dev.off()



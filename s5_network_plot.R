# ***********************
# Title: Network plot of Petal survey
#
# Author: Annalisa Hauck
# Created on: 23-03-2023
# Based on: Schweinberger, Martin. 2022. Network Analysis using R. Brisbane: The University of Queensland. 
#     url: https://ladal.edu.au/net.html 
# Adapted for readibility: January 2024. 
#
# **************************

# install.packages("psych")
# install.packages("lavaan")
# install.packages("GPArotation")
# install.packages("psychTools")  #iCLUST
# install.packages("Rgraphviz") #iCLUST
# install.packages("ltm") #for Cronbach Alpha

# ****************************

rm(list=ls())         # Clear R's memory
library(psych)
library(lavaan)
library(psychTools)
# library(Rgraphviz)
library(ltm)
library(sna)

# Read data
Dataset = read.table("./data/survey.csv", header=TRUE, sep=',')
Dataset_key = read.table("./data/survey-key.csv", header=TRUE, sep=',')

Dataset <- Dataset[,-3]  # Clear empty heading Q3 variable 
Dataset_pre = Dataset[Dataset$Q2 ==1,]
Dataset_post = Dataset[Dataset$Q2 ==0,]

DatasetQ4 <- Dataset[, c("Q4_9", "Q4_8","Q4_7","Q4_6","Q4_5","Q4_4","Q4_3","Q4_2","Q4_1","Q4_0")]
colnames(DatasetQ4) = Dataset_key[38:47,2]

DatasetQ4_pre <- Dataset_pre[, c("Q4_9", "Q4_8","Q4_7","Q4_6","Q4_5","Q4_4","Q4_3","Q4_2","Q4_1","Q4_0")]
colnames(DatasetQ4_pre) = Dataset_key[38:47,2]

DatasetQ4_post<- Dataset_post[, c("Q4_9", "Q4_8","Q4_7","Q4_6","Q4_5","Q4_4","Q4_3","Q4_2","Q4_1","Q4_0")]
colnames(DatasetQ4_post) = Dataset_key[38:47,2]

DatasetQ4_pos_neg = DatasetQ4
DatasetQ4_pos_neg$ANXIOUS = (DatasetQ4$ANXIOUS - 1)*(-1)
DatasetQ4_pos_neg$STRESSED = (DatasetQ4$STRESSED - 1)*(-1)
DatasetQ4_pos_neg$HELPLESS = (DatasetQ4$HELPLESS - 1)*(-1)
DatasetQ4_pos_neg$FRUSTRATED = (DatasetQ4$FRUSTRATED - 1)*(-1)
DatasetQ4_pos_neg$UPSET = (DatasetQ4$UPSET - 1)*(-1)

# *****************************************************

# Reorder feelings so that they are grouped when similar. This also reflects the 
# adjective groups suggested by the factor analysis.
# 
col_order <- c("CALM", "RELAXED","UPSET","HELPLESS","FRUSTRATED","STRESSED","ANXIOUS","REASSURED","USEFUL", "EMPOWERED")
DatasetQ4_2 <- DatasetQ4[, col_order]
DatasetQ4_pre2 <- DatasetQ4_pre[, col_order]
DatasetQ4_post2 <- DatasetQ4_post[, col_order]
# 

# Create cooccurrence matrix
cooccurrence = matrix(nrow=10, ncol=10)
colnames(cooccurrence) <- c("CALM", "RELAXED","UPSET","HELPLESS","FRUSTRATED","STRESSED","ANXIOUS","REASSURED","USEFUL", "EMPOWERED")
rownames(cooccurrence) <- c("CALM", "RELAXED","UPSET","HELPLESS","FRUSTRATED","STRESSED","ANXIOUS","REASSURED","USEFUL", "EMPOWERED")

for (x in 1:10) {
  for (y in 1:10) {
    cooccurrence[x,y]= sum(DatasetQ4_2[,x]== 1 & DatasetQ4_2[,y]== 1)
  }
}

# Next:  ggnet

# install.packages("flextable")
# install.packages("GGally")
# install.packages("ggraph")
# install.packages("igraph")
# install.packages("Matrix")
# install.packages("network")
# install.packages("quanteda")
# install.packages("sna")
# install.packages("tidygraph")
# install.packages("tidyverse")
# install.packages("tm")
# install.packages("tibble")
# install.packages("quanteda.textplots")
# # install klippy for copy-to-clipboard button in code chunks
# install.packages("remotes")
# remotes::install_github("rlesur/klippy")

# ****************************

library(flextable)
library(GGally)
library(ggraph)
library(gutenbergr)
library(igraph)
library(Matrix)
library(network)
library(quanteda)
library(sna)
library(tidygraph)
library(tidyverse)
library(tm)
library(tibble)
# activate klippy for copy-to-clipboard button
klippy::klippy()

################################################################################################

# Create nodes and edges for network plot

feelings = data.frame(matrix(nrow = 10, ncol = 2)) 
colnames(feelings) = c("feeling", "n") 
for (i in 1:10) {
  feelings[i,1] = col_order[i]
}
feelings[,2] = diag(cooccurrence)

interactions = data.frame(matrix(nrow = 45, ncol = 3)) 
colnames(interactions) = c("from", "to","weight") 
start_row_idx = c(1, 10, 18, 25, 31, 36, 40, 43, 45)


for (y in 1:9) {
  for (i in 0:(9-y)) {
    interactions[start_row_idx[y]+i,1] = col_order[i+y+1]
    interactions[start_row_idx[y]+i,2] = col_order[y]
    interactions[start_row_idx[y]+i,3] = cooccurrence[i+1+y,y]
  }
}

# Remove rows with 0 interactions
interactions = interactions[interactions$weight != 0, ]                  
feelings$id <- seq(1:(nrow(feelings)))

##########################################################################################

# Prepare ig graph 
library(dplyr)
library(tidygraph)
ig <- tbl_graph(feelings,interactions, directed=F)
# ig1 <- delete.edges(ig, E(ig)[ abs(weight) < 0.3 ])
plot(ig)

ig %>% activate(nodes) %>% as_tibble()
ig %>% activate(edges) %>% as_tibble()
ig %>% activate(edges) %>% arrange(desc(weight)) %>% as_tibble() %>% head()
ig %>% activate(edges) %>% pull(weight) -> frequencies
hist(frequencies)
ig %>% activate(edges) %>% filter(weight>10) %>% activate(nodes) %>% mutate(degree=centrality_degree()) %>% filter(degree>0) %>% plot()


library(ggraph)

tg <- tidygraph::as_tbl_graph(ig) %>% 
  tidygraph::activate(nodes) %>% 
  dplyr::mutate(label=feelings$feeling)
plot(tg)


Replies <- V(tg)$n
# inspect
Replies

v.size <- V(tg)$n
# inspect
v.size

#Edges weights
E(tg)$weight <- E(tg)$weight 
# inspect weights
head(E(tg)$weight, 10)


# define colors (positive vs negative feelings)
pos <- c("CALM", "RELAXED", "USEFUL", "REASSURED", "EMPOWERED")
neg <- c("ANXIOUS", "STRESSED", "HELPLESS", "UPSET", "FRUSTRATED")

# create color vectors
Feelings <- dplyr::case_when(sapply(tg, "[")$nodes$feeling %in% pos ~ "positive feelings",
                             sapply(tg, "[")$nodes$feeling %in% neg ~ "negative feelings",
                             TRUE ~ "Other")
# inspect colors
Feelings

# set seed
set.seed(12345)
# edge size shows frequency of co-occurrence
tg %>%
  ggraph(layout = "fr") +
  geom_edge_arc(colour= "gray50",
                lineend = "round",
                strength = .1,
                alpha=.6,
                aes(edge_width = weight)) +
  geom_node_point(aes(size=Replies, color=Feelings)) +
  geom_node_text(aes(label = feelings$feeling), 
                 repel = TRUE, 
                 point.padding = unit(0.2, "lines"), 
                 size=sqrt(Replies), 
                 colour="gray10") +
  scale_edge_width(range = c(0, 2.5)) +
  scale_edge_alpha(range = c(0, .3)) +
  theme_graph(background = "white") +
  theme(legend.position = "top")
# +   guides(edge_width = FALSE,
#         edge_alpha = FALSE)

# geom_node_point(size=log(v.size)*2, aes(color=Family))

library("tm")
library("slam")
path_training <- "C:/Users/Sandeep/Documents/Coursera/Data science capstone/final/training/"
path_ngrams <- "C:/Users/Sandeep/Documents/Coursera/Data science capstone/final/ngrams/"
myCorpus <- VCorpus(DirSource(path_training))

myCorpus <- tm_map(myCorpus,removeNumbers)
myCorpus <- tm_map(myCorpus,removePunctuation)
myCorpus <- tm_map(myCorpus,content_transformer(tolower))
myCorpus <- tm_map(myCorpus,removeWords, stopwords("english"))
myCorpus <- tm_map(myCorpus,stripWhitespace)

ngram_tokenizer <- function(x,n)unlist(sapply(sapply(strsplit(as.character(x),"\\s+"),ngrams,n),sapply,paste,collapse=" "))

trigram_tokenizer <- function(x)ngram_tokenizer(x,3)
myTrigrams <- TermDocumentMatrix(myCorpus,control=list(tokenize=trigram_tokenizer))

bigram_tokenizer <- function(x)ngram_tokenizer(x,2)
myBigrams <- TermDocumentMatrix(myCorpus,control=list(tokenize=bigram_tokenizer))

unigram_tokenizer <- function(x)ngram_tokenizer(x,1)
myUnigrams <- TermDocumentMatrix(myCorpus,control=list(tokenize=unigram_tokenizer))

sumTrigrams <- rowapply_simple_triplet_matrix(myTrigrams,sum)
sumBigrams <- rowapply_simple_triplet_matrix(myBigrams,sum)                       
sumUnigrams <- rowapply_simple_triplet_matrix(myUnigrams,sum)                       

sumTrigrams <- sumTrigrams[!grepl("[^(A-z| )]",names(sumTrigrams))]
sumBigrams <- sumBigrams[!grepl("[^(A-z| )]",names(sumBigrams))]
sumUnigrams <- sumUnigrams[!grepl("[^(A-z| )]",names(sumUnigrams))]

freq_freq <- data.frame(Trigram=double(6),Bigram=double(6),Unigram=double(6))
for (i in 1:6){
      freq_freq[i,"Trigram"] <- sum(sumTrigrams==i)
      freq_freq[i,"Bigram"] <- sum(sumBigrams==i)
      freq_freq[i,"Unigram"] <- sum(sumUnigrams==i)
}

discount_coeff <- data.frame(Trigram=double(5),Bigram=double(5),Unigram=double(5))
for (i in 1:5){
      discount_coeff[i,"Trigram"] <- ((i+1)*freq_freq[i+1,"Trigram"])/(i*freq_freq[i,"Trigram"])
      discount_coeff[i,"Bigram"] <- ((i+1)*freq_freq[i+1,"Bigram"])/(i*freq_freq[i,"Bigram"])
      discount_coeff[i,"Unigram"] <- ((i+1)*freq_freq[i+1,"Unigram"])/(i*freq_freq[i,"Unigram"])
}

df1 <-data.frame(t(sapply(strsplit(names(sumTrigrams)," "),rbind)))
colnames(df1) <- c("W1","W2","W3")
df1 <- data.frame(df1,C=sumTrigrams,
                  d=ifelse(sumTrigrams %in% 1:5,discount_coeff[sumTrigrams,"Trigram"],1))
df1 <- data.frame(W1W2=paste(df1$W1,df1$W2),W3=df1$W3,C=df1$C,d=df1$d)
df1$C <- as.double(as.character(df1$C))
df2 <- tapply(df1$C,df1$W1W2,sum)
df2 <- data.frame(W1W2=names(df2),N=df2)
df1 <- merge(df1,df2,by="W1W2")
df1$C <- as.double(as.character(df1$C))
df1$d <- as.double(as.character(df1$d))
df1$N <- as.double(as.character(df1$N))
df1 <- data.frame(df1,
                  P=round(df1$C*df1$d/df1$N,4),
                  B=round(df1$C*(1-df1$d)/df1$N,4))
df2 <- tapply(df1$B,df1$W1W2,sum)
df2 <- df2[df2!=0]
df2 <- data.frame(W1W2=names(df2),W3=rep("leftover_probability",nrow(df2)),P=df2)
df1 <- rbind(df1[,c("W1W2","W3","P")],df2[,c("W1W2","W3","P")])
uniq_W1W2 <- levels(as.factor(df1$W1W2))
uniq_W3 <- levels(as.factor(df1$W3))
stmTrigrams <- simple_triplet_matrix(i=match(df1[,"W1W2"],uniq_W1W2),
                                     j=match(df1[,"W3"],uniq_W3),
                                     v=df1[,"P"],
                                     dimnames=list(W1W2=uniq_W1W2,W3=uniq_W3))
saveRDS(stmTrigrams,paste(path_ngrams,"Trigrams",sep=""))

df1 <-data.frame(t(sapply(strsplit(names(sumBigrams)," "),rbind)))
colnames(df1) <- c("W1","W2")
df1 <- data.frame(df1,C=sumBigrams,
                  d=ifelse(sumBigrams %in% 1:5,discount_coeff[sumBigrams,"Bigram"],1))
df1$C <- as.double(as.character(df1$C))
df2 <- tapply(df1$C,df1$W1,sum)
df2 <- data.frame(W1=names(df2),N=df2)
df1 <- merge(df1,df2,by="W1")
df1$C <- as.double(as.character(df1$C))
df1$d <- as.double(as.character(df1$d))
df1$N <- as.double(as.character(df1$N))
df1 <- data.frame(df1,
                  P=round(df1$C*df1$d/df1$N,4),
                  B=round(df1$C*(1-df1$d)/df1$N,4))
df2 <- tapply(df1$B,df1$W1,sum)
df2 <- df2[df2!=0]
df2 <- data.frame(W1=names(df2),W2=rep("leftover_probability",nrow(df2)),P=df2)
df1 <- rbind(df1[,c("W1","W2","P")],df2[,c("W1","W2","P")])
uniq_W1 <- levels(as.factor(df1$W1))
uniq_W2 <- levels(as.factor(df1$W2))
stmBigrams <- simple_triplet_matrix(i=match(df1[,"W1"],uniq_W1),
                                    j=match(df1[,"W2"],uniq_W2),
                                    v=df1[,"P"],
                                    dimnames=list(W1=uniq_W1,W2=uniq_W2))
saveRDS(stmBigrams,paste(path_ngrams,"Bigrams",sep=""))

df1 <- data.frame(W1=names(sumUnigrams),C=sumUnigrams,
                  d=ifelse(sumUnigrams %in% 1:5,discount_coeff[sumUnigrams,"Unigram"],1),
                  N=rep(sum(as.double(as.character(sumUnigrams))),length(sumUnigrams)))
df1$C <- as.double(as.character(df1$C))
df1$d <- as.double(as.character(df1$d))
df1$N <- as.double(as.character(df1$N))
df1 <- data.frame(df1,
                  P=round(df1$C*df1$d/df1$N,4),
                  B=round(df1$C*(1-df1$d)/df1$N,4))
df2 <- data.frame(W1="leftover_probability",P=sum(df1$B))
df1 <- rbind(df1[,c("W1","P")],df2[,c("W1","P")])
uniq_W1 <- levels(as.factor(df1$W1))
stmUnigrams <- simple_sparse_array(i=match(df1[,"W1"],uniq_W1),
                                   v=df1[,"P"],
                                   dimnames=list(W1=uniq_W1))
saveRDS(stmUnigrams,paste(path_ngrams,"Unigrams",sep=""))






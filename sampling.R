library("tm")
path_source <- "C:/Users/Sandeep/Documents/Coursera/Data science capstone/final/en_US/"
path_training <- "C:/Users/Sandeep/Documents/Coursera/Data science capstone/final/training/"
path_test <- "C:/Users/Sandeep/Documents/Coursera/Data science capstone/final/test/"

myCorpus <- VCorpus(DirSource(path_source))

sample_file <- function(pathr,pathw1,pathw2,file,vsample){
      conr <- file(paste(pathr,file,sep=""),"r")
      conw1 <- file(paste(pathw1,file,sep=""),"w")
      conw2 <- file(paste(pathw2,file,sep=""),"w")
      counter <- 0
      repeat{
            rec <- readLines(conr,1,skipNul=TRUE,warn=FALSE)
            if (length(rec)==0){
                  break
            }
            counter <- counter+1
            if (vsample[counter]==1){
                  writeLines(rec,conw1)
            }
            if (vsample[counter]==0){
                  writeLines(rec,conw2)
            }            
      }
      close(conr)
      close(conw1)
      close(conw2)
}

newsLC <- length(myCorpus[["en_US.news.txt"]][[1]])
blogsLC <- length(myCorpus[["en_US.blogs.txt"]][[1]])
twitterLC <- length(myCorpus[["en_US.twitter.txt"]][[1]])

set.seed(1234)

vsample <- rbinom(n=newsLC,size=1,prob=0.1)
sample_file(path_source,path_training,path_test,"en_US.news.txt",vsample)

vsample <- rbinom(n=blogsLC,size=1,prob=0.1)
sample_file(path_source,path_training,path_test,"en_US.blogs.txt",vsample)

vsample <- rbinom(n=twitterLC,size=1,prob=0.1)
sample_file(path_source,path_training,path_test,"en_US.twitter.txt",vsample)

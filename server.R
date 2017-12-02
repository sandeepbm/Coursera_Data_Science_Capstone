
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(tm)

shinyServer(function(input, output) {
      input_text <- reactive({
            x <- input$input_text
            x <- removeNumbers(x)
            x <- removePunctuation(x)
            x <- tolower(x)
            x <- removeWords(x,stopwords("english"))
            x <- stripWhitespace(x)
            x <- strsplit(x," ")[[1]]
            if (length(x)<2){
                  x <- paste(" ",x,collapse=" ")
            }
            if (length(x)>2){
                  x <- paste(x[-(1:(length(x)-2))],collapse=" ")
            }
            if (length(x)==2){
                  x <- paste(x,collapse=" ")
            }
            x
      })
      
      gram_3 <- reactive({
            W1W2i <- which(Trigrams$dimnames[[1]]==input_text())
            if (length(W1W2i)==0){
                  v <- numeric(0)
            } else{
                  i <- which(Trigrams$i == W1W2i)
                  v <- Trigrams$v[i]
                  j <- Trigrams$j[i]
                  names(v) <- Trigrams$dimnames[[2]][j]
            }
            v
      })

      gram_2 <- reactive({
            x <- strsplit(input_text()," ")[[1]]
            last_word <- x[length(x)]
            W1i <- which(Bigrams$dimnames[[1]]==last_word)
            if (length(W1i)==0){
                  v <- numeric(0)
            } else{
                  i <- which(Bigrams$i == W1i)
                  v <- Bigrams$v[i]
                  j <- Bigrams$j[i]
                  names(v) <- Bigrams$dimnames[[2]][j]
                  if (length(gram_3())>0){
                        v <- leftover_probability(gram_3(),v)
                  }
            }
            v
      })      

      gram_1 <- reactive({
            v <- Unigrams$v
            names(v) <- Unigrams$dimnames[[1]]
            if (length(gram_3())>0 & length(gram_2())>0){
                  v <- numeric(0)
            }
            if (length(gram_3())>0 & length(gram_2())==0){
                  v <- leftover_probability(gram_3(),v)
            }
            if (length(gram_3())==0 & length(gram_2())>0){
                  v <- leftover_probability(gram_2(),v)
            }
            v
      })         
      
      leftover_probability <- function(x,v){
            i <- which(names(x)=="leftover_probability")
            if (length(i)==0){
                  v <- numeric(0)
            } else{
                  beta <- x[i]
                  x <- x[-i]
                  v <- v[names(v)[!(names(v) %in% names(x))]]
                  if (beta>0 & length(v)>0){
                        v <- round(v*beta/sum(v),4)
                  } else{
                        v <- numeric(0)
                  }
                  
            }
            v
      }
      
      output$prediction <- renderText({
            x <- c(gram_3(),gram_2(),gram_1())
            i <- which(names(x)=="leftover_probability")
            if (length(i)!=0){
                  x <- x[-i]
            }
            names(x[x==max(x)])[1]
      })
      
      output$displot <- renderPlot({
            x <- gram_3()
            y <- gram_2()
            z <- gram_1()
            par(mfrow=c(sum(sapply(list(x,y,z),length)>0),1),mar=c(5,4,1,1))
            if (length(x)!=0){
                  plotv <- plot_values(x)
                  barplot(plotv[1:5],
                          main="TRIGRAM model",
                          ylab="Probability",
                          ylim=c(0,1)) 
            }
            if (length(y)!=0){
                  plotv <- plot_values(y)
                  barplot(plotv[1:5],
                          main="BIGRAM model",
                          ylab="Probability",
                          ylim=c(0,1)) 
            }
            if (length(z)!=0){
                  plotv <- plot_values(z)
                  barplot(plotv[1:5],
                          main="UNIGRAM model",
                          ylab="Probability",
                          ylim=c(0,1)) 
            }
      })
      
      plot_values <- function(x){
            i <- which(names(x)=="leftover_probability")
            if (length(i)!=0){
                  x <- x[-i]
            }
            x <- x[order(-x)]
      }
      
})
      




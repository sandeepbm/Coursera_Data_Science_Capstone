
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Text Prediction App"),

  # Input text
  sidebarLayout(
    sidebarPanel(
      textInput("input_text","Enter Ngram phrase:")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(selected="Prediction",
      tabPanel("About",
      br(),
      tags$p("This app predits next word for a given N-gram/text phrase."),
      tags$ul(
      tags$li("Input N-gram/text phrase is accepted from user through a text box on left hand side panel."),
      tags$li("Next word, as determined by prediction algorithm, is displayed top of main panel in an output text box."),
      tags$li("Prediction algorithm determines next word using maximum likelihood probability as determined from an N-gram model trained on data sampled from a text Corpus."),
      tags$li("N-gram plot is displayed on screen that compares probabilty of top words, upto maximum of 5 words, that have the maximum likelihood estimate. When smoothing is applied, plot for back off model will also be displayed.")
      )),
      tabPanel("Prediction",
      tags$u(h4("Prediction:")),
      verbatimTextOutput("prediction"),
      br(),
      tags$u(h4("Ngram plots:")),
      plotOutput("displot")
      )
      )
    )
  )
))

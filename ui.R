
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
      tags$p("This app predits next word for a given N-gram/text phrase in the 'Prediction' tab."),
      tags$ul(
      tags$li(tags$u("Input:"),"A text box on left hand side panel accepts an N-gram/text phrase as input."),
      tags$li(tags$u("Output:"),"The prediction algorithm determines next word for the given input and displays the same in a text box at the top of the main panel."),
      tags$li(tags$u("Algorithm:"),"A Katz back off n-gram model, that is trained on data sampled from a text Corpus, is used to determine conditional probabilty of possible words and maximum likelihood estimation is done to arrive at the output."),
      tags$li(tags$u("Visualization:"),"N-gram plots are displayed on main panel to compare probabilty of top words, upto maximum of 5 words, that have the maximum likelihood estimate. When smoothing is applied, plot for back off model is also displayed.")),
      tags$p(tags$b("Github link:"),
      tags$u(tags$a(href="https://github.com/sandeepbm/Coursera_Data_Science_Capstone","https://github.com/sandeepbm/Coursera_Data_Science_Capstone")))
      ),
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

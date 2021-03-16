library(shiny)

ui <- fluidPage( # lets. check 
  sidebarLayout(
    sidebarPanel(
      fileInput("datain", "Upload WHIP Export", accept = c(".xlsx")
                #accept = c(
                  # "text/csv",
                  # "text/comma-separated-values,text/plain",
                 # ".csv")
      ),
      # tags$hr(),
      # checkboxInput("header", "Header", TRUE)
      radioButtons("country", 'Select the Country', 
                   choiceValues=c('Cambodia', 'Lao PDR', 'Vietnam'),
                   choiceNames = c('Cambodia', 'Lao PDR', 'Vietnam'), 
                   inline = F),  
      
      downloadButton("report", "Assess data")
    ),
    mainPanel(
      tableOutput("contents")
    ),
    
    mainPanel("Download all the data from WHIP. Specifically, go to the quick search and click on the down arrow.
              In 'Category', select 'Event', and in 'Field' select 'Event Code'. Type 'wcs' in 'Value' and click on 
              the green button on the upper-right corner. Click on 'Export' and save the excel file. Finally,
              upload the excel file to the app, click on 'Assess...' and wait for 3-5 minutes. Download the .html
              output and presto! (Let me know if you have any problems)")
  )
)

server <- function(input, output) {
  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "data_quality.html",
    content = function(file) {
      
      
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "assess_data.Rmd")
      file.copy("assess_data.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(country.of.interest = input$country, 
                     path.to.file=input$datain$datapath)
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv()))
    }
  )
}

shinyApp(ui, server) # testing this...
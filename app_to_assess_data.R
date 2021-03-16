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
    )
  )
)

server <- function(input, output) {
  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "data_quality.html",
    content = function(file) {
      
      # report<-"Checking_quality_whip_data_per_country.Rmd"
      # src <- normalizePath(report)
      # 
      # owd <- setwd(tempdir())
      # on.exit(setwd(owd))
      # file.copy(src, report, overwrite = TRUE)
      # 
      
      
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
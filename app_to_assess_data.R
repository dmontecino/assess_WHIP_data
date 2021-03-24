library(shiny)
library(readxl)



ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      fileInput("datain", "Upload WHIP Export", buttonLabel = "Choose file..."),
      radioButtons('country', 'Select country', 
                   choiceValues=c("Cambodia", "Lao PDR", "Vietnam"),
                   choiceNames = c('Cambodia', 'Laos', 'Viet nam'), inline = F),
      downloadButton("report", "Assess data")
    ),
    
    
    mainPanel("Download all the data from WHIP. Specifically, go to the quick search and click on the down arrow.
              In 'Category', select 'Event', and in 'Field' select 'Event Code'. Type 'wcs' in 'Value' and click on 
              the green button on the upper-right corner. 
              Select all the sections in the export options and select 'Specimens' and 'Observation' as well. 
              Click on 'Export' and save the excel file. 
              Upload the excel file to the app, click on 'Assess data' and wait for some minutes (seriouly, just wait). 
              Open and download the .html output (Let me know if you have any problems).")
  )
)




server <- function(input, output) {
  
  number_of_columns=627 # counted the number of columns in the original excel
  
  dataset<-reactive({
    # inFile <- input$datain
    dat<-read_excel(path =input$datain$datapath, sheet = 1, col_types = rep("text", number_of_columns))
    return(dat)
  })
  
  dataset2<-reactive({
    # inFile <- input$datain
    dat<-read_excel(path =input$datain$datapath, sheet = 2, col_types = rep("text", number_of_columns))
    return(dat)
  })
  
  output$report <- downloadHandler(
    filename = "report.html",
    content = function(file) {
      
      report<-"assess_data.Rmd"
      src <- normalizePath(report)
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, report, overwrite = TRUE)
      
      spec <- dataset()
      obs <- dataset2()
      
      params <- list(spec = spec,
                     obs = obs,
                     country.of.interest=input$country)
      
      out<-rmarkdown::render(report,
                             output_file = file,
                             params = params,
                             envir = new.env(parent = globalenv()))
      
      file.rename(out, file)
      
    }
  )
}



shinyApp(ui, server)

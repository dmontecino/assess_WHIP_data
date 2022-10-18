library(shiny)
library(readxl)



ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      fileInput("datain", "Upload WHIP Export", buttonLabel = "Choose file..."),
      # radioButtons('country', 'Select country',
      #              choiceValues=c("Cambodia", "Lao PDR", "Vietnam"),
      #              choiceNames = c('Cambodia', 'Laos', 'Viet nam'), inline = F),
      downloadButton("report", "Assess data")
    ),
    
    
    mainPanel("Download all the data from WHIP. Specifically, go to the quick search and click on the down arrow.
              In 'Category', select 'Event', and in 'Field' select 'Event Code'. Type 'wcs' in 'Value' and click on 
              the green button on the upper-right corner. 
              Select all the sections in the export options and select 'Observation', 'Specimen', and 'Environmental Specimen'. 
              Click on 'Export' and save the excel file. 
              Upload the excel file to the app, click on 'Assess data' and wait for some minutes (seriouly, just wait). 
              Open and download the .html output (Let me know if you have any problems).")
  )
)


options(shiny.maxRequestSize=30*1024^2)

server <- function(input, output) {
  
  # options(shiny.maxRequestSize=30*1024^2) 
  
  # first open the observation and spec to get the number of columns
  
   dataset<-reactive({
    # inFile <- input$datain
    dat1<-read_excel(path =input$datain$datapath, sheet = 1, col_types = "text")
    return(dat1)
  })
  
   # dataset<-reactive({
   #   # inFile <- input$datain
   #   dat<-lapply(c(1:3), function(x) read_excel(path =input$datain$datapath, sheet = x, col_types = "text"))
   #   return(dat)
   # })
     
  dataset2<-reactive({
    # inFile <- input$datain
    dat2<-read_excel(path =input$datain$datapath, sheet = 2, col_types = "text")
    return(dat2)
  })
  
  dataset3<-reactive({
    # inFile <- input$datain
    dat3<-read_excel(path =input$datain$datapath, sheet = 3, col_types = "text")
    return(dat3)
  })
  
  
  output$report <- downloadHandler(
    filename = "report.html",
    content = function(file) {
      
      report<-"assess_data.Rmd"
      src <- normalizePath(report)
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, report, overwrite = TRUE)
      
      obs.temp <- dataset()
      spec.temp <- dataset2()
      env_spec.temp <- dataset3()
      
      params <- list(obs = obs.temp,
                     spec = spec.temp,
                     env_spec = env_spec.temp
                     #country.of.interest=input$country
      )
      
      out<-rmarkdown::render(report,
                             output_file = file,
                             params = params,
                             envir = new.env(parent = globalenv()))
      
      file.rename(out, file)
      
    }
  )
}



shinyApp(ui, server)

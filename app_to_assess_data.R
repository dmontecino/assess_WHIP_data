library(shiny)
library(readxl)



ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      fileInput("datain", "Upload WHIP Export", buttonLabel = "Choose file..."),
      downloadButton("report", "Assess Data")
    ),
    
    mainPanel("Download all the data from WHIP. Specifically, go to the quick search and click on the down arrow.
              In 'Category', select 'Event', and in 'Field' select 'Event Code'. Type 'wcs' in 'Value' and click on 
              the green button on the upper-right corner. Click on 'Export' and save the excel file. Finally,
              upload the excel file to the app, click on 'Assess...' and wait for 3-5 minutes. Download the .html
              output and presto! (Let me know if you have any problems).")
    
    
    )
  )


server = function(input, output, session) {

  number_of_columns=619 # counted the number of columns in the original excel
  
  # specimens
  dataset<-reactive({
    # inFile <- input$datain
    dat<-read_excel(path =input$datain$datapath, sheet = 1, col_types = rep("text", number_of_columns))
    return(dat)
  })
  
  #observations
  dataset2<-reactive({
    # inFile <- input$datain
    dat<-read_excel(path =input$datain$datapath, sheet = 2, col_types = rep("text", number_of_columns))
    return(dat)
  })
  
  
  output$report <- downloadHandler(
    filename = "data_quality.html",
    content = function(file) {
      report<-"assess_data.Rmd"
      src <- normalizePath(report)
      
      
      
      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, report, overwrite = TRUE)
      spec <- dataset()
      obs <- dataset2()
      
      params <- list(spec = spec,
                     obs = obs)
      
      library(rmarkdown)
      out <- rmarkdown::render(report,
                               output_file = file,
                               params = params,
                               envir = new.env(parent = globalenv()))
      file.rename(out, file)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)

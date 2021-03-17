library(shiny)

ui = fluidPage(
  
  sidebarLayout(
    sidebarPanel(
      fileInput("datain", "Upload data", buttonLabel = "Choose file..."),
      downloadButton("report", "Generate report")
    ),
    
    mainPanel("Download all the data from WHIP. Specifically, go to the quick search and click on the down arrow.
              In 'Category', select 'Event', and in 'Field' select 'Event Code'. Type 'wcs' in 'Value' and click on 
              the green button on the upper-right corner. Click on 'Export' and save the excel file. Finally,
              upload the excel file to the app, click on 'Assess...' and wait for 3-5 minutes. Download the .html
              output and presto! (Let me know if you have any problems).")
    
    
    ))


server = function(input, output, session) {
  
  
  
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
  
       # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      library(rmarkdown)
      out <- render(report,
                    params = list(datain = input$datain$datapath))
      file.rename(out, file)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)

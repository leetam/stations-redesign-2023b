library(shiny)
library(shinydashboard)
library(DT)
library(dplyr)
library(leaflet)
library(ggplot2)
library(plotly)

metadata <- readRDS("data/atr_its_map_meta.rds")
i5_daily <- readRDS("data/i5_daily_station.rds")

function(input, output, session) {
  
  
  #### Metadata table display ####
  output$metadata_table = renderDT({
      datatable(
      metadata,
      filter = "top",
      colnames = c("Station ID",
                   "Agency ID",
                   "Milepost",
                   "Description",
                   "Mainline Lanes",
                   "Agency",
                   "Highway",
                   "Direction",
                   "Source",
                   "Start Date",
                   "Ramp ID(s)",
                   "Longitude",
                   "Latitude"
                   ),
      rownames = F,
      selection = "multiple",
      options = list(pageLength = 5,
                     stateSave = F,
                     columnDefs = list(list(visible = F,
                                            targets = c(11, 12)
                                            )
                                       )
      )
    )
  })
  
  proxy = dataTableProxy("metadata_table")
  
  observeEvent(input$reset, {
    proxy %>%
      selectRows(NULL)
  })
  
  #### Reactive table to filter data for map ####
  filtered_table <- reactive({
    req(input$metadata_table_rows_all)
    metadata[input$metadata_table_rows_all, ]
  })
  
  #### Reactive Map ####
  output$stations_map <- renderLeaflet({
    filtered_table() %>%
      leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(
        lng = filtered_table()$lon,
        lat = filtered_table()$lat,
        clusterOptions = markerClusterOptions(maxClusterRadius = 2),
        popup = paste("Description: ", filtered_table()$locationtext, "<br>",
                      "Station ID: ", filtered_table()$stationid, "<br>",
                      "Agency ID: ", filtered_table()$agencyid, "<br>",
                      "Highway: ", filtered_table()$highway, "<br>",
                      "Direction: ", filtered_table()$direction, "<br>",
                      "Milepost: ", filtered_table()$milepost, "<br>",
                      "Agency: ", filtered_table()$agency, "<br>",
                      "Source: ", filtered_table()$source
                      )
      )
  })

  #### Data Gaps Plot ####
    output$data_gap_figure <- renderPlotly({
      req(input$metadata_table_rows_selected)
      selected = input$metadata_table_rows_selected
      stationsid <- unique(metadata[selected, c("stationid")])
      df <- i5_daily[i5_daily$stationid %in% stationsid, ]
      data_gaps <- df %>%
        # filter(stationid %in% stationsid) %>%
        filter(year == input$year) %>%
        ggplot(aes(x = date, y = data_available)) +
        geom_bar(stat = "identity", fill = "pink") +
        facet_grid(stationid ~ .) +
        theme_bw() +
        xlab(NULL) +
        ylab("% data available") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        geom_hline(yintercept = input$y_percent, linewidth = 0.3)
      ggplotly(data_gaps)
    })
  
}

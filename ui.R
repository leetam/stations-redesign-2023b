library(shiny)
library(shinydashboard)
library(DT)
library(leaflet)
library(plotly)
library(ggplot2)

header <- dashboardHeader(title = "Stations DRAFT",
                          titleWidth = 450)

body <- dashboardBody(
  
  #### Text boxes info ####
  fluidRow(
    column(
      width = 4,
      box(
        width = NULL,
        tags$div(
          "This is a mock-up of the Stations page redesign. The data in this app is not real, please do not panic when it doesn't seem to make sense. As you test this out, please makes notes of changes and functionalities you'd like for us to consider and include in the final deployement."
        )
      )
    ),
    column(
      width = 4,
      box(
        width = NULL,
        tags$div(
          "PORTAL only displays data from active stations. If you're looking for data from a station that doesn't seem to exist anymore, please ",
          tags$a(href="https://trec-pdx.shinyapps.io/historic-stations-viz/",
                 "visit this page to search for historic stations."
          )
        )
      )
    ),
    column(
      width = 4,
      box(
        width = NULL,
        tags$div(
          "For now, please use the table to filter and search for the station(s) of interest. We will re-enable the clickable option at the final deployment."
        )
      )
    )
  ),
  
  #### Metadata table & Map ####
  fluidRow(
    column(
      width = 8,
      box(
        width = NULL,
        solidHeader = T,
        label = "Select Metadata",
        DTOutput("metadata_table")
      )
    ),
    column(
      width = 4,
      box(
        width = NULL,
        solidHeader = T,
        label = "Stations Map",
        leafletOutput("stations_map",
                      height = 600)
      )
    )
  ),
  
  #### Buttons: Clear, Downloads ####
  
  fluidRow(
    column(
      width = 4,
      box(
        width = NULL,
        solidHeader = F,
        actionButton("reset",
                   label = "Reset Selection"),
        actionButton("download_all_metadata",
                     label = "Download All Metadata"),
        actionButton("download_selected_metadata",
                     label = "Download Selected Metadata")
      )
    )
  ),
  
  #### Tab Panels ####
  fluidRow(
    tabBox(
      width = 12,
      height = NULL,
      
      #### Data availabilty/data gap ####
      tabPanel(
        "Data Availability - Mainline",
        fluidRow(
          column(
            width = 2,
            box(
              width = NULL,
              tags$div(
                "Data availabilty is based on 20 second granularity. Within a 24-hr period there should be 4,320 records per mainline lane. Gaps in data are due to a variety of reasons, and are not limited to, data feed outages, transmission of data from the detector, and issues with the hardware. PORTAL does not impute any missing data."
              )
            ),
            box(
              width = NULL,
              numericInput(
                "y_percent",
                label = "Set % Threshold",
                value = 90
              )
            ),
            box(
              width = NULL,
              selectizeInput(
                "year",
                label = "Year",
                choices = c(2019, 2020, 2021, 2022, 2023),
                selected = NULL
              )
            )
          ),
          column(
            width = 10,
            box(
              width = NULL,
              plotlyOutput(
                "data_gap_figure"
              )
            )
          )
        )
      ),
      
      #### 2 quantity chart ####
      tabPanel(
        "Two-Quantity Chart",
        fluidRow(
          column(
            width = 2,
            box(
              width = NULL,
              tags$div("This visualization is using fake data. Total volume will be available as a new metric (in addition to VPLPH and average volume). All the other quantity metrics are the same. Please note, ODOT ATR stations only have volume related data.
                       ")
            )
            
          )
        )
      )
    )
  )
  
)

dashboardPage(
  header,
  dashboardSidebar(disable = T),
  body
)
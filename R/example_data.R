library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)

its_detectors <- read.csv("data/its_2022_example_data.csv")
its_ramps <- read.csv("data/its_ramp_2022_example_data.csv")

its_detectors$starttime <- ymd_hms(its_detectors$starttime, tz = "US/Pacific")

its_stations <- its_detectors %>%
  mutate(stationid = case_when(detector_id %in% c(100374, 100375, 100376) ~ 1036,
                               detector_id %in% c(100367, 100368) ~ 1096,
                               .default = 0),
         lane_no = case_when(detector_id %in% c(100374, 100367) ~ 1,
                             detector_id %in% c(100375, 100368) ~ 2,
                             .default = 3)) %>%
  select(stationid,
         detectorid = detector_id,
         lane_no,
         starttime,
         volume,
         speed,
         occupancy)
saveRDS(its_stations, "data/its_stations_data.rds")

its_ramps$start_time <- ymd_hms(its_ramps$start_time, tz = "US/Pacific")
ramps_data <- its_ramps %>%
  select(detectorid = device_id,
         starttime = start_time,
         metered_lane_volume) %>%
  mutate(stationid = if_else(detectorid == 10034, 1096, 1036))
saveRDS(ramps_data, "data/its_ramps_data.rds")

starttime <- its_stations %>%
  distinct(starttime)
volume <- sample(1:2000, 8398, replace = T)
atr1 <- bind_cols(starttime, volume) %>%
  mutate(lane_no = 1,
         detectorid = 100)
colnames(atr1) <- c("starttime", "volume", "lane_no", "detectorid")

volume <- sample(1:2000, 8398, replace = T)
atr2 <- bind_cols(starttime, volume) %>%
  mutate(lane_no = 2,
         detectorid = 101)
colnames(atr2) <- c("starttime", "volume", "lane_no", "detectorid")

atr_data <- bind_rows(atr1, atr2) %>%
  mutate(stationid = 20245) %>%
  select(stationid,
         detectorid,
         lane_no,
         starttime,
         volume)
saveRDS(atr_data, "data/atr_data.rds")

atr_all_data <- atr_data %>%
  mutate(speed = as.numeric(""),
         occupancy = as.numeric(""))

example_stations_data <- bind_rows(its_stations, atr_all_data)
saveRDS(example_stations_data, "data/example_stations_data.rds")

testplot <- example_stations_data %>%
  ggplot(aes(x = starttime)) +
  geom_line(aes(y = speed), color = "yellow4", linewidth = 1) +
  geom_col(aes(y = volume / 10), fill = "deepskyblue4") +
  facet_grid(stationid ~ lane_no, scales = "free") +
  scale_y_continuous(
    name = "Speed",
    breaks = 0:2 * 100,
    sec.axis = sec_axis(~.x,
                        name = "Volume",
                        labels = function(z) {
                          paste0(z*10)
                        }
                        )
  )
testplot

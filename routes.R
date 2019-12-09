# run stop_frequency.R first when updated data is received

rm(list=ls())

library(tidytransit)
library(tidyverse)
library(sf)

setwd("G:/_Projects/Connect_GTFS/")

ct <- read_gtfs("data/7.1.19.zip",local=TRUE)
routes_sf <- get_route_geometry(ct) %>%
  left_join(ct$routes[c(1,4,6)]) %>%
  st_transform(102271) %>%
  write_sf("output/ct_routes.shp")

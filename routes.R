# run stop_frequency.R first when updated data is received
library(sf)
library(tidytransit)
library(tidyverse)
library(here)

ct <- read_gtfs("data/2020-06-15_Connect-GTFS.zip")
ct_sf <- gtfs_as_sf(ct)

routes_sf <- get_route_geometry(ct_sf) %>%
  left_join(ct$routes) %>%
  select(route_id, route_long_name, route_color) %>%
  st_transform(3443) %>%
  write_sf("output/ct_routes.shp")


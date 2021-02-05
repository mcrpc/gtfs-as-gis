# run stop_frequency.R before this when updated data is received
# 2021-02-05 note: I don't know if that applies any more. stop_frequency seems
# a bit overly complex for a simple update to our GIS data.
# check out the GTFS script in the housing-location-tool for what is possibly
# a better version
library(sf)
library(tidytransit)
library(tidyverse)
library(here)

ct <- read_gtfs("data/2020-06-15_Connect-GTFS.zip") # make sure to change to current GTFS
ct_sf <- gtfs_as_sf(ct)

routes_sf <- get_route_geometry(ct_sf) %>%
  left_join(ct$routes) %>%
  select(route_id, route_long_name, route_color) %>%
  st_transform(3443) %>% # change this if a different CRS is desired. if you don't know what a CRS is, leave alone
  write_sf("output/ct_routes.shp")


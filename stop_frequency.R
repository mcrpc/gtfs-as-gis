#install.packages(c("knitr","tidyverse","pryr","dplyr","ggplot2","plotly"))
library(knitr)
library(tidyverse)
library(pryr)
library(dplyr)
library(here)

zip <- here("data/2020-06-15_Connect-GTFS.zip")
#zip <- file.choose()
outDir <- substring(zip, 1, nchar(zip)-4)

if (file.exists(outDir)){
  setwd(outDir)
} else {
  dir.create(outDir)
  setwd(outDir)
}

unzip(zip, exdir = outDir)

trips <- read_csv("trips.txt")
stops <- read_csv("stops.txt")
shapes <- read_csv("shapes.txt")
routes <- read_csv("routes.txt")
stop_times <- read_csv("stop_times.txt", col_types= cols(arrival_time = col_character(), departure_time = col_character()))
# read_csv(path, col_types by column to force the columns to be in a given format)


# the following three lines are just for viewing the tables
kable(head(trips))
kable(head(routes))
kable(head(stop_times))


# the following lines will join those three tables
stop_times <- stop_times %>% 
  left_join(trips) %>% 
  left_join(routes) %>% 
  select(route_id, route_long_name, trip_id, stop_id, service_id, arrival_time, departure_time, direction_id, shape_id, stop_sequence)

kable(head(stop_times))

# get the stop direction with the greatest frequency to avoid double-counting end stops (inbound trip and outbound trip both get counted)
stop_directions <- count(stop_times, wt = NULL, sort = TRUE, name = 'n', stop_id, direction_id)
best_direction <- aggregate(direction_id~stop_id, data = stop_directions, unique)
best_direction[['direction_id']] <- as.numeric(lapply(best_direction[['direction_id']], '[[', 1))
stop_times <- semi_join(stop_times, best_direction)


# test <- cbind(test,lengths(test[[direction_id]]))
# colnames(test) <- c("stop_id","direction_ids","direction_num")
# test2 <- left_join(stop_times, test)

# test3 <- test2 %>%
#   group_by(stop_id) %>%
#   count(direction_num)
# 
# stop_times %>%
#   group_by(stop_id, service_id) %>%
#   count(stop_id) %>%
#   head()
# visualize the new, joined table

#Santiago Toso selects only the service with the most trips:

# bigger_service <- trips %>% 
#   group_by(service_id) %>% 
#   count(service_id) %>%
#   arrange(desc(n)) %>% 
#   head(1)
# 
# bigger_service

# CT only has 3 service ids, 1 = weekday, 2 = saturday, 3 = sunday, and we are looking for frequency by week, so there should be no need to filter

# actually, since his code is looking for trips per hour, and we want frequency by week, we should only need to relate the number of unique trips by route

# so here's how to just get the number of trips per week
stop_freq <- count(stop_times,name = 'freq',stop_id,service_id)
stop_freq[stop_freq$service_id==1,][['freq']] <- stop_freq[stop_freq$service_id==1,][['freq']] * 5
stop_freq <- aggregate(freq~stop_id, data = stop_freq, sum)


# we can also do this by route
# route_freq <- table(subset(stop_times, service_id == 1)$route_id)*5
# route_freq <- route_freq + table(subset(stop_times, service_id == 2)$route_id)
# route_freq <- route_freq + table(subset(stop_times, service_id == 3)$route_id)
# however, this can be a bit misleading as some routes have segments which are express portions, which add additional trips for specific parts of the line

# let's take stop_freq and turn it into a GIS file
# we'll need a few libraries
library(maptools)
library(rgdal)
library(sf)

stops <- left_join(stops, stop_freq)

# attach route information to stops
cols <- unique(cbind(stop_times[2],stop_times[4]))
joinData <- aggregate(route_long_name~stop_id, data = cols, paste, collapse = ",")
stops <- left_join(stops, joinData)
# stop_ids 1892303 (Uptown Station) and 2026561 (Market & Oak) have duplicate entries in the 1 July 2019 GTFS feed stops.txt for some reason
# (and it is very likely that future GTFS files will have duplicate stops because Connect Transit is sloppy like that)
stops <- distinct(stops, stop_id, .keep_all = TRUE)

stops_sf <- st_as_sf(stops,crs=4326,coords=c("stop_lon","stop_lat")) %>%
  st_transform(3443) %>% # change this if a different CRS is desired. if you don't know what a CRS is, leave alone
  write_sf(here("output/ct_stops.shp"))

spdf <- SpatialPointsDataFrame(coords = c(stops[4],stops[3]), data = stops, proj4string = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
writeOGR(spdf, dsn=here("output"), layer="CT_StopFreq_1JUL19",driver="ESRI Shapefile")

# mapbox isochrones of stops
# library(leaflet)
# library(mapboxapi)
# 
# walk_5min <- mb_isochrone(stops_sf,
#                           profile = "walking",
#                           time = 5)
# 
# leaflet(walk_5min) %>%
#   addMapboxTiles(style_id = "streets-v11",
#                  username = "mapbox") %>%
#   addPolygons()
# 
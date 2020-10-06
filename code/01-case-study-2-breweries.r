### -----------------------------------------------
### Case Study: Mapping Breweries in Germany
### Simon Munzert
### -----------------------------------------------


##  goal

# 1. get list of breweries in Germany
# 2. import list in R
# 3. geolocate breweries
# 4. put them on a map


## load packages

library(tidyverse)
library(rvest)
library(stringr)
# devtools::install_github("hrbrmstr/nominatim")
library(nominatim)
library(sf)
library(rnaturalearth)

## inspect the source code in your browser ---------------

browseURL("http://www.biermap24.de/brauereiliste.php") 



## step 1: fetch list of cities with breweries
url <- "http://www.biermap24.de/brauereiliste.php"
content <- read_html(url)
anchors <- html_nodes(content, xpath = "//tr/td[2]")
cities <- html_text(anchors)
cities
cities <- str_trim(cities)
cities <- cities[str_detect(cities, "^[[:upper:]]+.")]
cities <- cities[6:length(cities)]
length(cities)
length(unique(cities))
sort(table(cities))
unique_cities <- unique(cities)

## step 2: geocode cities
# get free key for mapquest API at browseURL("https://developer.mapquest.com/")
#load("/Users/s.munzert/rkeys.RDa") # import API key (or paste it here in openstreetmap object)

pos <- data.frame(lon = NA, lat = NA)
if (!file.exists("geocodes_breweries.RData")){
  for (i in 1:length(unique_cities)) {
    pos[i,] <- try(nominatim::osm_search(unique_cities[i], country_codes = "de", key = openstreetmap) %>% dplyr::select(lon, lat))
  }
  pos$city <- unique_cities
  pos <- filter(pos, !str_detect(lon, "Error"))
  pos$lon <- as.numeric(pos$lon)
  pos$lat <- as.numeric(pos$lat)
  save(pos, file="geocodes_breweriers.RData")
} else {
  load("geocodes_breweries.RData")
}
head(pos)


## step 3: plot breweries of Germany
pos <- filter(pos, lon >= 6, lon <= 15, lat >= 47, lat <= 55)
worldmap <- rnaturalearth::ne_countries(scale = 'medium', type = 'map_units', returnclass = 'sf')
germany <- worldmap[worldmap$name == 'Germany',]
ggplot() + geom_sf(data = germany) + theme_bw() + geom_point(aes(lon,lat), data = pos, size = .5, color = "red") 


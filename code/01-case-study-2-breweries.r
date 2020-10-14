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
anchors <- html_nodes(content, xpath = "//tr/td[3]")
cities <- html_text(anchors)
cities
cities <- str_trim(cities)
length(cities)
length(unique(cities))
sort(table(cities))
unique_cities <- unique(cities)

## step 2: geocode cities
# get free key for mapquest API at browseURL("https://developer.mapquest.com/")
#load("/Users/simonmunzert/rkeys.RDa") # import API key (or paste it here in openstreetmap object)

n_cities <- length(unique_cities)
coords_df <- data.frame(city = rep(NA, n_cities), lon = rep(NA, n_cities), lat = rep(NA, n_cities), stringsAsFactors = FALSE)
if (!file.exists("coords_breweries.RData")){
  for (i in 1:n_cities) {
    coords <- try(nominatim::osm_search(unique_cities[i], country_codes = "de", key = openstreetmap))
   coords_df$city[i] <- unique_cities[i]
   if(nrow(coords) > 0) {
   coords_df$lon[i] <- as.numeric(coords$lon)
   coords_df$lat[i] <- as.numeric(coords$lat)
   }else{
     coords_df$lon[i] <- NA
     coords_df$lat[i] <- NA
   }
  }
  save(coords_df, file="coords_breweries.RData")
} else {
  load("coords_breweries.RData")
}
head(coords_df)


## step 3: plot breweries of Germany
pos <- filter(coords_df, lon >= 6, lon <= 15, lat >= 47, lat <= 55)
worldmap <- rnaturalearth::ne_countries(scale = 'medium', type = 'map_units', returnclass = 'sf')
germany <- worldmap[worldmap$name == 'Germany',]
ggplot() + geom_sf(data = germany) + theme_bw() + geom_point(aes(lon,lat), data = pos, size = .5, color = "red") 


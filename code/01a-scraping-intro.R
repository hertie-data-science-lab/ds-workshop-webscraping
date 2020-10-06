### -----------------------------
## simon munzert
## web scraping
### -----------------------------

## load packages -----------------
library(rvest)
library(stringr)
library(maps)

# parse URL
parsed_url <- read_html("https://en.wikipedia.org/wiki/Berlin")

# extract data
parsed_nodes <- html_nodes(parsed_url, xpath = "//div[contains(@class, 'div-col columns column-width')]//li")
cities <- html_text(parsed_nodes)
cities

# subset data
cities <- str_subset(cities, ":", negate = TRUE) # only select strings that do not contain the colon (":")
cities

# tidy data
cities <- str_replace(cities, "\\[\\d+\\]", "") # remove the footnote symbols
cities

# extract variables
year <- str_extract(cities, "\\d{4}")
city <- str_extract(cities, "[[:alpha:] ]+") %>% str_trim
country <- str_extract(cities, "[[:alpha:] ]+$") %>% str_trim
year[1:10]
city[1:10]
country[1:10]

# make data frame
cities_df <- data.frame(year, city, country)
head(cities_df)

# geocode observations with nominatim package
# if you want to replicate the geocoding, uncomment the following lines of code and run it after retrieving the API key, storing, and loading it
# devtools::install_github("hrbrmstr/nominatim") # not on CRAN, so install from GitHub
# library(nominatim)
# # get free API key at browseURL("https://developer.mapquest.com/")
# load("/Users/simonmunzert/rkeys.RDa") # load key from local file; you have to create your own file or paste your key into an object named 'openstreetmap'
# cities_to_geocode <- paste0(cities_df$city, ", ", cities_df$country)
# lats_longs <- osm_geocode(cities_to_geocode, key = openstreetmap)
# save(lats_longs, file = "cities_lat_longs.RData")

load("cities_lat_longs.RData")
lats_longs[c("lat", "lon")]

# map observations
map_world <- borders("world", colour = "gray50", fill = "white") 
ggplot() + map_world + geom_point(aes(x = lats_longs$lon, y = lats_longs$lat), color = "red", size = 1) + theme_void()

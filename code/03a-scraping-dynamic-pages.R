### -----------------------------
### simon munzert
### scraping dynamic webpages
### -----------------------------

## peparations -------------------

library(tidyverse)
library(rvest)
library(RSelenium)


## setup R + RSelenium -------------------------

# install current version of Java SE Runtime Environment
browseURL("https://duckduckgo.com/?q=java+download&va=z&t=hk&ia=web")

# set up connection via RSelenium package
# documentation: http://cran.r-project.org/web/packages/RSelenium/RSelenium.pdf



## example --------------------------

# initiate Selenium driver
rD <- rsDriver(browser = "chrome") 
rD <- rsDriver(browser = "firefox") # if chrome is causing some issues on your system, try (a) using the current beta, which you then have to install first, or (b) another browser, such as firefox

# set up connection
remDr <- rD[["client"]]

# start browser, navigate to page
url <- "https://www.iea.org/policies"
remDr$navigate(url)

# open filter menu
xpath <- '//*[@id="content"]/div[2]/nav/div/div/div/div/button'
findElem <- remDr$findElement(using = 'xpath', value = xpath)
findElem$clickElement() # click on button

# open region menu
xpath <- '//*[@id="accordion-filter-region"]'
findElem <- remDr$findElement(using = 'xpath', value = xpath)
findElem$clickElement() # click on button

# select Europe
xpath <- '//*[@id="content"]/div[2]/div[1]/div/ul/li[2]/div/div/ul/li[1]/a/span[2]'
findElem <- remDr$findElement(using = 'xpath', value = xpath)
findElem$clickElement() # click on button

# specify text field
xpath <- '//*[@id="input-qs"]'
textfield <- remDr$findElement(using = 'xpath', value = xpath) 
textfield$clickElement() # click on text field
textfield$sendKeysToElement(list("battery", key = "enter")) # enter start year

# close filter menu
xpath <- '//*[@id="content"]/div[2]/div[1]/div/div/button'
findElem <- remDr$findElement(using = 'xpath', value = xpath) 
findElem$clickElement() 

# store index page
output <- remDr$getPageSource(header = TRUE)
write(output[[1]], file = "iea-renewables-1.html")

# close connection
remDr$closeServer()

# parse data
content <- read_html("iea-renewables-1.html", encoding = "utf8") 
policies <- html_nodes(content, xpath = '//*[@id="content"]/div[2]/div[2]/div[1]/ul//li') %>% html_text()

policies_list <- map(policies, 
    function(x) {x %>% 
        str_replace_all("  ", "") %>% 
        str_split("(\\n)+") %>% 
        unlist() %>%  
        t() %>% 
        as.data.frame(stringsAsFactors = FALSE)})
policies_df <- bind_rows(policies_list)
policies_df$V1 <- NULL
policies_df$V7 <- NULL
names(policies_df) <- c("policy", "country", "year", "status", "jurisdiction")

head(policies_df)


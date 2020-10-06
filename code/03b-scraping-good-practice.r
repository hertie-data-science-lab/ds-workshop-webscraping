### -----------------------------
### simon munzert
### good practice
### -----------------------------

## peparations -------------------

library(tidyverse)
library(rvest)
library(httr)
library(polite)


## Staying friendly on the web, step by step ------

# work with informative header fields
# don't bombard server
# respect robots.txt

# add User-Agent string
url <- "https://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_article/May_2020"
browseURL("http://www.whoishostingthis.com/tools/user-agent/")
uastring <- "Mozilla/5.0 (X11; Ubuntu; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36 RuxitSynthetic/1.0 v5270611774 t38550"
session <- html_session(url, user_agent(uastring))

# add header fields with rvest + httr
session <- html_session(url, add_headers(From = "my@email.com", `User-Agent` = "R Scraper"))
articles <- session %>% 
  html_nodes(xpath = "//p//b/a[1]") %>% 
  html_attr("href") %>% 
  str_subset("Wikipedia", negate = TRUE) %>%
  unique()

# build full URLs
urls <- paste0("https://en.wikipedia.org", articles)

# don't bombard server
path <- "data/wiki_articles"
dir.create(path, recursive = TRUE)
for (i in 1:length(urls)) {
  if (!file.exists(paste0(path, "/", basename(urls[i]), ".html"))) {
    download.file(urls[i], destfile = paste0(path, "/", basename(urls[i]), ".html"))
    Sys.sleep(runif(1, 0, 1))
  }
}



## Staying friendly on the web using the {polite} package  ------

# example due to
browseURL("https://dmi3kno.github.io/polite/")
# (also check out for an extended example)
  
# set user agent and crawl delay
session <- bow("https://www.cheese.com/by_type", force = TRUE)

# scrape URL (add parameters to call via query argument)
result <- scrape(session, query=list(t="semi-soft", per_page=100)) %>%
  html_node("#main-body") %>%
  html_nodes("h3") %>%
  html_text()
head(result)



## Respect robots.txt  ------

# examples
browseURL("https://www.google.com/robots.txt")
browseURL("http://www.nytimes.com/robots.txt")

library(robotstxt)
# more info see here: https://cran.r-project.org/web/packages/robotstxt/vignettes/using_robotstxt.html

paths_allowed("/", "http://google.com/", bot = "*")
paths_allowed("/", "https://facebook.com/", bot = "*")

paths_allowed("/imgres", "http://google.com/", bot = "*")
paths_allowed("/imgres", "http://google.com/", bot = "Twitterbot")


r_text <- get_robotstxt("https://www.google.com/")
r_parsed <- parse_robotstxt(r_text)
names(r_parsed)
table(r_parsed$permissions$useragent, r_parsed$permissions$field)



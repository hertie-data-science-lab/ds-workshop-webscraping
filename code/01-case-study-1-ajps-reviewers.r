### -----------------------------
### ajps reviewers
### simon munzert
### -----------------------------

## goals ------------------------

  # fetch list of AJPS reviewers from PDFs
  # parse them into a clean data frame


## tasks ------------------------

  # downloading PDF files
  # importing them into R (as plain text)
  # extract information via regex


## packages ---------------------

library(tidyverse)
library(rvest)
library(pdftools)
# devtools::install_github("hrbrmstr/nominatim")
library(nominatim)


## code ---------------------

## step 1: inspect page
url <- "http://ajps.org/list-of-reviewers/"
browseURL(url)


## step 2: retrieve pdfs
# get page
content <- read_html(url)
 # get anchor (<a href=...>) nodes via xpath
anchors <- html_nodes(content, xpath = "//a")
# get value of anchors' href attribute
hrefs <- html_attr(anchors, "href")

# filter links to pdfs
pdfs <- hrefs[ str_detect(basename(hrefs), ".*\\d{4}.*pdf") ]
pdfs

# define names for pdfs on disk
pdf_names <- str_extract(basename(pdfs), "\\d{4}") %>% paste0("reviewers", ., ".pdf")
pdf_names

# download pdfs
dir.create("ajps-reviewers")
for(i in seq_along(pdfs)) {
  download.file(pdfs[i], paste0("ajps-reviewers/", pdf_names[i]), mode="wb")
}


## step 3: import pdf
rev_raw <- pdftools::pdf_text("ajps-reviewers/reviewers2015.pdf")
class(rev_raw)
rev_raw[1]


## step 4: tidy data
rev_all <- rev_raw %>% str_split("\\n") %>% unlist 
surname <- str_extract(rev_all, "[[:alpha:]-]+")
prename <- str_extract(rev_all, " [.[:alpha:]]+")
rev_df <- data.frame(raw = rev_all, surname = surname, prename = prename, stringsAsFactors = F)
rev_df$institution <- NA
  for(i in 1:nrow(rev_df)) {
    rev_df$institution[i] <- rev_df$raw[i] %>% str_replace(rev_df$surname[i], "") %>% str_replace(rev_df$prename[i], "") %>% str_trim()
  }
rev_df <- rev_df[-c(1,2),]
rev_df <- rev_df[!is.na(rev_df$surname),]
head(rev_df)



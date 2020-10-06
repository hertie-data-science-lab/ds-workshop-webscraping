### -----------------------------
### simon munzert
### tapping wikipedia
### -----------------------------


## peparations -------------------

source("packages.r")


## on Wikipedia APIs ---------------------------------

# Media Wiki API
# use case: rich queries, editing and content access.
browseURL("https://www.mediawiki.org/wiki/API:Main_page")

# MediaWiki REST API
# use case: high-volume content access.
browseURL("https://www.mediawiki.org/api/rest_v1/")


## primer to the WikipediR package ----------------------------

# The WikipediR package
browseURL("https://cran.r-project.org/web/packages/WikipediR/vignettes/WikipediR.html")

# functionality
ls("package:WikipediR")

# get page content
content <- page_content("de", "wikipedia", page_name = "Brandenburger_Tor", as_wikitext = TRUE)
str(content)
content$parse$wikitext %>% unlist %>% cat

# get page links (careful: max 500 links)
links <- page_links("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500, namespaces = 0)
lapply(links[[1]]$links, "[", 2) %>% unlist

# get page backlinks (links referring to a given web resource; careful: max 500 backlinks)
backlinks <- page_backlinks("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500, namespaces = 0)
unlist(backlinks) %>%  .[names(.) == "title"] %>% as.character

# get external links
extlinks <- page_external_links("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE, limit = 500)
extlinks[[1]]$extlinks

# metadata on article
metadata <- page_info("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE) 
metadata[[1]] %>% t() %>% as.data.frame

# which categories in page
cats <- categories_in_page("de","wikipedia", page = "Brandenburger_Tor", clean_response = TRUE)
cats[[1]]$categories




### example: build a network of German MPs -----------------

## goals
# gather list of German MPs
# fetch Wikipedia entries
# identify links
# construct connectivity matrix
# visualize network

## step 1: get info about legislators
# potential source:
browseURL("https://de.wikipedia.org/wiki/Liste_der_Mitglieder_des_Deutschen_Bundestages_(18._Wahlperiode)")

# better: use legislatoR!
browseURL("https://github.com/saschagobel/legislatoR")
library(legislatoR)
dat <- semi_join(x = get_core(legislature = "deu"),
                                    y = filter(get_political(legislature = "deu"), session == 19), 
                                    by = "pageid")
dat$wikititle

## step 2: get page links (max 500 links)
if(!file.exists("../data/wikipediR/mdb_links_list.RData")){
links_list <- list()
for(i in 1:nrow(dat)) {
  links <- page_links("de","wikipedia", page = dat$wikititle[i], clean_response = TRUE, limit = 500, namespaces = 0)
  links_list[[i]] <- lapply(links[[1]]$links, "[", 2) %>% unlist
}
save(links_list, file = "../data/wikipediR/mdb_links_list.RData")
}else{
load("../data/wikipediR/mdb_links_list.RData")
}

## step 3: identify links between MPs
# loop preparation
connections <- data.frame(from=NULL, to=NULL)
# loop
for (i in seq_along(dat$wikititle)) {
  links_in_pslinks <- seq_along(dat$wikititle)[str_replace_all(dat$wikititle, "_", " ") %in% links_list[[i]]]
  links_in_pslinks <- links_in_pslinks[links_in_pslinks != i]
  connections <- rbind(
    connections,
    data.frame(
      from=rep(i-1, length(links_in_pslinks)), # -1 for zero-indexing
      to=links_in_pslinks-1 # here too
    )
  )
}

# results
names(connections) <- c("from", "to")
head(connections)

# make symmetrical
connections <- rbind(
  connections,
  data.frame(from=connections$to,
             to=connections$from)
)
connections <- connections[!duplicated(connections),]


## step 4: visualize connections
connections$value <- 1
nodesDF <- data.frame(name = dat$name, group = 1)

network_out <- forceNetwork(Links = connections, Nodes = nodesDF, Source = "from", Target = "to", Value = "value", NodeID = "name", Group = "group", zoom = TRUE, opacityNoHover = 3)

saveNetwork(network_out, file = '../data/connections.html')
browseURL("../data/connections.html")


## step 5: identify top nodes in data frame
nodesDF$id <- as.numeric(rownames(nodesDF)) - 1
connections_df <- merge(connections, nodesDF, by.x = "to", by.y = "id", all = TRUE)
to_count_df <- count(connections_df, name)
arrange(to_count_df, desc(n))

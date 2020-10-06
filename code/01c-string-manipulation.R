### -----------------------------
## simon munzert
## web scraping
### -----------------------------


## load packages -----------------

library(stringr)


## string manipulation ----------

example.obj <- "1. A small sentence. - 2. Another tiny sentence."
example.obj

# locate
str_locate(example.obj, "tiny")

# substring extraction
str_sub(example.obj, start = 35, end = 38)

# replacement
str_sub(example.obj, 35, 38) <- "huge"
str_replace(example.obj, pattern = "huge", replacement = "giant")

# splitting
str_split(example.obj, "-") %>% unlist

# manipulate multiple elements; example
(char.vec <- c("this", "and this", "and that"))

# detection
str_detect(char.vec, "this")

# keep strings matching a pattern
str_subset(char.vec, "this") # wrapper around x[str_detect(x, pattern)]

# counting
str_count(char.vec, "this")
str_count(char.vec, "\\w+")
str_length(char.vec)

# duplication
str_dup(char.vec, 3)

# padding and trimming
length.char.vec <- str_length(char.vec)
char.vec <- str_pad(char.vec, width = max(length.char.vec), side = "both", pad = " ")
char.vec
str_trim(char.vec)

# joining
str_c("text", "manipulation", sep = " ")
str_c(char.vec, collapse = "\n") %>% cat
str_c("text", c("manipulation", "basics"), sep = " ")

# approximate matching
agrepl("Donald Trump", "Donald Drumpf", max.distance = list(all = 3))
agrepl("Donald Trump", "Barack Obama", max.distance = list(all = 3))



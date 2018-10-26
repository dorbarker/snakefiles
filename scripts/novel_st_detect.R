library(tidyverse)
library(magrittr)

binarize <- function(column) {

    binary <-
        column %>%
        gsub(pattern = '^\\d+$', replacement = 1) %>%
        gsub(pattern = '^~\\d+$', replacement = -1)

    zeros <-
        binary %>%
        is_in(c('-1', '1')) %>%
        not

    binary[zeros] <- '0'

    binary %>%
        as.integer
}

calls <- read_tsv(snakemake@[[1]], col_types = 'cccccccccc')

binarized_calls <-
    calls %>%
    map(binarize) %>%
    as_tibble %>%
    select(-c(FILE, SCHEME, ST))

contains_novel <-
    binarized_calls %>%
    mutate(
        s = rowSums(.),
        abs_s = rowSums(abs(.)),
        strain = calls$FILE
    ) %>%
    filter(s < abs_s) %>%
    select(strain, everything(), -c(s, abs_s))


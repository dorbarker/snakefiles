library(reshape2)
library(getopt)

calc_melted_dm <- function(infile, outfile, delimiter) {

    distance_matrix <- read.table(infile,
                                  sep = delimiter,
                                  header = TRUE,
                                  row.names = 1)

    distance <- as.dist(as.matrix(distance_matrix))

    melted <- melt(as.matrix(distance))

    melted$dedup <- apply(melted, 1, function(x) {
            paste(sort(x[1:2]), collapse = "_")
        })

    melted <- melted[!duplicated(melted$dedup), c('Var1', 'Var2', 'value')]

    colnames(melted) <- c('genome1', 'genome2', 'distance')

    write.table(melted,
                file = outfile,
                sep = delimiter,
                quote = FALSE,
                row.names = FALSE)
}

calc_melted_dm(snakemake@input[[1]], snakemake@output[[1]], delimiter = ',')

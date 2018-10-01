library(ape)
library(reshape2)
library(getopt)
library(stringr)

arguments <- function() {

    spec <- matrix(c(
        'help',      'h', 0, 'logical',
        'calls',     'i', 1, 'character',
        'delimiter', 'd', 1, 'character'
    ), byrow = TRUE, ncol = 4)

    opt <- getopt(spec)

    if (!is.null(opt$help)) {
        cat(getopt(spec, usage = TRUE))
        quit(status = 0)
    }

    if (is.null(opt$calls)) {
        cat("Must provide table of calls\n")
        quit(status = 1)
    }

    if (is.null(opt$delimiter)) {
        opt$delimiter <- '\t'
    }

    opt
}

get_outname <- function(calls_file) {
    path_parts <- str_split(calls_file, '/')[[1]]

    root <- path_parts[1:(length(path_parts)-1)]

    basename_ext <- str_split(path_parts[length(path_parts)], '\\.')[[1]]

    basename <- basename_ext[1]

    ext <- basename_ext[2]

    out_basename <- paste0(basename, '_melted.', ext)

    outpath <- paste(paste(root, collapse = '/'), out_basename, sep = '/')

    outpath
}

process <- function(calls_file, delimiter) {

    calls <- read.table(calls_file,
                        sep = delimiter,
                        header = TRUE,
                        row.names = 1)

    calls[] <- lapply(calls, function(x) {x[x < 1] <- NA; x})

    distance <- dist.gene(calls, pairwise.deletion = TRUE)

    melted <- melt(as.matrix(distance))

    melted$dedup <- apply(melted, 1, function(x) {
            paste(sort(x[1:2]), collapse = "_")
        })

    melted <- melted[!duplicated(melted$dedup), c('Var1', 'Var2', 'value')]

    colnames(melted) <- c('genome1', 'genome2', 'distance')

    write.table(melted,
                file = get_outname(calls_file),
                sep = delimiter,
                quote = FALSE,
                row.names = FALSE)
}

main <- function() {

    args <- arguments()

    process(args$calls, args$delimiter)

}

main()

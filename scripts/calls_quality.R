library(getopt)

arguments <- function() {

    spec <- matrix(c(
        'help',   'h', 0, 'logical',   'Print this help and exit',
        'input',  'i', 1, 'character', 'Path to allelic calls',
        'output', 'o', 1, 'character', 'Output file path'
    ), byrow = TRUE, ncol = 5)

    opt <- getopt(spec)

    if (!is.null(opt$help)) {
        cat(getopt(spec, usage = TRUE))
        quit(status = 0)
    }

    if (is.null(opt$input)) {
        cat('Input is required\n')
        quit(status = 1)
    }

    if (is.null(opt$output)) {
        cat('Output is required\n')
        quit(status = 1)
    }

    opt
}

main <- function() {

    args <- arguments()

    calls <- read.csv(args$input, row.names = 1)

    truncations <- apply(calls, 1, function(x) sum(x == -1))

    absent <- apply(calls, 1, function(x) sum(x == 0))

    good <- apply(calls, 1, function(x) sum(x >= 1))

    result <- data.frame('truncations' = truncations,
                         'absent'      = absent,
                         'good'        = good,
                         row.names = row.names(calls))

    write.csv(result, file = args$output, quote = FALSE, row.names = TRUE)
}

main()

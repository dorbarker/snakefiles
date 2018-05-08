library(ggplot2)
library(tibble)

missing_data_plot <- function(calls_path, output_path) {

    count_missing <- function(calls, target) {
        apply(calls, 1, function(row) sum(row == target))
    }
    calls <- read.csv(calls_path, row.names = 1)

    missing <- tibble('Truncations' = count_missing(calls, -1),
                      'Absences' = count_missing(calls, 0),
                      'Total' = Truncations + Absences)

    ggplot(missing, aes(Total)) +
        geom_histogram(binwidth = 1) +
        scale_y_log10()

    ggsave(output_path, width = 10, height = 10, units = 'cm')
}

missing_data_plot(snakemake@input[[1]], snakemake@output[[1]])

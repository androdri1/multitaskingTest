################################################################################
# Replication package: Testing for Economies of Scope through an Established P4P Programme
# Script: 11_plot_markov_matrix.R
# Language: R
# Paper output: Appendix Figure B1 / label fig:persistence.
# Purpose: Plot the 2009-2010 achievement transition heat map used in the appendix.
# Main input:
#   - data/derived/QOFind0910Markov.csv, created by 08_analysis_bunching_and_results.do
# Main outputs:
#   - output/figures/MarkovMatrixcol.png              [file imported by appendix.tex]
#   - output/figures/markov_transition_hexbin.pdf     [replication copy]
#   - output/figures/markov_transition_bin2d.pdf      [replication copy]
# Run order: after 08_analysis_bunching_and_results.do.
################################################################################

suppressPackageStartupMessages({
  library(readr)
  library(ggplot2)
  library(hexbin)
})

# ------------------------------------------------------------------------------
# Locate replication package root as: script directory / ..
# ------------------------------------------------------------------------------
get_script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    return(normalizePath(sub("^--file=", "", file_arg[1]), mustWork = TRUE))
  }

  frame_files <- vapply(sys.frames(), function(x) {
    if (!is.null(x$ofile)) x$ofile else NA_character_
  }, character(1))
  frame_files <- frame_files[!is.na(frame_files)]
  if (length(frame_files) > 0) {
    return(normalizePath(frame_files[length(frame_files)], mustWork = TRUE))
  }

  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    path <- rstudioapi::getSourceEditorContext()$path
    if (!is.null(path) && nzchar(path)) {
      return(normalizePath(path, mustWork = TRUE))
    }
  }

  stop(
    "Could not determine the script path. Run with Rscript scripts/11_plot_markov_matrix.R ",
    "or source() the script from an existing file.",
    call. = FALSE
  )
}

script_path <- get_script_path()
script_dir <- dirname(script_path)
root <- normalizePath(file.path(script_dir, ".."), mustWork = TRUE)

if (!dir.exists(file.path(root, "data")) || !dir.exists(file.path(root, "output"))) {
  stop("Could not locate Rep_folder root from script_dir/..: ", root, call. = FALSE)
}

input_file <- file.path(root, "data", "derived", "QOFind0910Markov.csv")
fig_dir <- file.path(root, "output", "figures")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(input_file)) {
  stop(
    "Input file not found: ", input_file,
    "\nRun 08_analysis_bunching_and_results.do first, or place QOFind0910Markov.csv in data/derived/.",
    call. = FALSE
  )
}

QOFind0910Markov <- read_csv(input_file, show_col_types = FALSE)
# Stata may export names with different case; normalise the expected variables.
lookup_name <- function(df, target) {
  nm <- names(df)
  hit <- nm[tolower(nm) == tolower(target)]
  if (length(hit) == 0) stop(paste("Variable not found:", target), call. = FALSE)
  hit[1]
}

ach2009 <- lookup_name(QOFind0910Markov, "achR2009")
ach2010 <- lookup_name(QOFind0910Markov, "achR2010")

# The legacy script used achRbound2009/2010. If they are absent, recreate them.
# Bounds keep the heat map focused on the neighbourhood around the upper threshold.
if (!any(tolower(names(QOFind0910Markov)) == "achrbound2009")) {
  QOFind0910Markov$achRbound2009 <- pmax(pmin(QOFind0910Markov[[ach2009]], 10), -10)
} else {
  names(QOFind0910Markov)[tolower(names(QOFind0910Markov)) == "achrbound2009"] <- "achRbound2009"
}
if (!any(tolower(names(QOFind0910Markov)) == "achrbound2010")) {
  QOFind0910Markov$achRbound2010 <- pmax(pmin(QOFind0910Markov[[ach2010]], 10), -10)
} else {
  names(QOFind0910Markov)[tolower(names(QOFind0910Markov)) == "achrbound2010"] <- "achRbound2010"
}

cols <- colorRampPalette(c("darkorchid4", "darkblue", "green", "yellow", "red"))

pdf(file.path(fig_dir, "markov_transition_hexbin.pdf"), width = 7, height = 6)
hexbinplot(
  as.formula(paste(ach2010, "~", ach2009)),
  data = QOFind0910Markov,
  trans = log,
  inv = exp,
  colramp = function(n) cols(24),
  xlab = "Relative to UL achievement in 2009",
  ylab = "Relative to UL achievement in 2010"
)
dev.off()

png(file.path(fig_dir, "MarkovMatrixcol.png"), width = 1200, height = 1000, res = 150)
hexbinplot(
  as.formula(paste(ach2010, "~", ach2009)),
  data = QOFind0910Markov,
  trans = log,
  inv = exp,
  colramp = function(n) cols(24),
  xlab = "Relative to UL achievement in 2009",
  ylab = "Relative to UL achievement in 2010"
)
dev.off()

plot_df <- data.frame(
  x = QOFind0910Markov$achRbound2009,
  y = QOFind0910Markov$achRbound2010
)

p <- ggplot(plot_df, aes(x, y)) +
  stat_bin2d(binwidth = 1, na.rm = TRUE) +
  scale_fill_gradientn(
    colours = cols(24),
    trans = "log10",
    breaks = c(100, 1000, 10000, 100000),
    labels = c("100", "1k", "10k", "100k")
  ) +
  labs(
    x = "Relative to UL achievement in 2009",
    y = "Relative to UL achievement in 2010",
    fill = "Count"
  ) +
  theme_minimal()

ggsave(file.path(fig_dir, "markov_transition_bin2d.pdf"), p, width = 7, height = 6)

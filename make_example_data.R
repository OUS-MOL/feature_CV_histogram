# ============================================================
# Generate a fully fictional example dataset for cv_histogram.R.
# Compound names and CV values are simulated with a fixed seed; no real data
# are used. Each file has three columns: compound, between-unit CV (%),
# within-unit CV (%).
#
# Usage:  Rscript make_example_data.R     # writes example_data/*.xlsx
# ============================================================

if (!requireNamespace("writexl", quietly = TRUE)) install.packages("writexl")

set.seed(2026)
dir.create("example_data", showWarnings = FALSE)

simulate_mode <- function(n, prefix, between_median, within_median) {
  sim_cv <- function(med) {
    cv <- rlnorm(n, meanlog = log(med), sdlog = 0.55)   # right-skewed, like real CVs
    round(pmin(pmax(cv, 0.5), 39.5), 2)                 # keep inside the 0-40 % plot range
  }
  data.frame(
    Compound = sprintf("%s %03d", prefix, seq_len(n)),
    `Between-unit CV (%)` = sim_cv(between_median),
    `Within-unit CV (%)`  = sim_cv(within_median),
    check.names = FALSE, stringsAsFactors = FALSE)
}

writexl::write_xlsx(simulate_mode(620, "Example compound (ESI+)", 9, 7),
                    "example_data/data_positive_example.xlsx")
writexl::write_xlsx(simulate_mode(480, "Example compound (ESI-)", 10, 7.5),
                    "example_data/data_negative_example.xlsx")
cat("Wrote example_data/data_positive_example.xlsx (620 compounds) and",
    "example_data/data_negative_example.xlsx (480 compounds)\n")

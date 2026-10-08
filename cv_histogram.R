# ============================================================
# Homogeneity assessment of a reference material: CV histograms
#
# A bulk reference material is mixed, pipetted into vials, and analysed by
# untargeted LC-MS in positive (ESI+) and negative (ESI-) ionization mode.
# For every compound (metabolite / lipid feature) two coefficients of
# variation are reported:
#   - Between-unit CV (%): variation between different vials of the material
#   - Within-unit  CV (%): variation within a vial (repeat injections)
# If the bulk was homogeneous, the between-unit CV distribution should be
# comparable to the within-unit one. This script bins the CVs in 5 % classes
# and plots the number of compounds per class (panel "A").
#
# Usage (from the repository root):
#   Rscript cv_histogram.R <data_positive.xlsx> <data_negative.xlsx> <output_prefix>
# Defaults: data/data_positive.xlsx, data/data_negative.xlsx, output/cv_histogram
# Writes <output_prefix>.pdf and <output_prefix>.png
#
# Input: one .xlsx per ionization mode, first sheet, exactly three columns in
# this order: compound name, between-unit CV (%), within-unit CV (%).
# Requires ggplot2 >= 3.5.0.
# ============================================================

library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)

# ---- 0. Input / output paths ------------------------------------------------
cli_args    <- commandArgs(trailingOnly = TRUE)
pos_path    <- if (length(cli_args) >= 1) cli_args[1] else "data/data_positive.xlsx"
neg_path    <- if (length(cli_args) >= 2) cli_args[2] else "data/data_negative.xlsx"
out_prefix  <- if (length(cli_args) >= 3) cli_args[3] else "output/cv_histogram"

# ---- 1. Load data -------------------------------------------------------------
data_pos <- read_excel(pos_path)
data_neg <- read_excel(neg_path)

colnames(data_pos) <- c("Compound", "Between_CV", "Within_CV")
colnames(data_neg) <- c("Compound", "Between_CV", "Within_CV")

# ---- 2. Reshape to long format -----------------------------------------------
prepare_df <- function(df, mode_label) {
  df %>%
    pivot_longer(cols = c("Between_CV", "Within_CV"),
                 names_to = "Type", values_to = "CV") %>%
    mutate(
      Group = case_when(
        Type == "Between_CV" ~ paste0("Between-unit CV (%), ", mode_label),
        Type == "Within_CV"  ~ paste0("Within-unit CV (%), ", mode_label)
      )
    )
}

df_all <- bind_rows(prepare_df(data_pos, "ESI+"), prepare_df(data_neg, "ESI-"))

group_levels <- c(
  "Between-unit CV (%), ESI+",
  "Within-unit CV (%), ESI+",
  "Between-unit CV (%), ESI-",
  "Within-unit CV (%), ESI-"
)
df_all$Group <- factor(df_all$Group, levels = group_levels)

# ---- 3. CV classes (5 % wide, 0-40 %) -------------------------------------------
breaks_seq <- seq(0, 40, by = 5)
labels_seq <- paste0(breaks_seq[-length(breaks_seq)], "–", breaks_seq[-1])

df_all <- df_all %>%
  filter(!is.na(CV) & CV >= 0) %>%
  mutate(Bin = cut(CV, breaks = breaks_seq, right = FALSE, include.lowest = TRUE,
                   labels = labels_seq))

# ---- 4. Colours --------------------------------------------------------------------
colors <- c(
  "Between-unit CV (%), ESI+" = "#c5005b",
  "Within-unit CV (%), ESI+"  = "#ff99a8",
  "Between-unit CV (%), ESI-" = "#0000e6",
  "Within-unit CV (%), ESI-"  = "#85c1e9"
)

# ---- 5. Plot --------------------------------------------------------------------------
p <- ggplot(df_all, aes(x = Bin, fill = Group)) +
  geom_bar(position = position_dodge(preserve = "single"), width = 0.8) +
  scale_fill_manual(values = colors) +
  scale_y_continuous(
    breaks = seq(0, 1000, by = 100),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    tag = "A",
    x = "CV Range (%)",
    y = "Number of compounds",
    fill = NULL
  ) +
  theme_classic() +
  theme(
    plot.tag = element_text(size = 16, face = "plain"),
    legend.position = "inside",
    legend.position.inside = c(0.80, 0.75),
    legend.background = element_blank(),
    axis.text = element_text(color = "black", size = 10),
    axis.title = element_text(size = 12),
    axis.line = element_line(color = "black", linewidth = 0.4)
  )

if (interactive()) print(p)

# ---- 6. Save ----------------------------------------------------------------------------
dir.create(dirname(out_prefix), recursive = TRUE, showWarnings = FALSE)
ggsave(paste0(out_prefix, ".pdf"), p, width = 8, height = 5)
ggsave(paste0(out_prefix, ".png"), p, width = 8, height = 5, dpi = 300)
cat("Saved:", paste0(out_prefix, c(".pdf", ".png")), "\n")

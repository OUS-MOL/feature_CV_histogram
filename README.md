# Reference material homogeneity: CV histograms (untargeted LC-MS)

R script that visualises the **homogeneity of a reference material** after mixing a
bulk and pipetting it into vials. For every metabolite / lipid feature, the
coefficient of variation (CV) is calculated

- **between units** (between different vials of the same material), and
- **within units** (within a vial),

separately for positive (ESI+) and negative (ESI-) ionization mode. The script bins the
CVs into 5 % classes (0-40 %) and plots the number of compounds per class, so the
between-unit and within-unit distributions can be compared directly. If the bulk is
homogeneous, the between-unit distribution should resemble the within-unit one.

## Input format

One Excel file per ionization mode (first sheet), with **exactly three columns in this order**
(column names are ignored and set by position):

| Column | Content |
|---|---|
| 1 | Compound name |
| 2 | Between-unit CV (%) |
| 3 | Within-unit CV (%) |

CVs must be given in percent. Values outside 0-40 % fall outside the plotted classes
(change `breaks_seq` in the script to use a different range).

## Running

```bash
Rscript cv_histogram.R data/data_positive.xlsx data/data_negative.xlsx output/cv_histogram
```

Writes `output/cv_histogram.pdf` and `output/cv_histogram.png`. Requires R with
`readxl`, `dplyr`, `tidyr` and `ggplot2` (>= 3.5.0).

## Try it with the fictional example data

`example_data/` contains simulated CVs for 620 (ESI+) and 480 (ESI-) fictional compounds;
`make_example_data.R` regenerates them with a fixed seed. They contain no real data.

```bash
Rscript cv_histogram.R example_data/data_positive_example.xlsx example_data/data_negative_example.xlsx output/cv_histogram
```

## Data

Real measurement data are not included in this repository and are not publicly available.

## License

MIT - see [LICENSE](LICENSE).

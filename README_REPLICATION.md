# Replication package

Paper: *Testing for Economies of Scope through an Established Pay-for-Performance Programme*

This repository uses Stata, Julia, and R. There is therefore no single `master.do`. Scripts are numbered in the intended execution order. Stata and R scripts define the replication root from the script location, not from the working directory. For Stata scripts in `scripts/`, the root is `dirname(current_do_file)/..`; for Stata builders in `scripts/qof_domain_builders/`, the root is `dirname(current_do_file)/../..`.

## Folder structure

```text
Rep_folder/
  scripts/
  data/
    GPs/
    derived/
  output/
    figures/
    tables/
    logs/
```

## Two ways to use the package

### Standard replication with the data supplied in this repository

The data shipped with the repository are sufficient to start at script `06_build_qof_practice_panel.do`. The earlier Stata scripts, `01_*` and `02_*`, document how the intermediate `.dta` files were built from public web downloads; they are not required for the standard replication run unless the user wants to rebuild all intermediate files from the original downloaded spreadsheets.

In a clean Stata session, run the scripts using either relative paths from `Rep_folder` or absolute paths. The do-files will set the root directory internally from their own location:

```stata
do scripts/06_build_qof_practice_panel.do
do scripts/07_descriptive_tables_and_figures.do
do scripts/08_analysis_bunching_and_results.do
```

`06_build_qof_practice_panel.do` uses the prepared intermediate files included under `data/GPs/` and writes `data/derived/QOFpracticePanel.dta`. Scripts `07` and `08` use that file to produce the descriptive outputs, first-step bunching outputs, second-step estimates, and empirical figures/tables.

### Full rebuild from downloaded public source files

The earlier scripts are included for transparency and for users who want to rebuild the supplied intermediate `.dta` files from raw public-source downloads. To use this mode, first place the downloaded raw files in the folder structure described in `data/README_data_sources.md`. Then run:

```stata
do scripts/01_prepare_gp_source_data.do
do scripts/02_prepare_qof_domain_data.do
do scripts/06_build_qof_practice_panel.do
do scripts/07_descriptive_tables_and_figures.do
do scripts/08_analysis_bunching_and_results.do
```

This rebuild mode depends on legacy public files from ODS/EGPCUR, APHO/ERPHO, National General Practice Profiles, Static IC/HSCIC indicators, Attribution Data Set files, and QOF domain workbooks. Some web locations are archival and may require manual retrieval.

## R transition heat map

After `08_analysis_bunching_and_results.do`, run:

```bash
Rscript scripts/11_plot_markov_matrix.R
```

The R script locates the replication root as `dirname(script)/..`, so it can be run from any working directory.

## Julia theory and simulation figures

From a Julia prompt:

```julia
include(raw"C:/path/to/Rep_folder/scripts/09_theory_figure4_bunching_density.jl")
include(raw"C:/path/to/Rep_folder/scripts/10_theory_figure5_policy_rules_derivatives_NLopt142.jl")
include(raw"C:/path/to/Rep_folder/scripts/12_AppendixB2_simulation_inputs_NLopt142.jl")  # needed only for Appendix Figure G1
```

The Julia scripts locate the replication root as the parent folder of `scripts/`, using their own file location. They do not require the Julia working directory to be `Rep_folder`.

Then, for Appendix Figure G1, run in Stata:

```stata
do scripts/13_AppendixB2_simulation_uncertainty_riskaversion.do
```


## Output map by script

The table below maps each replication script to the figures and tables as named in the paper or appendix. File names are reported in parentheses only to help locate the generated output.

| Script | Main paper or appendix outputs |
|---|---|
| `07_descriptive_tables_and_figures.do` | **Figure 2**: Histogram of PHC achievement relative to UL in 2011 (`allInsBunching.pdf`); **Appendix Figure A1**: PHCs workforce (`NHS staf 2001-2013 v2.pdf`); **Appendix Table A4**: QOF indicators descriptives for the 2010/11 financial year (`qofindic_descrip.tex`). |
| `08_analysis_bunching_and_results.do` | **Figure 7**: Example of presence and lack of bunching, THYROI02 and COPD13 (`ExampleBunchingTest.pdf`); **Figure 8**: Evidence of excess bunching at UL for each indicator, Step 1 (`step1_summary.pdf`); **Figure 9**: Estimates of the effects of the 2011 QOF contract changes, Step 2 (`step2_summary.pdf`); **Table 2**: Heterogeneity according to the number of indicators that PHCs have at the bunching window (`multiBunched_L3.tex`); **Appendix Table C1**: QOF indicators corner test (`testCornerv12alt.tex`); **Appendix Table C2**: QOF indicators corner test, additional exercises (`testCornerv12_rob.tex`); **Appendix Table C3**: Bunching graphs of QOF clinical indicators which did not change (`massProd/*.png`); **Appendix Table D1**: QOF indicators results, benchmark window (`mainResults_L3.tex`); **Appendix Table D2**: Alternative window configurations (`mainResults_Multih.tex`); **Appendix Figures F1-F5**: Heterogeneity analyses by PHC size, GP size, GP density, local shrinkage and local growth (`step2_summaryby_*.pdf`); **Appendix Figure F6**: Distribution of PHCs according to the number of indicators at the bunching window (`bunchedItemsDistribution2010.pdf`). |
| `09_theory_figure4_bunching_density.jl` | **Figure 5**: The effect on density of \(e_1\) of a kink on the payment function at \(e_1=UL\) (`Bunching1_uncertainty.pdf`). |
| `10_theory_figure5_policy_rules_derivatives_NLopt142.jl` | **Appendix Figure B1**: Simulation exercise, \(e_1^*\) as a function of \(a_2\) (`de1da2_uncertainty.pdf`). |
| `11_plot_markov_matrix.R` | **Appendix Figure A2**: Heat map at indicator-PHC level (`MarkovMatrixcol.png`). |
| `12_AppendixB2_simulation_inputs_NLopt142.jl` | Generates the simulation CSV grid used by **Appendix Figure B2**. This script does not directly produce a figure or table imported in the PDF. |
| `13_AppendixB2_simulation_uncertainty_riskaversion.do` | **Appendix Figure B2**: Estimates of steps 1 and 2 with respect to the variance of shocks on achievement, evidence from simulations (`sim_step1.png` and `sim_step2.png`). |

## Data source documentation

See `data/README_data_sources.md` and `data/GPs/_sources/`. The key source families are ODS/EGPCUR GP directory files, APHO/ERPHO modelled prevalence files, Static IC/HSCIC practice indicators 2011, Attribution Data Set registered population panel, National General Practice Profiles, and public QOF practice-level disease-domain workbooks.

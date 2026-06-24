# Data folder and source layer

The replication archive contains the prepared intermediate Stata datasets needed to start the standard replication at:

```stata
do scripts/06_build_qof_practice_panel.do
```

That is the intended starting point for users of the submitted replication package. Script `06_build_qof_practice_panel.do` uses prepared `.dta` files already supplied under `data/GPs/` and creates `data/derived/QOFpracticePanel.dta`. Scripts `07` and `08` then generate the empirical tables and figures.

## What is included for standard replication

The repository includes prepared intermediate files such as:

```text
data/GPs/QoF practice level/QOF*-practicePanel.dta
data/GPs/Modelled Prevalences/mhyp_practices.dta
data/GPs/National General Practice Profiles/NationalGeneralPracticeProfiles.dta
data/GPs/Static IC Indicators 2011/GPstaticChars2011.dta
data/GPs/GIS/GPaddress.dta
data/derived/QOFpracticePanel_ready.dta
```

These files are sufficient for the paper replication pipeline from script `06` onward.

## What scripts 01 and 02 do

Scripts `01_*` and `02_*` are included to document and, when raw downloads are available, rebuild the prepared intermediate `.dta` files from public web sources. They are not required for the standard replication run.

Those scripts correspond to the following public-source families:

1. ODS/EGPCUR GP directory files.
2. APHO/ERPHO modelled prevalence files.
3. Static IC/HSCIC practice indicators for 2011.
4. Attribution Data Set registered-population files.
5. National General Practice Profiles.
6. QOF practice-level disease-domain workbooks.

To rebuild from raw downloads, place the downloaded source workbooks/CSVs in the folder structure expected by the scripts, then run:

```stata
do scripts/01_prepare_gp_source_data.do
do scripts/02_prepare_qof_domain_data.do
```

Some of the web sources are archival and may require manual retrieval from legacy URLs or web archives. The prepared `.dta` files are therefore supplied in the repository so that the paper can be reproduced without relying on the availability of old web downloads.

## Raw-source provenance

Legacy source notes and original scripts are preserved under:

```text
data/GPs/_sources/
```

Before final journal deposit, add access dates and checksums for the raw public files that were used to create the supplied intermediate `.dta` files, where available.

/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 01f_build_national_gp_profiles.do
Language: Stata
Purpose: Build the small Stata extract from the National General Practice Profiles file
         used by the QOF practice-panel builder.

Recovered original script:
  data/GPs/_sources/1.PublicHealthEngland2010onwards.do

Paper/data role:
  This script constructs data/GPs/National General Practice Profiles/NationalGeneralPracticeProfiles.dta,
  which is merged in 06_build_qof_practice_panel.do. In the recovered analysis code,
  the only explicitly used variable from this source is IMD2010, the practice-level
  deprivation score.

Expected raw input:
  data/GPs/National General Practice Profiles/raw/PublicHealthEngland-Data.xlsx
  Sheet: DeprivPrac
  Required columns: pra_code and year-suffixed IMD2010_* variables.

Output:
  data/GPs/National General Practice Profiles/NationalGeneralPracticeProfiles.dta

Run order:
  00_programs_and_globals.do
  01_prepare_gp_source_data.do, or run this script directly after cd-ing to Rep_folder.
****************************************************************************************/

cap log close
clear all
set more off

capture confirm global root
if _rc {
    global root "`c(pwd)'"
}
capture confirm global dataGP
if _rc {
    global dataGP "$root/data/GPs"
}
capture confirm global logsFold
if _rc {
    global logsFold "$root/output/logs"
}

cap mkdir "$dataGP/National General Practice Profiles"
cap mkdir "$dataGP/National General Practice Profiles/raw"
cap mkdir "$logsFold"
log using "$logsFold/01f_build_national_gp_profiles.log", replace text

local rawfile "$dataGP/National General Practice Profiles/raw/PublicHealthEngland-Data.xlsx"
local outfile "$dataGP/National General Practice Profiles/NationalGeneralPracticeProfiles.dta"

capture confirm file "`rawfile'"
if _rc {
    di as error "Missing raw National General Practice Profiles workbook: `rawfile'"
    di as error "Place PublicHealthEngland-Data.xlsx in the raw folder, then rerun."
    exit 601
}

import excel using "`rawfile'", sheet("DeprivPrac") firstrow clear

capture confirm variable pra_code
if _rc {
    di as error "The imported DeprivPrac sheet must contain pra_code."
    exit 111
}

capture unab imd_vars : IMD2010_*
if _rc {
    di as error "No IMD2010_* variables found. Expected year-suffixed deprivation variables."
    exit 111
}

reshape long IMD2010_, i(pra_code) j(year)
rename *_ *
label var IMD2010 "Deprivation Score (IMD 2010)"
label data "National General Practice Profiles extract: practice-level IMD 2010 by year"
compress
save "`outfile'", replace

di as result "Built `outfile'"
log close

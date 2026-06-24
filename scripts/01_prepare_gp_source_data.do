/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 01_prepare_gp_source_data.do
Language: Stata
Purpose: Document and, when raw source files are present, build the intermediate .dta files
         that are merged by 06_build_qof_practice_panel.do.

This is NOT a cross-language master file for the whole replication package. It only covers
the Stata data-preparation bridge between downloaded public-source files and the .dta inputs
used by the QOF practice-panel builder.

Data-source families covered here:
  1. ODS/EGPCUR GP directory files                       -> gp_egpcur.dta
  2. APHO/ERPHO modelled prevalence files                -> mhyp.dta, mhyp_practices.dta
  3. IC/HSCIC static practice indicators 2011            -> GPstaticChars2011.dta
  4. Attribution Data Set registered-population panel     -> AttributionDataset_panel152.dta
  5. National General Practice Profiles                  -> NationalGeneralPracticeProfiles.dta
  6. QOF practice-level disease-domain files             -> built/checks in 02_prepare_qof_domain_data.do

Run order:
  00_programs_and_globals.do
  01_prepare_gp_source_data.do
  02_prepare_qof_domain_data.do
  06_build_qof_practice_panel.do
  07_analysis_bunching_and_results.do
  08_theory_figure4_bunching_density.jl
  09_theory_figure5_policy_rules_derivatives.jl

Notes:
  - Set the BUILD_* switches to 0 if the corresponding .dta has already been included.
  - The QOF disease-domain .dta files are checked here but not rebuilt because their
    raw-domain import scripts are now included under scripts/qof_domain_builders/.
****************************************************************************************/

cap log close
clear all
set more off

global root        "`c(pwd)'"
global scripts     "$root/scripts"
global dataGP      "$root/data/GPs"
global dataDerived "$root/data/derived"
global logsFold    "$root/output/logs"

cap mkdir "$logsFold"
log using "$logsFold/01_prepare_gp_source_data.log", replace text

* -----------------------------------------------------------------------------
* Switches. Leave as 1 to rebuild from raw public-source files. Set to 0 if
* the derived .dta files are already supplied in data/GPs.
* -----------------------------------------------------------------------------
global BUILD_EGPCUR             1
global BUILD_MODELED_PCT        1
global BUILD_MODELED_PRACTICE   1
global BUILD_STATIC_IC_2011     1
global BUILD_ATTRIBUTION_PCT     1
global BUILD_NGP_PROFILES        1

* -----------------------------------------------------------------------------
* 1. Build intermediate source datasets.
* -----------------------------------------------------------------------------
if ${BUILD_EGPCUR} {
    do "$scripts/01a_build_gp_directory_egpcur.do"
}

if ${BUILD_MODELED_PCT} {
    do "$scripts/01b_build_modelled_prevalence_pct.do"
}

if ${BUILD_MODELED_PRACTICE} {
    do "$scripts/01c_build_modelled_prevalence_practice.do"
}

if ${BUILD_STATIC_IC_2011} {
    do "$scripts/01d_build_static_ic_indicators_2011.do"
}

if ${BUILD_ATTRIBUTION_PCT} {
    do "$scripts/01e_build_attribution_dataset_pct.do"
}

if ${BUILD_NGP_PROFILES} {
    do "$scripts/01f_build_national_gp_profiles.do"
}

* -----------------------------------------------------------------------------
* 2. Check that all source-level .dta inputs required by 06_build_qof_practice_panel.do exist.
* -----------------------------------------------------------------------------
local required_dta ///
    "$dataGP/GPsdirectory/moredocreg/gp_egpcur.dta" ///
    "$dataGP/Modelled Prevalences/mhyp_practices.dta" ///
    "$dataGP/Static IC Indicators 2011/GPstaticChars2011.dta" ///
    "$dataGP/Attribution Data Set (list size)/AttributionDataset_panel152.dta" ///
    "$dataGP/National General Practice Profiles/NationalGeneralPracticeProfiles.dta" ///
    "$dataGP/GIS/GPaddress.dta"

foreach f of local required_dta {
    capture confirm file "`f'"
    if _rc {
        di as error "MISSING REQUIRED INPUT: `f'"
        di as error "Place/build this file before running 06_build_qof_practice_panel.do"
    }
    else {
        di as result "FOUND: `f'"
    }
}

* QOF disease-domain files required by the practice-panel builder.
local qof_dta ///
    "QOFprimPrev-practicePanel.dta" ///
    "QOFdiabetes-practicePanel.dta" ///
    "QOFhyper-practicePanel.dta" ///
    "QOFmental-practicePanel.dta" ///
    "QOFdepr-practicePanel.dta" ///
    "QOFcoron-practicePanel.dta" ///
    "QOFatrial-practicePanel.dta" ///
    "QOFasthma-practicePanel.dta" ///
    "QOFckd-practicePanel.dta" ///
    "QOFepil-practicePanel.dta" ///
    "QOFsmoke-practicePanel.dta" ///
    "QOFthyroid-practicePanel.dta" ///
    "QOFstroke-practicePanel.dta" ///
    "QOFheart-practicePanel.dta" ///
    "QOFcancer-practicePanel.dta" ///
    "QOFdem-practicePanel.dta" ///
    "QOFcopd-practicePanel.dta" ///
    "QOForga-practicePanel.dta" ///
    "QOFdomm-practicePanel.dta" ///
    "QOFprevalence-practicePanel.dta"

foreach f of local qof_dta {
    local fullpath "$dataGP/QoF practice level/`f'"
    capture confirm file "`fullpath'"
    if _rc {
        di as error "MISSING QOF DOMAIN INPUT: `fullpath'"
    }
    else {
        di as result "FOUND: `fullpath'"
    }
}

* -----------------------------------------------------------------------------
* 3. Write a simple source-to-analysis map for the replication record.
* -----------------------------------------------------------------------------
tempname handle
file open `handle' using "$dataGP/source_to_analysis_map.csv", write replace
file write `handle' "analysis_input,constructed_by,raw_source_folder,used_in" _n
file write `handle' "GPsdirectory/moredocreg/gp_egpcur.dta,01a_build_gp_directory_egpcur.do,GPsdirectory/moredocreg/raw,06_build_qof_practice_panel.do" _n
file write `handle' "Modelled Prevalences/mhyp.dta,01b_build_modelled_prevalence_pct.do,Modelled Prevalences/raw,optional PCT compiler" _n
file write `handle' "Modelled Prevalences/mhyp_practices.dta,01c_build_modelled_prevalence_practice.do,Modelled Prevalences/raw,06_build_qof_practice_panel.do" _n
file write `handle' "Static IC Indicators 2011/GPstaticChars2011.dta,01d_build_static_ic_indicators_2011.do,Static IC Indicators 2011/raw,06_build_qof_practice_panel.do" _n
file write `handle' "Attribution Data Set (list size)/AttributionDataset_panel152.dta,01e_build_attribution_dataset_pct.do,Attribution Data Set (list size),optional PCT compiler and source documentation for National General Practice Profiles" _n
file write `handle' "National General Practice Profiles/NationalGeneralPracticeProfiles.dta,01f_build_national_gp_profiles.do,National General Practice Profiles/raw/PublicHealthEngland-Data.xlsx,06_build_qof_practice_panel.do" _n
file write `handle' "QoF practice level/*-practicePanel.dta,02_prepare_qof_domain_data.do,QoF practice level/<year> raw QOF Excel workbooks,06_build_qof_practice_panel.do" _n
file close `handle'

di as result "Wrote $dataGP/source_to_analysis_map.csv"
log close

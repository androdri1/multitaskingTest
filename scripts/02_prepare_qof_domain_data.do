/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 02_prepare_qof_domain_data.do
Language: Stata
Purpose: Build the prepared QOF practice-domain .dta files from the raw public QOF Excel
         workbooks recovered in the legacy code bundle.

This is not a cross-language master file. It is a Stata-only bridge for the QOF raw-data
conversion layer. If the prepared QOF domain files are already deposited in
`data/GPs/QoF practice level/`, set RUN_QOF_PRACTICE_BUILDERS to 0 and leave this script
as documentation/checks.

Main outputs used by 06_build_qof_practice_panel.do:
  data/GPs/QoF practice level/QOFprimPrev-practicePanel.dta
  data/GPs/QoF practice level/QOFdiabetes-practicePanel.dta
  ...
  data/GPs/QoF practice level/QOFprevalence-practicePanel.dta

Run order:
  00_programs_and_globals.do
  01_prepare_gp_source_data.do
  02_prepare_qof_domain_data.do
  06_build_qof_practice_panel.do
****************************************************************************************/

cap log close
clear all
set more off

capture confirm global root
if _rc {
    global root "`c(pwd)'"
}
global scripts     "$root/scripts"
global dataGP      "$root/data/GPs"
global logsFold    "$root/output/logs"
cap mkdir "$logsFold"
cap mkdir "$dataGP/QoF practice level"
cap mkdir "$dataGP/Quality and Outcomes Framework Achievement Data"
log using "$logsFold/02_prepare_qof_domain_data.log", replace text

* Switches
* Set RUN_QOF_PRACTICE_BUILDERS to 0 when depositing prepared domain .dta files.
global RUN_QOF_PRACTICE_BUILDERS 1
* Optional PCT-level QOF files are not required by 06_build_qof_practice_panel.do.
global RUN_QOF_PCT_BUILDERS      0

if ${RUN_QOF_PRACTICE_BUILDERS} {
    do "$scripts/qof_domain_builders/02a01_build_qof_practice_primary_prevention.do"
    do "$scripts/qof_domain_builders/02a02_build_qof_practice_diabetes.do"
    do "$scripts/qof_domain_builders/02a03_build_qof_practice_hypertension.do"
    do "$scripts/qof_domain_builders/02a04_build_qof_practice_mental_health.do"
    do "$scripts/qof_domain_builders/02a05_build_qof_practice_depression.do"
    do "$scripts/qof_domain_builders/02a06_build_qof_practice_chd.do"
    do "$scripts/qof_domain_builders/02a07_build_qof_practice_atrial_fibrillation.do"
    do "$scripts/qof_domain_builders/02a08_build_qof_practice_asthma.do"
    do "$scripts/qof_domain_builders/02a09_build_qof_practice_ckd.do"
    do "$scripts/qof_domain_builders/02a10_build_qof_practice_epilepsy.do"
    do "$scripts/qof_domain_builders/02a11_build_qof_practice_smoking.do"
    do "$scripts/qof_domain_builders/02a12_build_qof_practice_thyroid.do"
    do "$scripts/qof_domain_builders/02a13_build_qof_practice_stroke.do"
    do "$scripts/qof_domain_builders/02a14_build_qof_practice_heart_failure.do"
    do "$scripts/qof_domain_builders/02a15_build_qof_practice_cancer.do"
    do "$scripts/qof_domain_builders/02a16_build_qof_practice_dementia.do"
    do "$scripts/qof_domain_builders/02a17_build_qof_practice_copd.do"
    do "$scripts/qof_domain_builders/02a18_build_qof_practice_organisational.do"
    do "$scripts/qof_domain_builders/02a19_build_qof_practice_domain_summary.do"
    do "$scripts/qof_domain_builders/02a20_build_qof_practice_prevalence.do"
}

if ${RUN_QOF_PCT_BUILDERS} {
    do "$scripts/qof_domain_builders/02b01_optional_build_qof_pct_clinical_domain.do"
    do "$scripts/qof_domain_builders/02b02_optional_build_qof_pct_prevalence.do"
    do "$scripts/qof_domain_builders/02b03_optional_build_qof_pct_primary_prevention.do"
}

* Verify outputs required by the practice panel builder.
local expected_qof ///
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

foreach f of local expected_qof {
    local fullpath "$dataGP/QoF practice level/`f'"
    capture confirm file "`fullpath'"
    if _rc {
        di as error "MISSING QOF DOMAIN OUTPUT: `fullpath'"
    }
    else {
        di as result "FOUND QOF DOMAIN OUTPUT: `fullpath'"
    }
}

log close

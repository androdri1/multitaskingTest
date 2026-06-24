/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 01c_build_modelled_prevalence_practice.do
Language: Stata
Purpose: Build practice-level modelled hypertension prevalence file from APHO/ERPHO workbooks.
Source:
  - ModelledestimatesofCHDstrokehypertensionandCOPDb.xls
  - HypertensionPrevalenceEstimatesDec2011.xls
Inputs expected:
  - data/GPs/Modelled Prevalences/raw/ModelledestimatesofCHDstrokehypertensionandCOPDb.xls
  - data/GPs/Modelled Prevalences/raw/HypertensionPrevalenceEstimatesDec2011.xls
Outputs:
  - data/GPs/Modelled Prevalences/mhyp_practices.dta
Used by:
  - 06_build_qof_practice_panel.do, which merges mhyp_practices.dta.
Paper output:
  - No direct table or figure. Provides modelled prevalence controls used by empirical estimates.
Run order:
  - Component of 01_prepare_gp_source_data.do.
****************************************************************************************/

cap log close
clear all
set more off

global root        "`c(pwd)'"
global scripts     "$root/scripts"
global dataGP      "$root/data/GPs"
global logsFold    "$root/output/logs"

cap mkdir "$logsFold"
log using "$logsFold/01c_build_modelled_prevalence_practice.log", replace text

cd "$dataGP/Modelled Prevalences/raw"

* Data from: East of England Public Health Observatory. Based on HSE 03-04, "account for age, sex, ethnicity and deprivation score"
**************************************************************
**************************************************************
* Extract the info from Excel Files
clear all
tempfile myfile

import excel "ModelledestimatesofCHDstrokehypertensionandCOPDb.xls", allstring sheet("Hypertension") cellrange(A4:L8181)
gen year="2008"	

rename A pra_code
rename B pra_name
rename C pra_address
rename D pct_code
rename E pct_name
rename F sha_code
rename G sha_name
rename H mhyp_regcount
rename I mhyp_denom
rename J mhyp_16p_denom
rename K mhyp_prev
rename L mhyp_16p_prev

	save `myfile', replace
		
clear
import excel "HypertensionPrevalenceEstimatesDec2011.xls", allstring sheet("Practices") cellrange(A8:J8144)

gen year="2011"	

rename A pra_code
rename B pra_name
rename C pct_code
rename D sha_code
rename E mhyp_16p_regcount
rename F mhyp_16p_denom
rename G mhyp_16p_prev
rename H mhyp_regcount
rename I mhyp_denom
rename J mhyp_prev

append using `myfile'	


destring mhyp_16p_regcount- year, replace force
* *********************************************************
do "$scripts/99_pct_mergers_2006_2011_helper.do"
* *********************************************************

label data "Modelled hypertension prevalences 2009 and 2011 (practice level)"

save "$dataGP/Modelled Prevalences/mhyp_practices.dta", replace


log close

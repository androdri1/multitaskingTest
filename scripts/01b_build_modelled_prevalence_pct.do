/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 01b_build_modelled_prevalence_pct.do
Language: Stata
Purpose: Build PCT-level modelled hypertension prevalence file from APHO/ERPHO workbooks.
Source:
  - Modelled hypertension by PCT v2.xls
  - HypertensionPrevalenceEstimatesDec2011.xls
Inputs expected:
  - data/GPs/Modelled Prevalences/raw/Modelled hypertension by PCT v2.xls
  - data/GPs/Modelled Prevalences/raw/HypertensionPrevalenceEstimatesDec2011.xls
Outputs:
  - data/GPs/Modelled Prevalences/mhyp.dta
Used by:
  - Optional PCT-level compiler / controls. Not directly used by 06_build_qof_practice_panel.do.
Paper output:
  - No direct table or figure in the current practice-level empirical pipeline.
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
log using "$logsFold/01b_build_modelled_prevalence_pct.log", replace text

cd "$dataGP/Modelled Prevalences/raw"

* Data from: East of England Public Health Observatory. Based on HSE 03-04, "account for age, sex, ethnicity and deprivation score"
**************************************************************
**************************************************************
* Extract the info from Excel Files
clear all
tempfile myfile

import excel "Modelled hypertension by PCT v2.xls", allstring sheet("2006") cellrange(A6:AC157)
	gen year="2006"
	save `myfile', replace
	clear

import excel "Modelled hypertension by PCT v2.xls", allstring sheet("2007") cellrange(A6:AC157)
	gen year="2007"
	append using `myfile'	
	save `myfile', replace
	clear

import excel "Modelled hypertension by PCT v2.xls", allstring sheet("2008") cellrange(A6:AC157)
	gen year="2008"
	append using `myfile'	

	rename A pct_code
	rename B pct_name
	rename C mhyp_male_regcount
	rename D mhyp_male_denom
	rename E mhyp_male_prev
	rename F mhyp_female_regcount
	rename G mhyp_female_denom
	rename H mhyp_female_prev
	rename I mhyp_regcount
	rename J mhyp_denom
	rename K mhyp_prev
	rename L mhyp_white_regcount
	rename M mhyp_white_prev
	rename N mhyp_mixed_regcount
	rename O mhyp_mixed_prev
	rename P mhyp_black_regcount
	rename Q mhyp_black_prev
	rename R mhyp_asian_regcount
	rename S mhyp_asian_prev
	rename T mhyp_other_regcount
	rename U mhyp_other_prev
	rename V mhyp_1644_regcount
	rename W mhyp_1644_prev
	rename X mhyp_4564_regcount
	rename Y mhyp_4564_prev
	rename Z mhyp_6574_regcount
	rename AA mhyp_6574_prev
	rename AB mhyp_75p_regcount
	rename AC mhyp_75p_prev

	save `myfile', replace
		
* ***************************************************
* New model
	
clear
import excel "HypertensionPrevalenceEstimatesDec2011.xls", allstring sheet("PCT") cellrange(A8:AM158)

	gen year="2011"	
		
	rename A pct_code
	rename B pct_name
	rename C sha_code
	rename D mhyp_male_regcount
	rename E mhyp_male_denom
	rename F mhyp_male_prev
	rename G mhyp_female_regcount
	rename H mhyp_female_denom
	rename I mhyp_female_prev
	rename J mhyp_regcount
	rename K mhyp_denom
	rename L mhyp_prev
	rename M mhyp_white_regcount
	rename N mhyp_white_denom
	rename O mhyp_white_prev
	rename P mhyp_mixed_regcount
	rename Q mhyp_mixed_denom
	rename R mhyp_mixed_prev
	rename S mhyp_black_regcount
	rename T mhyp_black_denom
	rename U mhyp_black_prev
	rename V mhyp_asian_regcount
	rename W mhyp_asian_denom
	rename X mhyp_asian_prev
	rename Y mhyp_other_regcount
	rename Z mhyp_other_denom
	rename AA mhyp_other_prev
	rename AB mhyp_1644_regcount
	rename AC mhyp_1644_denom
	rename AD mhyp_1644_prev
	rename AE mhyp_4564_regcount
	rename AF mhyp_4564_denom
	rename AG mhyp_4564_prev
	rename AH mhyp_6574_regcount
	rename AI mhyp_6574_denom
	rename AJ mhyp_6574_prev
	rename AK mhyp_75p_regcount
	rename AL mhyp_75p_denom
	rename AM mhyp_75p_prev

append using `myfile'	

destring mhyp_male_regcount- year, replace force

* *********************************************************
do "$scripts/99_pct_mergers_2006_2011_helper.do"
* *********************************************************
collapse (sum) *_regcount *_denom , by(pct_code year)

gen mhyp_prev = mhyp_regcount/mhyp_denom
keep pct_code year mhyp_prev

label data "Modelled hypertension prevalences 2006-2008 , and new model for 2011 (151 PCTs)"

save "$dataGP/Modelled Prevalences/mhyp.dta", replace


log close

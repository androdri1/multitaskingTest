/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 01d_build_static_ic_indicators_2011.do
Language: Stata
Purpose: Build static 2011 practice characteristics from IC/HSCIC indicator workbooks.
Sources include:
  - GENERAL_PRACTICE_CONTRACTS 2011.xls
  - Urban Rural Definition of practice 2011.xls
  - YEARS_OF_RECKONABLE_SERVICE 2011.xls
  - General Practice 2012 Practice GP.csv
  - PCT2006_303to152.dta crosswalk
Inputs expected:
  - data/GPs/Static IC Indicators 2011/raw/*.xls
  - data/GPs/General and Personal Medical Services/General Practice 2012 Practice GP.csv
  - data/GPs/Maps/ONS PCT code/PCT2006_303to152.dta
Outputs:
  - data/GPs/Static IC Indicators 2011/GPstaticChars2011.dta
Used by:
  - 06_build_qof_practice_panel.do, which merges GPstaticChars2011.dta.
Paper output:
  - No direct table or figure. Provides practice controls: contract type, list size,
    GP headcount, rurality, years-of-service index and workforce composition.
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
log using "$logsFold/01d_build_static_ic_indicators_2011.log", replace text

cd "$dataGP/Static IC Indicators 2011/raw"

* Data from: http://www.hscic.gov.uk/qof
**************************************************************
**************************************************************
* Extract the info from Excel Files
clear all
tempfile myfile

import excel "GENERAL_PRACTICE_CONTRACTS 2011.xls", allstring sheet("General Practice Contracts") cellrange(A12:J8327)
	gen year="2011"	
		
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E pra_code
	rename F pra_name
	rename G gp_hc
	rename H list
	rename I gp_1000p
	rename J contract
	
	preserve
	clear

import excel "Urban Rural Definition of practice 2011.xls", allstring sheet("Rurality") cellrange(A11:H8258)
	gen year="2011"	
	
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E pra_code
	rename F pra_name
	rename G ONS_rural
	rename H ONS_ruralDef

	replace pra_code=trim(pra_code)
	
	save `myfile', replace
	restore
	merge 1:1 pra_code using `myfile', nogen	
	preserve
	clear

import excel "YEARS_OF_RECKONABLE_SERVICE 2011.xls", allstring sheet("Table") cellrange(A14:Q8217)
	gen year="2011"	
	
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E pra_code
	rename F pra_name
	rename G yrsexp_00_04
	rename H yrsexp_05_09
	rename I yrsexp_10_14
	rename J yrsexp_15_19
	rename K yrsexp_20_24
	rename L yrsexp_25_29
	rename M yrsexp_30_34
	rename N yrsexp_35_39
	rename O yrsexp_40_44
	rename P yrsexp_45_49
	rename Q yrsexp_50_54
		

	save `myfile', replace
	restore
	merge 1:1 pra_code using `myfile', nogen	
	preserve
	clear
	
import delimited "$dataGP/General and Personal Medical Services/General Practice 2012 Practice GP.csv", clear 
	gen year="2012"		

	rename sha 				sha_code
	rename sha_name		 	sha_name
	rename pct_code 		pct_code
	rename pct_name		 	pct_name
	rename practice_code	pra_code
	rename practice_name 	pra_name
	
	drop if pra_code=="PCT"
	
	rename under_30_years_headcount gphcage_u30
	rename v20 					 	gphcage_30_34
	rename v21 					 	gphcage_35_39
	rename v22 					 	gphcage_40_44 
	rename v23  					gphcage_45_49
	rename v24 					 	gphcage_50_54 
	rename v25 					 	gphcage_55_59 
	rename v26  					gphcage_60_64
	rename v27  					gphcage_65_70
	rename over_70_years_headcount  gphcage_a70
	
	
	

	
	egen gphcagel=rowtotal(gphcage_u30 gphcage_30_34 gphcage_35_39 gphcage_40_44 gphcage_45_49 gphcage_50_54 gphcage_55_59 gphcage_60_64 gphcage_65_70 gphcage_a70)

	gen avgAgeBra=0
	local i=1
	foreach varo in "u30" "30_34" "35_39" "40_44" "45_49" "50_54" "55_59" "60_64" "65_70" "a70" {
		replace avgAgeBra=(25+5*`i')*(gphcage_`varo'/gphcagel) + avgAgeBra
		local i=1+`i'
		drop gphcage_`varo'
	}
	label var avgAgeBra "Avg. (2012) GPs age from brackets"
	drop gphcagel 

	
	egen gphcqual=rowtotal( uk_headcount european_economic_area_headcount europe_other_headcount africa_headcount asia_headcount australasiapacific_headcount central_america_headcount north_america_headcount south_america_headcount middle_east_headcount unknown_country_qualification_he)
	gen  gpQualUKpro = uk_headcount/gphcqual
	drop gphcqual
	label var gpQualUKpro "Proportion (2012) of GPs with UK qualification"

	
	egen gphcprov=rowtotal(gp_provider_headcount gp_other_headcount gp_registrar_headcount gp_retainer_headcount)
	gen  gpPROVpro = gp_provider_headcount/gphcprov
	gen  gpREGIpro = gp_registrar_headcount/gphcprov
	gen  gpRETApro = gp_retainer_headcount/gphcprov	
	gen  gpSALApro = gp_other_headcount/gphcprov	
	
	drop gphcprov
	label var gpPROVpro "Proportion (2012) of HC GPs excluding Registrars (i.e. trainees) and Retainers"	
	label var gpREGIpro "Proportion (2012) of HC GPs who are registrar"	
	label var gpRETApro "Proportion (2012) of HC GPs who are retainer"	
	label var gpSALApro "Proportion (2012) of HC GPs who are salaried"	
	
	
	egen gpFTEprov=rowtotal(gp_provider_fte gp_other_fte gp_registrar_fte gp_retainer_fte)
	gen  gpFTEPROVpro = gp_provider_fte/gpFTEprov
	gen  gpFTEREGIpro = gp_registrar_fte/gpFTEprov
	gen  gpFTERETApro = gp_retainer_fte/gpFTEprov	
	gen  gpFTESALApro = gp_other_fte/gpFTEprov	
	
	drop gpFTEprov
	label var gpFTEPROVpro "Proportion (2012) of FTE GPs excluding Registrars (i.e. trainees) and Retainers"	
	label var gpFTEREGIpro "Proportion (2012) of FTE GPs who are registrar"	
	label var gpFTERETApro "Proportion (2012) of FTE GPs who are retainer"	
	label var gpFTESALApro "Proportion (2012) of FTE GPs who are salaried"		
	
	save `myfile', replace
	restore
	merge 1:1 pra_code using `myfile', nogen	
		

* *******************************	

destring year gp_hc list gp_1000p ONS_rural ONS_rural yrsexp_* , replace force

labmask ONS_rural, val(ONS_ruralDef)
drop ONS_ruralDef
encode contract, gen(cont)
drop contract
gen cont_GMS  =  cont==3 | cont==4 if cont!=.
gen cont_PMS = cont==6 | cont==7 if cont!=.
gen cont_other= cont_GMS==0 & cont_PMS==0  if cont!=.

egen GPdenom=rowtotal(yrsexp_*)

foreach x in "00_04" "05_09" "10_14" "15_19" "20_24" "25_29" "30_34" "35_39" "40_44" "45_49" "50_54" {
	gen yrsexpW_`x'=yrsexp_`x'/GPdenom
	replace yrsexpW_`x'=0 if yrsexp_`x'==. & GPdenom!=.
	label var yrsexp_`x' "Years of Reckonable Service `x'"
}

gen yrsexpIndi=yrsexpW_00_04*1+yrsexpW_05_09*2+yrsexpW_10_14*3+yrsexpW_15_19*4+yrsexpW_20_24*5+yrsexpW_25_29*6+yrsexpW_30_34*7+yrsexpW_35_39*8+yrsexpW_40_44*9+yrsexpW_45_49*10+yrsexpW_50_54*11
drop yrsexpW_*
drop GPdenom

label var gp_hc "Number of GPs (HC) (A)"
label var list "Registered List (B)"
label var gp_1000p "Number of GPs (HC) per 1,000 patients (A/(B/1000)"
label var ONS_rural "Practice ONS rurality indicator"
label var cont  "Type of contract"
label var cont_GMS   "GMS contract"
label var cont_PMS  "PMS contract"
label var cont_other "Other contract"
label var yrsexpIndi "Years of Reckonable Service Index"


order sha_code sha_name pct_code pct_name pra_code pra_name year
	 

* *********************************************************
* Let's deal with the PCT name and code
* 2003-2006: 303
* 2007-2013: 152

gen pct303code=pct_code if year<2006
merge n:1 pct303code using "$dataGP/Maps/ONS PCT code/PCT2006_303to152.dta", keep(master match)   /* Get PCT standarized id */
tab _merge year // Good, 2005 and 2006 match properly
drop _merge

replace pct152code=pct_code if year>=2006
replace pct152name=pct_name if year>=2006

* *********************************************************
rename pct_code pct_codeX
rename pct152code pct_code
do "$scripts/99_pct_mergers_2006_2011_helper.do"
rename pct_code pct152code
rename pct_codeX pct_code
* *********************************************************	 
	 
save "$dataGP/Static IC Indicators 2011/GPstaticChars2011.dta", replace



log close

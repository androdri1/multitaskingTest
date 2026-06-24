/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 01e_build_attribution_dataset_pct.do
Language: Stata
Purpose: Build the PCT-level Attribution Data Set panel from public HSCIC/QOF
         registered-population Excel workbooks.

Paper role:
  - This file does not directly produce a table or figure.
  - It documents and builds one source family used by the National General Practice
    Profiles and by the optional PCT-level workforce/context compiler.
  - The National General Practice Profiles FAQ describes the Attribution Dataset as
    one of the input sources for the profiles; this script builds the PCT-level ADS
    panel recovered in the legacy code, not the full practice-level profiles extract.

Expected raw inputs in data/GPs/Attribution Data Set (list size):
  - ADS 2007 Final GP Regd pops.xls
  - ADS 2008 Final GP Regd pops.xls
  - ADS 2009 Final GP Regd pops.xls
  - attr-data-gp-regi-pop-2010-fina-tab.xls
  - attr-data-gp-reg-pop-ons-esti-2011-data.xls

Output:
  - data/GPs/Attribution Data Set (list size)/AttributionDataset_panel152.dta

Run order:
  00_programs_and_globals.do
  01e_build_attribution_dataset_pct.do
****************************************************************************************/

cap log close
clear all
set more off

global root        "`c(pwd)'"
global scripts     "$root/scripts"
global dataGP      "$root/data/GPs"
global logsFold    "$root/output/logs"

cap mkdir "$logsFold"
cap mkdir "$dataGP/Attribution Data Set (list size)"
log using "$logsFold/01e_build_attribution_dataset_pct.log", replace text

cd "$dataGP/Attribution Data Set (list size)"
* Attribution Dataset (N of patients by age brackets)

clear all


* Data from: http://www.hscic.gov.uk/qof
**************************************************************
**************************************************************
* Extract the info from Excel Files
clear all
tempfile myfile
import excel "ADS 2007 Final GP Regd pops.xls", allstring sheet("PCOs") cellrange(B19:AU170)
	gen year="2007"	
	preserve
	clear

import excel "ADS 2007 Final GP Regd pops.xls", allstring sheet("PCOs") cellrange(B174:AU195) //Wales
	gen year="2007"		
	save `myfile', replace
	restore
	append using `myfile'		
	preserve
	clear	
	
import excel "ADS 2008 Final GP Regd pops.xls", allstring sheet("PCOs") cellrange(B21:AU172) //England
	gen year="2008"	
	save `myfile', replace
	restore
	append using `myfile'
	preserve
	clear	

import excel "ADS 2008 Final GP Regd pops.xls", allstring sheet("PCOs") cellrange(B179:AU200) //Wales
	gen year="2008"		
	save `myfile', replace
	restore
	append using `myfile'	

	
rename B SHACode
rename C PCOCode
rename D PCOName
rename E Allpersons
rename F AllMales
rename G AllFemales
rename I MalesUnder1
rename J Males14
rename K Males59
rename L Males1014
rename M Males1519
rename N Males2024
rename O Males2529
rename P Males3034
rename Q Males3539
rename R Males4044
rename S Males4549
rename T Males5054
rename U Males5559
rename V Males6064
rename W Males6569
rename X Males7074
rename Y Males7579
rename Z Males8084
rename AA Males85Over
rename AC FemalesUnder1
rename AD Females14
rename AE Females59
rename AF Females1014
rename AG Females1519
rename AH Females2024
rename AI Females2529
rename AJ Females3034
rename AK Females3539
rename AL Females4044
rename AM Females4549
rename AN Females5054
rename AO Females5559
rename AP Females6064
rename AQ Females6569
rename AR Females7074
rename AS Females7579
rename AT Females8084
rename AU Females85Over

drop H AB	
	

tempfile base
save 	`base', replace
	
* **************************************************************************************************
	
clear	
	
import excel "ADS 2009 Final GP Regd pops.xls", allstring sheet("PCOs") cellrange(B22:AX173) //England
	gen year="2009"	
	save `myfile', replace
	preserve
	clear		

import excel "ADS 2009 Final GP Regd pops.xls", allstring sheet("PCOs") cellrange(B180:AX201) //Wales
	gen year="2009"		
	save `myfile', replace
	restore
	append using `myfile'	

	
rename B SHACode
rename C PCOCode
rename D PCOName
rename E Allpersons
rename F AllMales
rename G AllFemales
rename I Males18Over
rename J Females18Over
rename L MalesUnder1
rename M Males14
rename N Males59
rename O Males1014
rename P Males1519
rename Q Males2024
rename R Males2529
rename S Males3034
rename T Males3539
rename U Males4044
rename V Males4549
rename W Males5054
rename X Males5559
rename Y Males6064
rename Z Males6569
rename AA Males7074
rename AB Males7579
rename AC Males8084
rename AD Males85Over
rename AF FemalesUnder1
rename AG Females14
rename AH Females59
rename AI Females1014
rename AJ Females1519
rename AK Females2024
rename AL Females2529
rename AM Females3034
rename AN Females3539
rename AO Females4044
rename AP Females4549
rename AQ Females5054
rename AR Females5559
rename AS Females6064
rename AT Females6569
rename AU Females7074
rename AV Females7579
rename AW Females8084
rename AX Females85Over
drop H K AE	

	
append using `base'		
save 	`base', replace

* **************************************************************************************************
	
clear	
		
import excel "attr-data-gp-regi-pop-2010-fina-tab.xls", allstring sheet("PCOs") cellrange(B23:AY173) //England
	gen year="2010"	
	save `myfile', replace
	preserve
	clear		

import excel "attr-data-gp-regi-pop-2010-fina-tab.xls", allstring sheet("PCOs") cellrange(B181:AY187) //Wales
	gen year="2010"		
	save `myfile', replace
	restore
	append using `myfile'	

rename B SHACode
rename C ONSGeographyCode
rename D PCOCode
rename E PCOName
rename F Allpersons
rename G AllMales
rename H AllFemales
rename J Males18Over
rename K Females18Over
rename M MalesUnder1
rename N Males14
rename O Males59
rename P Males1014
rename Q Males1519
rename R Males2024
rename S Males2529
rename T Males3034
rename U Males3539
rename V Males4044
rename W Males4549
rename X Males5054
rename Y Males5559
rename Z Males6064
rename AA Males6569
rename AB Males7074
rename AC Males7579
rename AD Males8084
rename AE Males85Over
rename AG FemalesUnder1
rename AH Females14
rename AI Females59
rename AJ Females1014
rename AK Females1519
rename AL Females2024
rename AM Females2529
rename AN Females3034
rename AO Females3539
rename AP Females4044
rename AQ Females4549
rename AR Females5054
rename AS Females5559
rename AT Females6064
rename AU Females6569
rename AV Females7074
rename AW Females7579
rename AX Females8084
rename AY Females85Over
drop I L AF
	
	
	
	
append using `base'		
save 	`base', replace

* **************************************************************************************************
clear	
	
import excel "attr-data-gp-reg-pop-ons-esti-2011-data.xls", allstring sheet("PCOs") cellrange(B22:AX172) //England
	gen year="2011"	
	save `myfile', replace
	preserve
	clear

import excel "attr-data-gp-reg-pop-ons-esti-2011-data.xls", allstring sheet("PCOs") cellrange(B178:AX184) //Wales
	gen year="2011"		
	save `myfile', replace
	restore
	append using `myfile'	

			
rename B SHACode
rename C ONSGeographyCode
rename D PCOCode
rename E PCOName
rename F Allpersons
rename G AllMales
rename H AllFemales

rename J Males18Over
rename K Females18Over

rename M MalesUnder1
rename N Males14
rename O Males59
rename P Males1014
rename Q Males1519
rename R Males2024
rename S Males2529
rename T Males3034
rename U Males3539
rename V Males4044
rename W Males4549
rename X Males5054
rename Y Males5559
rename Z Males6064
rename AA Males6569
rename AB Males7074
rename AC Males7579
rename AD Males8084
rename AE Males85Over
rename AF FemalesUnder1
rename AG Females14
rename AH Females59
rename AI Females1014
rename AJ Females1519
rename AK Females2024
rename AL Females2529
rename AM Females3034
rename AN Females3539
rename AO Females4044
rename AP Females4549
rename AQ Females5054
rename AR Females5559
rename AS Females6064
rename AT Females6569
rename AU Females7074
rename AV Females7579
rename AW Females8084
rename AX Females85Over
drop I L	
	
append using `base'		
save 	`base', replace	
	
order year SHACode ONSGeographyCode PCOCode PCOName   	
	
destring year  Allpersons- Females85Over, replace ignore("," "-")

drop if SHACode=="WALES"

rename PCOCode pct_code
* *********************************************************
do "$scripts/99_pct_mergers_2006_2011_helper.do"
collapse (sum) Allpersons- Females85Over, by(year pct_code)
* *********************************************************
replace Males18Over=.   if Males18Over==0
replace Females18Over=. if Females18Over==0

rename pct_code pct152code

*encode  pct152code, gen(pctid)
*xtset pctid year
label data "Attribution dataset by PCT post 2006 (151 PCTs)"


save "AttributionDataset_panel152.dta", replace






log close

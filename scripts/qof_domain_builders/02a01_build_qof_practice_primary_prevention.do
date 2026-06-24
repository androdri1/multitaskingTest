/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: qof_domain_builders/02a01_build_qof_practice_primary_prevention.do
Language: Stata
Purpose: Recovered raw-to-Stata QOF domain builder.
Recovered original script: data/GPs/_sources/1.QoF_dos/QOF_01-GPprac-CVD-PP.do
Main output(s): QOFprimPrev-practicePanel.dta; QOF_collapsedPCT_primPrev.dta
Run order: called by scripts/02_prepare_qof_domain_data.do, after 00 and after PCT map files exist.
Notes: This script was ported from legacy paths to the replication-folder structure. It still
       expects the original public QOF Excel workbooks to be placed in the same year folders
       used by the recovered code under data/GPs/QoF practice level/ or
       data/GPs/Quality and Outcomes Framework Achievement Data/.
****************************************************************************************/

* Quality and Outcomes Framework (QOF) clinic domain data

clear all

cd "$dataGP/QoF practice level"


* Data from: http://www.hscic.gov.uk/qof
**************************************************************
**************************************************************
* Extract the info from Excel Files
clear all
tempfile myfile

* **********************************	
		
import excel "2009/qof-09-10-data-tab-prac-clin-card.xls", allstring sheet("QOF export") cellrange(A15:N8319)
	gen year="2009"	
	save `myfile', replace
	preserve
	clear			
		
	
import excel "2010/qof-10-11-data-tab-prac-clin-card.xls", allstring sheet("QOF export") cellrange(A15:N8259)
	gen year="2010"	
	save `myfile', replace
	restore
	append using `myfile'
	
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E pra_code
	rename F pra_name
	rename G pp01_points
	rename H pp01_numer
	rename I pp01_denom
	rename J pp01_achiev
	rename K pp02_points
	rename L pp02_numer
	rename M pp02_denom
	rename N pp02_achiev	
			
	preserve
	clear		

* 2011: Add the 1st part of the data	
import excel "2011/QOF-11-12-data-set-pracs-cardio.xls", allstring sheet("PP01") cellrange(A15:N8137)
	gen year="2011"	
	
	
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E pra_code
	rename F pra_name
	rename G pp01_points
	rename H pp01_numer
	rename I pp01_denom
	rename J pp01_achiev
	rename K pp01_excep
	rename L pp01_exrat
	rename M pp01_denEx
	rename N pp01_ppTrea
	save `myfile', replace
	clear
	* 2011: Add the 2nd part of the data
import excel "2011/QOF-11-12-data-set-pracs-cardio.xls", allstring sheet("PP02") cellrange(A15:N8137)
	gen year="2011"		
	
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E pra_code
	rename F pra_name	
	rename G pp02_points
	rename H pp02_numer
	rename I pp02_denom
	rename J pp02_achiev
	rename K pp02_excep
	rename L pp02_exrat
	rename M pp02_denEx
	rename N pp02_ppTrea

	merge 1:1 sha_code pct_code pra_code using `myfile', nogen
		
	save `myfile', replace
	restore
	append using `myfile'

/////////////////////////////////////////////////////////////	
preserve 

	/*
	* Around 4% of the practices (382) change of PCT
	keep sha_code pct_code  pra_code
	duplicates drop
	sort pra_code
	duplicates tag pra_code, gen(dups)
	list  pct_code  pra_code dups if dups>0
	drop dups
	*/

	keep if year=="2011"

	keep sha_code sha_name pct_code pct_name pra_code
	duplicates drop

	tempfile codesFile
	save `codesFile'

restore
/////////////////////////////////////////////////////////////
	
	
preserve

* 2012 pp02 data ****************************	
clear
import excel "2012/Clinical/qof-12-13-data-tab-prac-cardio-dis.xlsx", allstring sheet("PP02") cellrange(A15:P8034)
	gen year="2012"
	rename A region_code
	rename B region_name
	rename C at_code
	rename D at_name
	rename E ccg_code
	rename F ccg_name		
	rename G pra_code
	rename H pra_name
	rename I pp02_points
	rename J pp02_numer
	rename K pp02_denom
	rename L pp02_achiev
	rename M pp02_excep
	rename N pp02_exrat
	rename O pp02_denEx
	rename P pp02_ppTrea
	save `myfile', replace
	clear
	
* 2012 pp01 data ****************************	
import excel "2012/Clinical/qof-12-13-data-tab-prac-cardio-dis.xlsx", allstring sheet("PP01") cellrange(A15:P8034)
	gen year="2012"
	rename A region_code
	rename B region_name
	rename C at_code
	rename D at_name
	rename E ccg_code
	rename F ccg_name		
	rename G pra_code
	rename H pra_name
	rename I pp01_points
	rename J pp01_numer
	rename K pp01_denom
	rename L pp01_achiev
	rename M pp01_excep
	rename N pp01_exrat
	rename O pp01_denEx
	rename P pp01_ppTrea

	merge 1:1 region_code at_code ccg_code pra_code using `myfile', nogen
	merge 1:1 pra_code using `codesFile', nogen keep(match master)
		
	save `myfile', replace
restore
append using `myfile'
	
order year
destring  pp01_points-  pp01_ppTrea year, replace ignore("," "-")
order  sha_code sha_name pct_code pct_name  region_code region_name at_code at_name ccg_code ccg_name pra_code pra_name year  pp01* pp02*

replace pp01_achiev=pp01_achiev/100 if year==2012
replace pp02_achiev=pp02_achiev/100 if year==2012


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



label data "Quality of Output Framework (GP) by practice (PCT 152)"

save "QOFprimPrev-practicePanel.dta", replace


collapse (sum) pp01_numer pp01_denom pp02_numer pp02_denom , by(pct_code year)
drop if pct_code==""
gen pp01_achiev=pp01_numer/pp01_denom
gen pp02_achiev=pp02_numer/pp02_denom

save "QOF_collapsedPCT_primPrev.dta", replace



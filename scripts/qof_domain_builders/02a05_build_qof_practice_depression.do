/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: qof_domain_builders/02a05_build_qof_practice_depression.do
Language: Stata
Purpose: Recovered raw-to-Stata QOF domain builder.
Recovered original script: data/GPs/_sources/1.QoF_dos/QOF_01-GPprac-depr.do
Main output(s): QOFdepr-practicePanel.dta
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// 2009 data 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
preserve
clear
import excel "2009/qof-09-10-data-tab-prac-clin-depr.xls", allstring sheet("QOF export") cellrange(A15:R8319) //firstrow

gen year="2009"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G DEP01Points
rename H DEP01Numerator
rename I DEP01Denominator
rename J DEP01Achievement
rename K DEP02Points
rename L DEP02Numerator
rename M DEP02Denominator
rename N DEP02Achievement
rename O DEP03Points
rename P DEP03Numerator
rename Q DEP03Denominator
rename R DEP03Achievement


	save `myfile', replace
	clear
restore
append using `myfile'

/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// 2010 data 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
preserve
clear
import excel "2010/qof-09-10-data-tab-prac-clin-depr.xls", allstring sheet("QOF export") cellrange(A15:R8259) //firstrow

gen year="2010"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G DEP01Points
rename H DEP01Numerator
rename I DEP01Denominator
rename J DEP01Achievement
rename K DEP02Points
rename L DEP02Numerator
rename M DEP02Denominator
rename N DEP02Achievement
rename O DEP03Points
rename P DEP03Numerator
rename Q DEP03Denominator
rename R DEP03Achievement

save `myfile', replace
	clear
restore
append using `myfile'




/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// 2011 data 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
preserve


clear

tempfile elArchivo


foreach indi in "01" "04" "05" {

	clear
	import excel "2011/QOF-11-12-data-tab-pracs-dep.xls", allstring sheet("DEP`indi'") cellrange(A15:N8137) //firstrow

	gen year="2011"
	rename A SHACode
	rename B StrategicHealthAuthorityName
	rename C PCTCode
	rename D PCTName
	rename E pra_code
	rename F pra_name

	rename G DEP`indi'Points
	rename H DEP`indi'Numerator
	rename I DEP`indi'Denominator
	rename J DEP`indi'Achievement
	rename K DEP`indi'Exceptions
	rename L DEP`indi'ExceptionRate
	rename M DEP`indi'DenominatorPE
	rename N DEP`indi'AchievementPE

	if "`indi'"!="01" merge 1:1 SHACode StrategicHealthAuthorityName PCTCode PCTName pra_code pra_name using `elArchivo', nogen
	save `elArchivo', replace

}


save `myfile', replace
	clear
restore
append using `myfile'


/////////////////////////////////////////////////////////////////////////////////

order SHACode StrategicHealthAuthorityName PCTCode PCTName pra_code pra_name year

destring  year- DEP05AchievementPE, replace force
rename PCTCode pct_code
rename SHACode sha_code
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

* *********************************************************
* Let's deal with the PCT name and code
* 2003-2006: 303
* 2007-2013: 152

gen pct303code=pct_code if year<2006
merge n:1 pct303code using "$dataGP/Maps/ONS PCT code/PCT2006_303to152.dta" , keep(master match)  /* Get PCT standarized id */
tab _merge year // Good, 2005 and 2006 match properly
drop _merge

replace pct152code=pct_code if year>=2006
replace pct152name=PCTName if year>=2006

* *********************************************************
rename pct_code pct_codeX
rename pct152code pct_code
do "$scripts/99_pct_mergers_2006_2011_helper.do"
rename pct_code pct152code
rename pct_codeX pct_code
* *********************************************************

label data "Quality of Output Framework (GP) Depression by practice"

drop pra_name

save "QOFdepr-practicePanel.dta", replace





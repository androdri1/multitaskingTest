/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: qof_domain_builders/02a12_build_qof_practice_thyroid.do
Language: Stata
Purpose: Recovered raw-to-Stata QOF domain builder.
Recovered original script: data/GPs/_sources/1.QoF_dos/QOF_01-GPprac-thyroid.do
Main output(s): QOFthyroid-practicePanel.dta
Run order: called by scripts/02_prepare_qof_domain_data.do, after 00 and after PCT map files exist.
Notes: This script was ported from legacy paths to the replication-folder structure. It still
       expects the original public QOF Excel workbooks to be placed in the same year folders
       used by the recovered code under data/GPs/QoF practice level/ or
       data/GPs/Quality and Outcomes Framework Achievement Data/.
****************************************************************************************/

* Quality and Outcomes Framework (QOF) clinic domain data
* Hypothyroidism

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
import excel "2009/qof-09-10-data-tab-prac-clin-hypo.xls", allstring sheet("QOF export") cellrange(A15:K8319) //firstrow

gen year="2009"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G THYROI01Points
rename H THYROI02Points
rename I THYROI02Numerator
rename J THYROI02Denominator
rename K THYROI02Achievement

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
import excel "2010/qof-10-11-data-tab-prac-clin-hypo.xls", allstring sheet("QOF export") cellrange(A15:K8259) //firstrow

gen year="2010"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G THYROI01Points
rename H THYROI02Points
rename I THYROI02Numerator
rename J THYROI02Denominator
rename K THYROI02Achievement

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
import excel "2011/QOF-11-12-data-tab-pracs-thyroid.xls", allstring sheet("THYROI01") cellrange(A15:G8137) //firstrow

gen year="2011"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G THYROI01Points

tempfile elArchivo
save `elArchivo'

foreach indi in "02" {

	clear
	import excel "2011/QOF-11-12-data-tab-pracs-thyroid.xls", allstring sheet("THYROI`indi'") cellrange(A15:N8137) //firstrow

	gen year="2011"
	rename A SHACode
	rename B StrategicHealthAuthorityName
	rename C PCTCode
	rename D PCTName
	rename E pra_code
	rename F pra_name

	rename G THYROI`indi'Points
	rename H THYROI`indi'Numerator
	rename I THYROI`indi'Denominator
	rename J THYROI`indi'Achievement
	rename K THYROI`indi'Exceptions
	rename L THYROI`indi'ExceptionRate
	rename M THYROI`indi'DenominatorPE
	rename N THYROI`indi'AchievementPE

	if "`indi'"!="03" merge 1:1 SHACode StrategicHealthAuthorityName PCTCode PCTName pra_code pra_name using `elArchivo', nogen
	save `elArchivo', replace

}


save `myfile', replace
	clear
restore
append using `myfile'


/////////////////////////////////////////////////////////////////////////////////


order SHACode StrategicHealthAuthorityName PCTCode PCTName pra_code pra_name year

destring  year- THYROI02AchievementPE, replace force
rename PCTCode pct_code
rename SHACode sha_code
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

* *********************************************************
* Let's deal with the PCT name and code
* 2003-2006: 303
* 2007-2013: 152

gen pct303code=pct_code if year<2006
merge n:1 pct303code using "$dataGP/Maps/ONS PCT code/PCT2006_303to152.dta" , keep(master match)   /* Get PCT standarized id */
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


label data "Quality of Output Framework (GP) Hypothyroidism Data by practice"

drop pra_name

save "QOFthyroid-practicePanel.dta", replace





/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: qof_domain_builders/02a13_build_qof_practice_stroke.do
Language: Stata
Purpose: Recovered raw-to-Stata QOF domain builder.
Recovered original script: data/GPs/_sources/1.QoF_dos/QOF_01-GPprac-stroke.do
Main output(s): QOFstroke-practicePanel.dta
Run order: called by scripts/02_prepare_qof_domain_data.do, after 00 and after PCT map files exist.
Notes: This script was ported from legacy paths to the replication-folder structure. It still
       expects the original public QOF Excel workbooks to be placed in the same year folders
       used by the recovered code under data/GPs/QoF practice level/ or
       data/GPs/Quality and Outcomes Framework Achievement Data/.
****************************************************************************************/

* Quality and Outcomes Framework (QOF) clinic domain data
* Stroke

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
import excel "2009/qof-09-10-data-tab-prac-clin-stro.xls", allstring sheet("QOF export") cellrange(A15:AI8319) //firstrow

gen year="2009"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G STROKE01Points
rename H STROKE05Points
rename I STROKE05Numerator
rename J STROKE05Denominator
rename K STROKE05Achievement
rename L STROKE06Points
rename M STROKE06Numerator
rename N STROKE06Denominator
rename O STROKE06Achievement
rename P STROKE07Points
rename Q STROKE07Numerator
rename R STROKE07Denominator
rename S STROKE07Achievement
rename T STROKE08Points
rename U STROKE08Numerator
rename V STROKE08Denominator
rename W STROKE08Achievement
rename X STROKE10Points
rename Y STROKE10Numerator
rename Z STROKE10Denominator
rename AA STROKE10Achievement
rename AB STROKE12Points
rename AC STROKE12Numerator
rename AD STROKE12Denominator
rename AE STROKE12Achievement
rename AF STROKE13Points
rename AG STROKE13Numerator
rename AH STROKE13Denominator
rename AI STROKE13Achievement

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
import excel "2010/qof-10-11-data-tab-prac-clin-stro.xls", allstring sheet("QOF export") cellrange(A15:AI8259) //firstrow

gen year="2010"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G STROKE01Points
rename H STROKE05Points
rename I STROKE05Numerator
rename J STROKE05Denominator
rename K STROKE05Achievement
rename L STROKE06Points
rename M STROKE06Numerator
rename N STROKE06Denominator
rename O STROKE06Achievement
rename P STROKE07Points
rename Q STROKE07Numerator
rename R STROKE07Denominator
rename S STROKE07Achievement
rename T STROKE08Points
rename U STROKE08Numerator
rename V STROKE08Denominator
rename W STROKE08Achievement
rename X STROKE10Points
rename Y STROKE10Numerator
rename Z STROKE10Denominator
rename AA STROKE10Achievement
rename AB STROKE12Points
rename AC STROKE12Numerator
rename AD STROKE12Denominator
rename AE STROKE12Achievement
rename AF STROKE13Points
rename AG STROKE13Numerator
rename AH STROKE13Denominator
rename AI STROKE13Achievement


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
import excel "2011/QOF-11-12-data-tab-pracs-stroke.xls", allstring sheet("STROKE01") cellrange(A15:G8137) //firstrow

gen year="2011"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G STROKE01Points

tempfile elArchivo
save `elArchivo'

foreach indi in "06" "07" "08" "10" "12" "13" {

	clear
	import excel "2011/QOF-11-12-data-tab-pracs-stroke.xls", allstring sheet("STROKE`indi'") cellrange(A15:N8137) //firstrow

	gen year="2011"
	rename A SHACode
	rename B StrategicHealthAuthorityName
	rename C PCTCode
	rename D PCTName
	rename E pra_code
	rename F pra_name

	rename G STROKE`indi'Points
	rename H STROKE`indi'Numerator
	rename I STROKE`indi'Denominator
	rename J STROKE`indi'Achievement
	rename K STROKE`indi'Exceptions
	rename L STROKE`indi'ExceptionRate
	rename M STROKE`indi'DenominatorPE
	rename N STROKE`indi'AchievementPE

	merge 1:1 SHACode StrategicHealthAuthorityName PCTCode PCTName pra_code pra_name using `elArchivo', nogen
	save `elArchivo', replace

}


save `myfile', replace
	clear
restore
append using `myfile'


/////////////////////////////////////////////////////////////////////////////////


order SHACode StrategicHealthAuthorityName PCTCode PCTName pra_code pra_name year

destring  year- STROKE06AchievementPE, replace force
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

label data "Quality of Output Framework (GP) Stroke Data by practice"

drop pra_name

save "QOFstroke-practicePanel.dta", replace





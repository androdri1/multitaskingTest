/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: qof_domain_builders/02a19_build_qof_practice_domain_summary.do
Language: Stata
Purpose: Recovered raw-to-Stata QOF domain builder.
Recovered original script: data/GPs/_sources/1.QoF_dos/QOF_01-GPprac-domm.do
Main output(s): QOFdomm-practicePanel.dta
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

import excel "2009/qof-09-10-data-tab-prac-doma-summ.xls", allstring sheet("QOF export") cellrange(A15:P8319) //firstrow

gen year="2009"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G SUM_CLINICALPoints
rename H SUM_CLINICALAchievement
rename I SUM_ORGANPoints
rename J SUM_ORGANAchievement
rename K SUM_PATEXPPoints
rename L SUM_PATEXPAchievement
rename M SUM_ADDSERPoints
rename N SUM_ADDSERAchievement
rename O SUM_QOFPoints
rename P SUM_QOFAchievement

save `myfile', replace

/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// 2010 data 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
preserve
clear
import excel "2010/qof-10-11-data-tab-prac-doma-summ.xls", allstring sheet("QOF export") cellrange(A15:P8259) //firstrow

gen year="2010"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G SUM_CLINICALPoints
rename H SUM_CLINICALAchievement
rename I SUM_ORGANPoints
rename J SUM_ORGANAchievement
rename K SUM_PATEXPPoints
rename L SUM_PATEXPAchievement
rename M SUM_ADDSERPoints
rename N SUM_ADDSERAchievement
rename O SUM_QOFPoints
rename P SUM_QOFAchievement

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
import excel "2011/QOF-11-12-data-tab-pracs-dom-summ.xls", allstring sheet("QOF Export") cellrange(A15:R8138) //firstrow

gen year="2011"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G SUM_CLINICALPoints
rename H SUM_CLINICALAchievement
rename I SUM_ORGANPoints
rename J SUM_ORGANAchievement
rename K SUM_PATEXPPoints
rename L SUM_PATEXPAchievement
rename M SUM_ADDSERPoints
rename N SUM_ADDSERAchievement
rename O SUM_QOFPoints
rename P SUM_QOFAchievement
rename Q SUM_QOFAvbPoints
rename R SUM_QOFAvbAchievement

save `myfile', replace
	clear
restore
append using `myfile'


/////////////////////////////////////////////////////////////////////////////////

order SHACode StrategicHealthAuthorityName PCTCode PCTName pra_code pra_name year

destring  year- SUM_QOFAvbAchievement, replace force
rename PCTCode pct_code
rename SHACode sha_code

label var SUM_CLINICALPoints "Clinical Total Points"
label var SUM_CLINICALAchievement "Clinical Total Points / Available %"
label var SUM_ORGANPoints "Organisational Total Points"
label var SUM_ORGANAchievement "Organisational Total Points / Available %"
label var SUM_PATEXPPoints "Patient Experience Total Points"
label var SUM_PATEXPAchievement "Patient Experience Total Points / Available %"
label var SUM_ADDSERPoints "Additional Services Total Points"
label var SUM_ADDSERAchievement "Additional Services Total Points / Available %"
label var SUM_QOFPoints "QOF points total"
label var SUM_QOFAchievement "QOF Points Total / % Available"
label var SUM_QOFAvbPoints ""
label var SUM_QOFAvbAchievement ""


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

label data "Quality of Output Framework (GP) overall domain"

drop pra_name

save "QOFdomm-practicePanel.dta", replace





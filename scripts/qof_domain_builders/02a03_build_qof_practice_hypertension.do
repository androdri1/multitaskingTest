/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: qof_domain_builders/02a03_build_qof_practice_hypertension.do
Language: Stata
Purpose: Recovered raw-to-Stata QOF domain builder.
Recovered original script: data/GPs/_sources/1.QoF_dos/QOF_01-GPprac-Hyper.do
Main output(s): QOFhyper-practicePanel.dta
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

/*
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// 2004 data 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
		
import excel "2004/QOF0405_Practices_Diabetes_Eastern.xls", allstring sheet("Norfolk, Suffolk and Cambs") cellrange(A6:BE303) //firstrow

	save `myfile', replace
	clear			
import excel "2004/QOF0405_Practices_Diabetes_Eastern.xls", allstring sheet("Bedfordshire and Hertfordshire") cellrange(A6:BE233)
	append using `myfile'
	save `myfile', replace
	clear	
	
import excel "2004/QOF0405_Practices_Diabetes_Eastern.xls", allstring sheet("Essex") cellrange(A6:BE293)	
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_Eastern.xls", allstring sheet("Trent") cellrange(A6:BE418)	
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_Eastern.xls", allstring sheet("Leics, Northants and Rutland") cellrange(A6:BE234)	
append using `myfile'
	save `myfile', replace
	clear	
	
import excel "2004/QOF0405_Practices_Diabetes_London.xls", allstring sheet("North West London") cellrange(A6:BE439)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_London.xls", allstring sheet("North Central London") cellrange(A6:BE293)
append using `myfile'
	save `myfile', replace
	clear	
	
import excel "2004/QOF0405_Practices_Diabetes_London.xls", allstring sheet("North East London") cellrange(A6:BE372)	
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_London.xls", allstring sheet("South East London") cellrange(A6:BE292)	
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_London.xls", allstring sheet("South West London") cellrange(A6:BE237)	
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_NorthEast.xls", allstring sheet("Northumberland, Tyne and Wear") cellrange(A6:BE244)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_NorthEast.xls", allstring sheet("County Durham and Tees Valley") cellrange(A6:BE181)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_NorthEast.xls", allstring sheet("N and E Yorks and N Lincs") cellrange(A6:BE258)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_NorthEast.xls", allstring sheet("West Yorkshire") cellrange(A6:BE364)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_NorthEast.xls", allstring sheet("South Yorkshire") cellrange(A6:BE229)
append using `myfile'
	save `myfile', replace
	clear	

	
import excel "2004/QOF0405_Practices_Diabetes_NorthWest.xls", allstring sheet("Cumbria and Lancashire") cellrange(A6:BE363)
append using `myfile'
	save `myfile', replace
	clear		
	
import excel "2004/QOF0405_Practices_Diabetes_NorthWest.xls", allstring sheet("Greater Manchester") cellrange(A6:BE553)
append using `myfile'
	save `myfile', replace
	clear		
	
import excel "2004/QOF0405_Practices_Diabetes_NorthWest.xls", allstring sheet("Cheshire and Merseyside") cellrange(A6:BE433)
append using `myfile'
	save `myfile', replace
	clear		
		
import excel "2004/QOF0405_Practices_Diabetes_NorthWest.xls", allstring sheet("Shropshire and Staffordshire") cellrange(A6:BE267)
append using `myfile'
	save `myfile', replace
	clear		
			
import excel "2004/QOF0405_Practices_Diabetes_NorthWest.xls", allstring sheet("Birmingham and Black Country") cellrange(A6:BE520)
append using `myfile'
	save `myfile', replace
	clear		
				
import excel "2004/QOF0405_Practices_Diabetes_NorthWest.xls", allstring sheet("West Midlands South") cellrange(A6:BE235)
append using `myfile'
	save `myfile', replace
	clear		
	
import excel "2004/QOF0405_Practices_Diabetes_Southern.xls", allstring sheet("Thames Valley") cellrange(A6:BE291)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_Southern.xls", allstring sheet("Hampshire and Isle Of Wight") cellrange(A6:BE236)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_Southern.xls", allstring sheet("Kent and Medway") cellrange(A6:BE299)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_Southern.xls", allstring sheet("Surrey and Sussex") cellrange(A6:BE371)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_Southern.xls", allstring sheet("Avon, Gloucestershire and Wilts") cellrange(A6:BE323)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_Southern.xls", allstring sheet("South West Peninsula") cellrange(A6:BE253)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2004/QOF0405_Practices_Diabetes_Southern.xls", allstring sheet("Dorset and Somerset") cellrange(A6:BE182)
append using `myfile'


gen year="2004"	

rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F Diabetes1Points
rename G Diabetes2Numerator
rename H Diabetes2Denominator
rename I Diabetes2Points
rename J Diabetes3Numerator
rename K Diabetes3Denominator
rename L Diabetes3Points
rename M Diabetes4Numerator
rename N Diabetes4Denominator
rename O Diabetes4Points
rename P Diabetes5Numerator
rename Q Diabetes5Denominator
rename R Diabetes5Points
rename S Diabetes6Numerator
rename T Diabetes6Denominator
rename U Diabetes6Points
rename V Diabetes7Numerator
rename W Diabetes7Denominator
rename X Diabetes7Points
rename Y Diabetes8Numerator
rename Z Diabetes8Denominator
rename AA Diabetes8Points
rename AB Diabetes9Numerator
rename AC Diabetes9Denominator
rename AD Diabetes9Points
rename AE Diabetes10Numerator
rename AF Diabetes10Denominator
rename AG Diabetes10Points
rename AH Diabetes11Numerator
rename AI Diabetes11Denominator
rename AJ Diabetes11Points
rename AK Diabetes12Numerator
rename AL Diabetes12Denominator
rename AM Diabetes12Points
rename AN Diabetes13Numerator
rename AO Diabetes13Denominator
rename AP Diabetes13Points
rename AQ Diabetes14Numerator
rename AR Diabetes14Denominator
rename AS Diabetes14Points
rename AT Diabetes15Numerator
rename AU Diabetes15Denominator
rename AV Diabetes15Points
rename AW Diabetes16Numerator
rename AX Diabetes16Denominator
rename AY Diabetes16Points
rename AZ Diabetes17Numerator
rename BA Diabetes17Denominator
rename BB Diabetes17Points
rename BC Diabetes18Numerator
rename BD Diabetes18Denominator
rename BE Diabetes18Points

/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// 2005 data 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
preserve

tempfile myfile
clear
import excel "2005/qof-eng-05-06-gp-tab-clin-east-diab.xls", allstring sheet("Norfolk__Suffolk_and_Cambridges") cellrange(A14:BE305) 

	save `myfile', replace
	clear			
import excel "2005/qof-eng-05-06-gp-tab-clin-east-diab.xls", allstring sheet("Bedfordshire_and_Hertfordshire_") cellrange(A14:BE236)
	append using `myfile'
	save `myfile', replace
	clear	
	
import excel "2005/qof-eng-05-06-gp-tab-clin-east-diab.xls", allstring sheet("Essex_") cellrange(A14:BE295)	
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-east-diab.xls", allstring sheet("Trent_") cellrange(A14:BE420)	
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-east-diab.xls", allstring sheet("Leicestershire__Northamptonshir") cellrange(A14:BE240)	
append using `myfile'
	save `myfile', replace
	clear	
	
import excel "2005/qof-eng-05-06-gp-tab-clin-lond-diab.xls", allstring sheet("North_West_London_") cellrange(A14:BE445)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-lond-diab.xls", allstring sheet("North_Central_London_") cellrange(A14:BE286)
append using `myfile'
	save `myfile', replace
	clear	
	
import excel "2005/qof-eng-05-06-gp-tab-clin-lond-diab.xls", allstring sheet("North_East_London_") cellrange(A14:BE363)	
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-lond-diab.xls", allstring sheet("South_East_London_") cellrange(A14:BE298)	
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-lond-diab.xls", allstring sheet("South_West_London_") cellrange(A14:BE245)	
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-ne-diab.xls", allstring sheet("Northumberland__Tyne___Wear_") cellrange(A14:BE246)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-ne-diab.xls", allstring sheet("County_Durham_and_Tees_Valley_") cellrange(A14:BE185)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-ne-diab.xls", allstring sheet("North_and_East_Yorkshire_and_No") cellrange(A14:BE263)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-ne-diab.xls", allstring sheet("West_Yorkshire_") cellrange(A14:BE361)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-ne-diab.xls", allstring sheet("South_Yorkshire_") cellrange(A14:BE235)
append using `myfile'
	save `myfile', replace
	clear	

	
import excel "2005/qof-eng-05-06-gp-tab-clin-nw-diab.xls", allstring sheet("Cumbria_and_Lancashire_") cellrange(A14:BE357)
append using `myfile'
	save `myfile', replace
	clear		
	
import excel "2005/qof-eng-05-06-gp-tab-clin-nw-diab.xls", allstring sheet("Greater_Manchester_") cellrange(A14:BE549)
append using `myfile'
	save `myfile', replace
	clear		
	
import excel "2005/qof-eng-05-06-gp-tab-clin-nw-diab.xls", allstring sheet("Cheshire___Merseyside_") cellrange(A14:BE430)
append using `myfile'
	save `myfile', replace
	clear		
		
import excel "2005/qof-eng-05-06-gp-tab-clin-nw-diab.xls", allstring sheet("Shropshire_and_Staffordshire_") cellrange(A14:BE271)
append using `myfile'
	save `myfile', replace
	clear		
			
import excel "2005/qof-eng-05-06-gp-tab-clin-nw-diab.xls", allstring sheet("Birmingham_and_the_Black_Countr") cellrange(A14:BE511)
append using `myfile'
	save `myfile', replace
	clear		
				
import excel "2005/qof-eng-05-06-gp-tab-clin-nw-diab.xls", allstring sheet("West_Midlands_South_") cellrange(A14:BE242)
append using `myfile'
	save `myfile', replace
	clear		
	
import excel "2005/qof-eng-05-06-gp-tab-clin-sout-diab.xls", allstring sheet("Thames_Valley_") cellrange(A14:BE295)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-sout-diab.xls", allstring sheet("Hampshire_and_Isle_Of_Wight_") cellrange(A14:BE243)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-sout-diab.xls", allstring sheet("Kent_and_Medway_") cellrange(A14:BE297)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-sout-diab.xls", allstring sheet("Surrey_and_Sussex_") cellrange(A14:BE374)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-sout-diab.xls", allstring sheet("Avon__Gloucestershire_and_Wilts") cellrange(A14:BE328)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-sout-diab.xls", allstring sheet("South_West_Peninsula_") cellrange(A14:BE262)
append using `myfile'
	save `myfile', replace
	clear	

import excel "2005/qof-eng-05-06-gp-tab-clin-sout-diab.xls", allstring sheet("Dorset_and_Somerset_") cellrange(A14:BE191)
append using `myfile'

gen year="2005"

rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F Diabetes1Points
rename G Diabetes2Numerator
rename H Diabetes2Denominator
rename I Diabetes2Points
rename J Diabetes3Numerator
rename K Diabetes3Denominator
rename L Diabetes3Points
rename M Diabetes4Numerator
rename N Diabetes4Denominator
rename O Diabetes4Points
rename P Diabetes5Numerator
rename Q Diabetes5Denominator
rename R Diabetes5Points
rename S Diabetes6Numerator
rename T Diabetes6Denominator
rename U Diabetes6Points
rename V Diabetes7Numerator
rename W Diabetes7Denominator
rename X Diabetes7Points
rename Y Diabetes8Numerator
rename Z Diabetes8Denominator
rename AA Diabetes8Points
rename AB Diabetes9Numerator
rename AC Diabetes9Denominator
rename AD Diabetes9Points
rename AE Diabetes10Numerator
rename AF Diabetes10Denominator
rename AG Diabetes10Points
rename AH Diabetes11Numerator
rename AI Diabetes11Denominator
rename AJ Diabetes11Points
rename AK Diabetes12Numerator
rename AL Diabetes12Denominator
rename AM Diabetes12Points
rename AN Diabetes13Numerator
rename AO Diabetes13Denominator
rename AP Diabetes13Points
rename AQ Diabetes14Numerator
rename AR Diabetes14Denominator
rename AS Diabetes14Points
rename AT Diabetes15numerator
rename AU Diabetes15Denominator
rename AV Diabetes15Points
rename AW Diabetes16Numerator
rename AX Diabetes16Denominator
rename AY Diabetes16Points
rename AZ Diabetes17Numerator
rename BA Diabetes17Denominator
rename BB Diabetes17Points
rename BC Diabetes18Numerator
rename BD Diabetes18Denominator
rename BE Diabetes18Points


	save `myfile', replace
	clear
restore
append using `myfile'

*/
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// 2006 data 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
preserve
clear
import excel "2006/qof-eng-06-07-prac-tabs-clin-dom-hype.xls", allstring sheet("Sheet1") cellrange(A5:L8376) //firstrow

gen year="2006"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F Hyper1Points
rename G Hyper4Numerator
rename H Hyper4Denominator
rename I Hyper4Points
rename J Hyper5Numerator
rename K Hyper5Denominator
rename L Hyper5Points

	save `myfile', replace
	clear
restore
append using `myfile'

/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// 2007 data 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
preserve
clear
import excel "2007/qof-eng-07-08-prac-tabs-clin-dom-hype.xls", allstring sheet("Sheet1") cellrange(A14:L8307) //firstrow

gen year="2007"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F Hyper1Points
rename G Hyper4Numerator
rename H Hyper4Denominator
rename I Hyper4Points
rename J Hyper5Numerator
rename K Hyper5Denominator
rename L Hyper5Points

	save `myfile', replace
	clear
restore
append using `myfile'

/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// 2008 data 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
preserve
clear
import excel "2008/qof-eng-08-09-prac-tabs-clin-dom-hype.xls", allstring sheet("QOF export") cellrange(A15:O8243) //firstrow

gen year="2008"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name
rename G Hyper1Points
rename H Hyper4Points
rename I Hyper4Numerator
rename J Hyper4Denominator
rename K Hyper4Achievement
rename L Hyper5Points
rename M Hyper5Numerator
rename N Hyper5Denominator
rename O Hyper5Achievement

	save `myfile', replace
	clear
restore
append using `myfile'

/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// 2009 data 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
preserve
clear
import excel "2009/qof-09-10-data-tab-prac-clin-hype.xls", allstring sheet("QOF export") cellrange(A15:O8319) //firstrow

gen year="2009"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name
rename G Hyper1Points
rename H Hyper4Points
rename I Hyper4Numerator
rename J Hyper4Denominator
rename K Hyper4Achievement
rename L Hyper5Points
rename M Hyper5Numerator
rename N Hyper5Denominator
rename O Hyper5Achievement

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
import excel "2010/qof-10-11-data-tab-prac-clin-hype.xls", allstring sheet("QOF export") cellrange(A15:O8259) //firstrow

gen year="2010"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name
rename G Hyper1Points
rename H Hyper4Points
rename I Hyper4Numerator
rename J Hyper4Denominator
rename K Hyper4Achievement
rename L Hyper5Points
rename M Hyper5Numerator
rename N Hyper5Denominator
rename O Hyper5Achievement

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
import excel "2011/QOF-11-12-data-tab-pracs-hyper.xls", allstring sheet("BP01") cellrange(A15:G8137) //firstrow

gen year="2011"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G Hyper1Points

tempfile elArchivo
save `elArchivo'

foreach indi in 4 5 {

	clear
	import excel "2011/QOF-11-12-data-tab-pracs-hyper.xls", allstring sheet("BP0`indi'") cellrange(A15:N8137) //firstrow

	gen year="2011"
	rename A SHACode
	rename B StrategicHealthAuthorityName
	rename C PCTCode
	rename D PCTName
	rename E pra_code
	rename F pra_name

	rename G Hyper`indi'Points
	rename H Hyper`indi'Numerator
	rename I Hyper`indi'Denominator
	rename J Hyper`indi'Achievement
	rename K Hyper`indi'Exceptions
	rename L Hyper`indi'ExceptionRate
	rename M Hyper`indi'DenominatorPE
	rename N Hyper`indi'AchievementPE

	merge 1:1 SHACode StrategicHealthAuthorityName PCTCode PCTName pra_code pra_name using `elArchivo', nogen
	save `elArchivo', replace

}


save `myfile', replace
	clear
restore
append using `myfile'


/////////////////////////////////////////////////////////////////////////////////

order SHACode StrategicHealthAuthorityName PCTCode PCTName pra_code pra_name year

destring  year- Hyper5Achievement, replace force
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

label data "Quality of Output Framework (GP) Hypertension Data by practice"

drop pra_name

save "QOFhyper-practicePanel.dta", replace





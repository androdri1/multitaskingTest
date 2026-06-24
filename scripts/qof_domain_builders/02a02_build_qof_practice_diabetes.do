/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: qof_domain_builders/02a02_build_qof_practice_diabetes.do
Language: Stata
Purpose: Recovered raw-to-Stata QOF domain builder.
Recovered original script: data/GPs/_sources/1.QoF_dos/QOF_01-GPprac-Diab.do
Main output(s): QOFdiabetes-practicePanel.dta
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////	
// 2006 data 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
preserve
clear
import excel "2006/qof-eng-06-07-prac-tabs-clin-dom-diab.xls", allstring sheet("Sheet1") cellrange(A5:AY8376) //firstrow

gen year="2006"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F Diabetes1Points
rename G Diabetes2Numerator
rename H Diabetes2Denominator
rename I Diabetes2Points
rename J Diabetes5Numerator
rename K Diabetes5Denominator
rename L Diabetes5Points
rename M Diabetes7Numerator
rename N Diabetes7Denominator
rename O Diabetes7Points
rename P Diabetes9Numerator
rename Q Diabetes9Denominator
rename R Diabetes9Points
rename S Diabetes10Numerator
rename T Diabetes10Denominator
rename U Diabetes10Points
rename V Diabetes11Numerator
rename W Diabetes11Denominator
rename X Diabetes11Points
rename Y Diabetes12Numerator
rename Z Diabetes12Denominator
rename AA Diabetes12Points
rename AB Diabetes13Numerator
rename AC Diabetes13Denominator
rename AD Diabetes13Points
rename AE Diabetes15numerator
rename AF Diabetes15Denominator
rename AG Diabetes15Points
rename AH Diabetes16Numerator
rename AI Diabetes16Denominator
rename AJ Diabetes16Points
rename AK Diabetes17Numerator
rename AL Diabetes17Denominator
rename AM Diabetes17Points
rename AN Diabetes18Numerator
rename AO Diabetes18Denominator
rename AP Diabetes18Points
rename AQ Diabetes20Numerator
rename AR Diabetes20Denominator
rename AS Diabetes20Points
rename AT Diabetes21Numerator
rename AU Diabetes21Denominator
rename AV Diabetes21Points
rename AW Diabetes22Numerator
rename AX Diabetes22Denominator
rename AY Diabetes22Points

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
import excel "2007/qof-eng-07-08-prac-tabs-clin-dom-diab.xls", allstring sheet("Sheet1") cellrange(A14:AY8307) //firstrow

gen year="2007"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F Diabetes1Points
rename G Diabetes2Numerator
rename H Diabetes2Denominator
rename I Diabetes2Points
rename J Diabetes5Numerator
rename K Diabetes5Denominator
rename L Diabetes5Points
rename M Diabetes7Numerator
rename N Diabetes7Denominator
rename O Diabetes7Points
rename P Diabetes9Numerator
rename Q Diabetes9Denominator
rename R Diabetes9Points
rename S Diabetes10Numerator
rename T Diabetes10Denominator
rename U Diabetes10Points
rename V Diabetes11Numerator
rename W Diabetes11Denominator
rename X Diabetes11Points
rename Y Diabetes12Numerator
rename Z Diabetes12Denominator
rename AA Diabetes12Points
rename AB Diabetes13Numerator
rename AC Diabetes13Denominator
rename AD Diabetes13Points
rename AE Diabetes15numerator
rename AF Diabetes15Denominator
rename AG Diabetes15Points
rename AH Diabetes16Numerator
rename AI Diabetes16Denominator
rename AJ Diabetes16Points
rename AK Diabetes17Numerator
rename AL Diabetes17Denominator
rename AM Diabetes17Points
rename AN Diabetes18Numerator
rename AO Diabetes18Denominator
rename AP Diabetes18Points
rename AQ Diabetes20Numerator
rename AR Diabetes20Denominator
rename AS Diabetes20Points
rename AT Diabetes21Numerator
rename AU Diabetes21Denominator
rename AV Diabetes21Points
rename AW Diabetes22Numerator
rename AX Diabetes22Denominator
rename AY Diabetes22Points


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
import excel "2008/qof-eng-08-09-prac-tabs-clin-dom-diab.xls", allstring sheet("QOF export") cellrange(A15:BO8243) //firstrow

gen year="2008"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name
rename G Diabetes1Points
rename H Diabetes2Points
rename I Diabetes2Numerator
rename J Diabetes2Denominator
rename K Diabetes2Achievement
rename L Diabetes5Points
rename M Diabetes5Numerator
rename N Diabetes5Denominator
rename O Diabetes5Achievement
rename P Diabetes7Points
rename Q Diabetes7Numerator
rename R Diabetes7Denominator
rename S Diabetes7Achievement
rename T Diabetes9Points
rename U Diabetes9Numerator
rename V Diabetes9Denominator
rename W Diabetes9Achievement
rename X Diabetes10Points
rename Y Diabetes10Numerator
rename Z Diabetes10Denominator
rename AA Diabetes10Achievement
rename AB Diabetes11Points
rename AC Diabetes11Numerator
rename AD Diabetes11Denominator
rename AE Diabetes11Achievement
rename AF Diabetes12Points
rename AG Diabetes12Numerator
rename AH Diabetes12Denominator
rename AI Diabetes12Achievement
rename AJ Diabetes13Points
rename AK Diabetes13Numerator
rename AL Diabetes13Denominator
rename AM Diabetes13Achievement
rename AN Diabetes15Points
rename AO Diabetes15numerator
rename AP Diabetes15Denominator
rename AQ Diabetes15Achievement
rename AR Diabetes16Points
rename AS Diabetes16Numerator
rename AT Diabetes16Denominator
rename AU Diabetes16Achievement
rename AV Diabetes17Points
rename AW Diabetes17Numerator
rename AX Diabetes17Denominator
rename AY Diabetes17Achievement
rename AZ Diabetes18Points
rename BA Diabetes18Numerator
rename BB Diabetes18Denominator
rename BC Diabetes18Achievement
rename BD Diabetes20Points
rename BE Diabetes20Numerator
rename BF Diabetes20Denominator
rename BG Diabetes20Achievement
rename BH Diabetes21Points
rename BI Diabetes21Numerator
rename BJ Diabetes21Denominator
rename BK Diabetes21Achievement
rename BL Diabetes22Points
rename BM Diabetes22Numerator
rename BN Diabetes22Denominator
rename BO Diabetes22Achievement



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
import excel "2009/qof-09-10-data-tab-prac-clin-diab.xls", allstring sheet("QOF export") cellrange(A15:BS8319) //firstrow

gen year="2009"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name
rename G Diabetes1Points
rename H Diabetes2Points
rename I Diabetes2Numerator
rename J Diabetes2Denominator
rename K Diabetes2Achievement
rename L Diabetes5Points
rename M Diabetes5Numerator
rename N Diabetes5Denominator
rename O Diabetes5Achievement
rename P Diabetes9Points
rename Q Diabetes9Numerator
rename R Diabetes9Denominator
rename S Diabetes9Achievement
rename T Diabetes10Points
rename U Diabetes10Numerator
rename V Diabetes10Denominator
rename W Diabetes10Achievement
rename X Diabetes11Points
rename Y Diabetes11Numerator
rename Z Diabetes11Denominator
rename AA Diabetes11Achievement
rename AB Diabetes12Points
rename AC Diabetes12Numerator
rename AD Diabetes12Denominator
rename AE Diabetes12Achievement
rename AF Diabetes13Points
rename AG Diabetes13Numerator
rename AH Diabetes13Denominator
rename AI Diabetes13Achievement
rename AJ Diabetes15Points
rename AK Diabetes15numerator
rename AL Diabetes15Denominator
rename AM Diabetes15Achievement
rename AN Diabetes16Points
rename AO Diabetes16Numerator
rename AP Diabetes16Denominator
rename AQ Diabetes16Achievement
rename AR Diabetes17Points
rename AS Diabetes17Numerator
rename AT Diabetes17Denominator
rename AU Diabetes17Achievement
rename AV Diabetes18Points
rename AW Diabetes18Numerator
rename AX Diabetes18Denominator
rename AY Diabetes18Achievement
rename AZ Diabetes21Points
rename BA Diabetes21Numerator
rename BB Diabetes21Denominator
rename BC Diabetes21Achievement
rename BD Diabetes22Points
rename BE Diabetes22Numerator
rename BF Diabetes22Denominator
rename BG Diabetes22Achievement
rename BH Diabetes23Points
rename BI Diabetes23Numerator
rename BJ Diabetes23Denominator
rename BK Diabetes23Achievement
rename BL Diabetes24Points
rename BM Diabetes24Numerator
rename BN Diabetes24Denominator
rename BO Diabetes24Achievement
rename BP Diabetes25Points
rename BQ Diabetes25Numerator
rename BR Diabetes25Denominator
rename BS Diabetes25Achievement

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
import excel "2010/qof-10-11-data-tab-prac-clin-diab.xls", allstring sheet("QOF export") cellrange(A15:BS8259) //firstrow

gen year="2010"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name
rename G Diabetes1Points
rename H Diabetes2Points
rename I Diabetes2Numerator
rename J Diabetes2Denominator
rename K Diabetes2Achievement
rename L Diabetes5Points
rename M Diabetes5Numerator
rename N Diabetes5Denominator
rename O Diabetes5Achievement
rename P Diabetes9Points
rename Q Diabetes9Numerator
rename R Diabetes9Denominator
rename S Diabetes9Achievement
rename T Diabetes10Points
rename U Diabetes10Numerator
rename V Diabetes10Denominator
rename W Diabetes10Achievement
rename X Diabetes11Points
rename Y Diabetes11Numerator
rename Z Diabetes11Denominator
rename AA Diabetes11Achievement
rename AB Diabetes12Points
rename AC Diabetes12Numerator
rename AD Diabetes12Denominator
rename AE Diabetes12Achievement
rename AF Diabetes13Points
rename AG Diabetes13Numerator
rename AH Diabetes13Denominator
rename AI Diabetes13Achievement
rename AJ Diabetes15Points
rename AK Diabetes15numerator
rename AL Diabetes15Denominator
rename AM Diabetes15Achievement
rename AN Diabetes16Points
rename AO Diabetes16Numerator
rename AP Diabetes16Denominator
rename AQ Diabetes16Achievement
rename AR Diabetes17Points
rename AS Diabetes17Numerator
rename AT Diabetes17Denominator
rename AU Diabetes17Achievement
rename AV Diabetes18Points
rename AW Diabetes18Numerator
rename AX Diabetes18Denominator
rename AY Diabetes18Achievement
rename AZ Diabetes21Points
rename BA Diabetes21Numerator
rename BB Diabetes21Denominator
rename BC Diabetes21Achievement
rename BD Diabetes22Points
rename BE Diabetes22Numerator
rename BF Diabetes22Denominator
rename BG Diabetes22Achievement
rename BH Diabetes23Points
rename BI Diabetes23Numerator
rename BJ Diabetes23Denominator
rename BK Diabetes23Achievement
rename BL Diabetes24Points
rename BM Diabetes24Numerator
rename BN Diabetes24Denominator
rename BO Diabetes24Achievement
rename BP Diabetes25Points
rename BQ Diabetes25Numerator
rename BR Diabetes25Denominator
rename BS Diabetes25Achievement


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
import excel "2011/QOF-11-12-data-tabs-pracs-diab-mel.xls", allstring sheet("DM02") cellrange(A15:N8137) //firstrow

gen year="2011"
rename A SHACode
rename B StrategicHealthAuthorityName
rename C PCTCode
rename D PCTName
rename E pra_code
rename F pra_name

rename G Diabetes2Points
rename H Diabetes2Numerator
rename I Diabetes2Denominator
rename J Diabetes2Achievement
rename K Diabetes2Exceptions
rename L Diabetes2ExceptionRate
rename M Diabetes2DenominatorPE
rename N Diabetes2AchievementPE

tempfile elArchivo
save `elArchivo'

foreach indi in 10 13 15 17 18 19 21 22 26 27 28 29 30 31 {

	clear
	import excel "2011/QOF-11-12-data-tabs-pracs-diab-mel.xls", allstring sheet("DM`indi'") cellrange(A15:N8137) //firstrow

	gen year="2011"
	rename A SHACode
	rename B StrategicHealthAuthorityName
	rename C PCTCode
	rename D PCTName
	rename E pra_code
	rename F pra_name

	rename G Diabetes`indi'Points
	rename H Diabetes`indi'Numerator
	rename I Diabetes`indi'Denominator
	rename J Diabetes`indi'Achievement
	rename K Diabetes`indi'Exceptions
	rename L Diabetes`indi'ExceptionRate
	rename M Diabetes`indi'DenominatorPE
	rename N Diabetes`indi'AchievementPE

	merge 1:1 SHACode StrategicHealthAuthorityName PCTCode PCTName pra_code pra_name using `elArchivo', nogen
	save `elArchivo', replace

}


save `myfile', replace
	clear
restore
append using `myfile'





/////////////////////////////////////////////////////////////////////////////////

order SHACode StrategicHealthAuthorityName PCTCode PCTName pra_code pra_name year

destring  year- Diabetes31AchievementPE, replace force
rename PCTCode pct_code
rename SHACode sha_code
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
* *********************************************************

* *********************************************************
* Let's deal with the PCT name and code
* 2003-2006: 303
* 2007-2013: 152

gen pct303code=pct_code if year<2006
merge n:1 pct303code using "$dataGP/Maps/ONS PCT code/PCT2006_303to152.dta", keep(master match)   /* Get PCT standarized id */
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




label data "Quality of Output Framework (GP) Diabetes Data by practice"

drop pra_name

save "QOFdiabetes-practicePanel.dta", replace





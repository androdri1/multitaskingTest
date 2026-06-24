/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: qof_domain_builders/02b01_optional_build_qof_pct_clinical_domain.do
Language: Stata
Purpose: Recovered raw-to-Stata QOF domain builder.
Recovered original script: data/GPs/_sources/1.QoF_dos/QOF_02-PCT-ClinicDomain.do
Main output(s): QOFclinicDom-PCT_nopanel.dta; QOFclinicDom-PCT_panel152.dta
Run order: called by scripts/02_prepare_qof_domain_data.do, after 00 and after PCT map files exist.
Notes: This script was ported from legacy paths to the replication-folder structure. It still
       expects the original public QOF Excel workbooks to be placed in the same year folders
       used by the recovered code under data/GPs/QoF practice level/ or
       data/GPs/Quality and Outcomes Framework Achievement Data/.
****************************************************************************************/

* Quality and Outcomes Framework (QOF) clinic domain data

clear all

cd "$dataGP/Quality and Outcomes Framework Achievement Data"




* Data from: http://www.hscic.gov.uk/qof
**************************************************************
**************************************************************
* Extract the info from Excel Files
clear all
tempfile myfile
import excel "2004-2005/qof-eng-04-05-achi-data-pct-clin.xls", allstring sheet("PCTs Clinical Summary") cellrange(A6:AA308)
	gen year="2004"	
	preserve
	clear

	
import excel "2005-2006/qof-eng-05-06-achi-data-pct-clini.xls", allstring sheet("PCTs Clinical Summary") cellrange(A14:AA316)
	gen year="2005"	
	save `myfile', replace
	restore
	append using `myfile'
	
			
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E practices
	rename F coronary_points
	rename G coronary_achiv
	rename H disfunct_points
	rename I disfunct_achiv
	rename J strokeh_points
	rename K strokeh_achiv
	rename L hypert_points
	rename M hypert_achiv
	rename N diabet_points
	rename O diabet_achiv
	rename P pulmon_points
	rename Q pulmon_achiv
	rename R epilep_points
	rename S epilep_achiv
	rename T hypoty_points
	rename U hypoty_achiv
	rename V cancer_points
	rename W cancer_achiv
	rename X menhea_points
	rename Y menhea_achiv
	rename Z asthma_points
	rename AA asthma_achiv

	tempfile part1
	save `part1', replace	
	clear
	
* ********************************	
* Change in the number of PCTs
	
import excel "2006-2007/QOF0607_PCTs_ClinicalSummary.xls", allstring sheet("PCTs Clinical Summary") cellrange(A14:AQ165)
	gen year="2006"	
	preserve
	clear	
	
import excel "2007-2008/qof-eng-07-08-pct-tabs-clin-summ.xls", allstring sheet("Sheet1") cellrange(A15:AQ166)
	gen year="2007"	
	save `myfile', replace
	restore
	append using `myfile'
			
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E practices
	rename F coronary_points
	rename G coronary_achiv
	rename H herfai_points
	rename I herfai_achiv
	rename J strokeh_points
	rename K strokeh_achiv
	rename L hypert_points
	rename M hypert_achiv
	rename N diabet_points
	rename O diabet_achiv
	rename P pulmon_points
	rename Q pulmon_achiv
	rename R epilep_points
	rename S epilep_achiv
	rename T hypoty_points
	rename U hypoty_achiv
	rename V cancer_points
	rename W cancer_achiv
	rename X palliat_points
	rename Y palliat_achiv
	rename Z menhea_points
	rename AA menhea_achiv
	rename AB asthma_points
	rename AC asthma_achiv
	rename AD demen_points
	rename AE demen_achiv
	rename AF depres_points
	rename AG depres_achiv
	rename AH kidney_points
	rename AI kidney_achiv
	rename AJ atrial_points
	rename AK atrial_achiv
	rename AL obesit_points
	rename AM obesit_achiv
	rename AN leardi_points
	rename AO leardi_achiv
	rename AP smoke_points
	rename AQ smoke_achiv	

	* Add the 1st part of the data
	append using `part1'	
	
	preserve
	clear
	
* **********************************	
		
import excel "2008-2009/qof-eng-08-09-pct-tabs-clin-dom-lvl-summ.xls", allstring sheet("QOF export") cellrange(A15:AQ166)
	gen year="2008"	
			
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E practices
	rename F coronary_points
	rename G coronary_achiv
	rename H strokeh_points
	rename I strokeh_achiv
	rename J hypert_points
	rename K hypert_achiv
	rename L diabet_points
	rename M diabet_achiv
	rename N pulmon_points
	rename O pulmon_achiv
	rename P epilep_points
	rename Q epilep_achiv
	rename R hypoty_points
	rename S hypoty_achiv
	rename T cancer_points
	rename U cancer_achiv
	rename V menhea_points
	rename W menhea_achiv
	rename X asthma_points
	rename Y asthma_achiv
	rename Z herfai_points
	rename AA herfai_achiv
	rename AB palliat_points
	rename AC palliat_achiv
	rename AD demen_points
	rename AE demen_achiv
	rename AF depres_points
	rename AG depres_achiv
	rename AH kidney_points
	rename AI kidney_achiv
	rename AJ atrial_points
	rename AK atrial_achiv
	rename AL obesit_points
	rename AM obesit_achiv
	rename AN leardi_points
	rename AO leardi_achiv
	rename AP smoke_points
	rename AQ smoke_achiv
	
	save `myfile', replace
	restore
	append using `myfile'
	
	
	tempfile part2
	save `part2', replace		
	clear			
	
* **********************************	
		
import excel "2009-2010/qof-09-10-data-tab-pct-clin-summ.xls", allstring sheet("QOF export") cellrange(A15:AS166)
	gen year="2009"	
	save `myfile', replace
	preserve
	clear			
		
	
import excel "2010-2011/qof-10-11-data-tab-pct-clin-summ.xls", allstring sheet("QOF export") cellrange(A15:AS165)
	gen year="2010"	
	save `myfile', replace
	restore
	append using `myfile'
	preserve
	clear			
			
import excel "2011-2012/QOF-11-12-PCTs-clinsum.xls", allstring sheet("QOF Export") cellrange(A15:AS165)
	gen year="2011"	
	save `myfile', replace
	restore
	append using `myfile'
	
		
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E practices
	rename F coronary_points
	rename G coronary_achiv
	rename H strokeh_points
	rename I strokeh_achiv
	rename J hypert_points
	rename K hypert_achiv
	rename L diabet_points
	rename M diabet_achiv
	rename N pulmon_points
	rename O pulmon_achiv
	rename P epilep_points
	rename Q epilep_achiv
	rename R hypoty_points
	rename S hypoty_achiv
	rename T cancer_points
	rename U cancer_achiv
	rename V menhea_points
	rename W menhea_achiv
	rename X asthma_points
	rename Y asthma_achiv
	rename Z herfai_points
	rename AA herfai_achiv
	rename AB palliat_points
	rename AC palliat_achiv
	rename AD demen_points
	rename AE demen_achiv
	rename AF depres_points
	rename AG depres_achiv
	rename AH kidney_points
	rename AI kidney_achiv
	rename AJ atrial_points
	rename AK atrial_achiv
	rename AL obesit_points
	rename AM obesit_achiv
	rename AN leardi_points
	rename AO leardi_achiv
	rename AP smoke_points
	rename AQ smoke_achiv
	rename AR cvdpre_points
	rename AS cvdpre_achiv

	
	* Add the 2nd part of the data
	append using `part2'		
	
	
	
// Add 2012 data!!!	
	
destring  practices- disfunct_achiv year, replace ignore("," "-")

destring year, replace


* *********************************************************
* Let's deal with the PCT name and code
* 2003-2006: 303
* 2007-2013: 152

gen pct303code=pct_code if year<2006
merge n:1 pct303code using "$dataGP/Maps/ONS PCT code/PCT2006_303to152.dta"   /* Get PCT standarized id */
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


label data "Quality of Output Framework (GP) by PCT without panel"
order sha_code sha_name pct_code pct_name pct303code pct303name pct152code pct152name year


label var practices "Number of Practices"
label var coronary_points "Coronary Heart Disease Total Points"
label var coronary_achiv "Coronary Heart Disease Total Points / Available "
label var strokeh_points "Stroke or Transient Ischaemic Attacks (TIA) Total Points"
label var strokeh_achiv "Stroke or Transient Ischaemic Attacks (TIA) Total Points / Available "
label var hypert_points "Hypertension Total Points"
label var hypert_achiv "Hypertension Total Points / Available "
label var diabet_points "Diabetes Mellitus (Diabetes) Total Points"
label var diabet_achiv "Diabetes Mellitus (Diabetes) Total Points / Available "
label var pulmon_points "Chronic Obstructive Pulmonary Disease Total Points"
label var pulmon_achiv "Chronic Obstructive Pulmonary Disease Total Points / Available "
label var epilep_points "Epilepsy Total Points"
label var epilep_achiv "Epilepsy Total Points / Available "
label var hypoty_points "Hypothyroidism Total Points"
label var hypoty_achiv "Hypothyroidism Total Points / Available "
label var cancer_points "Cancer Total Points"
label var cancer_achiv "Cancer Total Points / Available "
label var menhea_points "Mental Health Total Points"
label var menhea_achiv "Mental Health Total Points / Available "
label var asthma_points "Asthma Total Points"
label var asthma_achiv "Asthma Total Points / Available "
label var herfai_points "Heart Failure Total Points"
label var herfai_achiv "Heart Failure Total Points / Available "
label var palliat_points "Palliative Care Total Points"
label var palliat_achiv "Palliative Care Total Points / Available "
label var demen_points "Dementia Total Points"
label var demen_achiv "Dementia Total Points / Available "
label var depres_points "Depression Total Points"
label var depres_achiv "Depression Total Points / Available "
label var kidney_points "Chronic Kidney Disease Total Points"
label var kidney_achiv "Chronic Kidney Disease Total Points / Available "
label var atrial_points "Atrial Fibrillation Total Points"
label var atrial_achiv "Atrial Fibrillation Total Points / Available "
label var obesit_points "Obesity Total Points"
label var obesit_achiv "Obesity Total Points / Available "
label var leardi_points "Learning Disabilities Total Points"
label var leardi_achiv "Learning Disabilities Total Points / Available "
label var smoke_achiv "Smoking Total Points"
label var smoke_points "Smoking Total Points / Available "
label var cvdpre_achiv "Cardiovascular Disease Primary Prevention Total Points"
label var cvdpre_points "Cardiovascular Disease Primary Prevention Total Points / Available "


save "QOFclinicDom-PCT_nopanel.dta", replace
* ********************************************************

collapse (sum)  practices (mean) *_achiv , by(pct152code year)

encode  pct152code, gen(pctid)
xtset pctid year
label data "Quality of Output Framework (GP) by PCT post 2006 (151 PCTs)"

label var practices "Number of Practices"
label var coronary_achiv "Coronary Heart Disease Total Points / Available "
label var strokeh_achiv "Stroke or Transient Ischaemic Attacks (TIA) Total Points / Available "
label var hypert_achiv "Hypertension Total Points / Available "
label var diabet_achiv "Diabetes Mellitus (Diabetes) Total Points / Available "
label var pulmon_achiv "Chronic Obstructive Pulmonary Disease Total Points / Available "
label var epilep_achiv "Epilepsy Total Points / Available "
label var hypoty_achiv "Hypothyroidism Total Points / Available "
label var cancer_achiv "Cancer Total Points / Available "
label var menhea_achiv "Mental Health Total Points / Available "
label var asthma_achiv "Asthma Total Points / Available "
label var herfai_achiv "Heart Failure Total Points / Available "
label var palliat_achiv "Palliative Care Total Points / Available "
label var demen_achiv "Dementia Total Points / Available "
label var depres_achiv "Depression Total Points / Available "
label var kidney_achiv "Chronic Kidney Disease Total Points / Available "
label var atrial_achiv "Atrial Fibrillation Total Points / Available "
label var obesit_achiv "Obesity Total Points / Available "
label var leardi_achiv "Learning Disabilities Total Points / Available "
label var smoke_achiv "Smoking  Total Points / Available"
label var cvdpre_achiv "Cardiovascular Disease Primary Prevention  Total Points / Available"

save "QOFclinicDom-PCT_panel152.dta", replace

/*
keep listgp pctid year list practices

reshape wide listgp list practices, i(pctid) j(year)
*/



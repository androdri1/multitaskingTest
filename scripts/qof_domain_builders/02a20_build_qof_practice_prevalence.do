/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: qof_domain_builders/02a20_build_qof_practice_prevalence.do
Language: Stata
Purpose: Recovered raw-to-Stata QOF domain builder.
Recovered original script: data/GPs/_sources/1.QoF_dos/QOF_01-GPprac-Prevalences.do
Main output(s): QOFprevalence-practicePanel.dta; QOF_ccg_to_pct.dta; QOF_collapsedPCT_prev.dta
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

// 2005 prevalence data are split by region and PCT sheet in the public workbooks.

* **********************************	

import excel "2006/qof-eng-06-07-prac-tabs-prev.xls", allstring sheet("Sheet1") cellrange(A5:AN8376)
	gen year="2006"	
			
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E pra_code
	rename F list
	rename G coronary_regcount
	rename H coronary_unaprev
	rename I strokeh_regcount
	rename J strokeh_unaprev
	rename K hypert_regcount
	rename L hypert_unaprev
	rename M diabet_regcount
	rename N diabet_unaprev
	rename O pulmon_regcount
	rename P pulmon_unaprev
	rename Q epilep_regcount
	rename R epilep_unaprev
	rename S hypoty_regcount
	rename T hypoty_unaprev
	rename U cancer_regcount
	rename V cancer_unaprev
	rename W menhea_regcount
	rename X menhea_unaprev
	rename Y asthma_regcount
	rename Z asthma_unaprev
	rename AA herfai_regcount
	rename AB herfai_unaprev	
	rename AC palliat_regcount
	rename AD palliat_unaprev
	rename AE demen_regcount
	rename AF demen_unaprev
	rename AG kidney_regcount
	rename AH kidney_unaprev
	rename AI atrial_regcount
	rename AJ atrial_unaprev
	rename AK obesit_regcount
	rename AL obesit_unaprev
	rename AM leardi_regcount
	rename AN leardi_unaprev

* **********************************	
preserve
	clear
import excel "2007/qof-eng-07-08-prac-tabs-prev.xls", allstring sheet("Sheet1") cellrange(A14:AN8307)
	gen year="2007"		
		
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E pra_code
	rename F list
	rename G coronary_regcount
	rename H coronary_unaprev
	rename I strokeh_regcount
	rename J strokeh_unaprev
	rename K hypert_regcount
	rename L hypert_unaprev
	rename M diabet_regcount
	rename N diabet_unaprev
	rename O pulmon_regcount
	rename P pulmon_unaprev
	rename Q epilep_regcount
	rename R epilep_unaprev
	rename S hypoty_regcount
	rename T hypoty_unaprev
	rename U cancer_regcount
	rename V cancer_unaprev
	rename W menhea_regcount
	rename X menhea_unaprev
	rename Y asthma_regcount
	rename Z asthma_unaprev
	rename AA herfai_regcount
	rename AB herfai_unaprev
	rename AC palliat_regcount
	rename AD palliat_unaprev
	rename AE demen_regcount
	rename AF demen_unaprev
	rename AG kidney_regcount
	rename AH kidney_unaprev
	rename AI atrial_regcount
	rename AJ atrial_unaprev
	rename AK obesit_regcount
	rename AL obesit_unaprev
	rename AM leardi_regcount
	rename AN leardi_unaprev	
	save `myfile', replace
restore
append using `myfile'	

preserve
clear			
				
* *********************************		
		
import excel "2008/qof-eng-08-09-prac-tabs-prev.xls", allstring sheet("All QOF Registers") cellrange(A15:AW8243)
	gen year="2008"		
	save `myfile', replace
	clear

		
import excel "2009/qof-09-10-data-tab-prev-prac.xls", allstring sheet("Practices") cellrange(A15:AY8319)
	gen year="2009"		
	append using `myfile'	
	save `myfile', replace
	clear

	
import excel "2010/qof-10-11-data-tab-prev-prac.xls", allstring sheet("Practice prevalence") cellrange(A15:AY8259)
	gen year="2010"	
	append using `myfile'	
	save `myfile', replace
	clear
	

import excel "2011/qual-outc-fram-11-12-prac-prev.xls", allstring sheet("Practice_Prevalence") cellrange(A15:AY8137)
	gen year="2011"	
	append using `myfile'	
			
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E pra_code
	rename F pra_name
	rename G list
	rename H coronary_regcount
	rename I coronary_unaprev
	rename J strokeh_regcount
	rename K strokeh_unaprev
	rename L hypert_regcount
	rename M hypert_unaprev
	rename N diabet_regcount
	rename O diabet_unaprev
	rename P pulmon_regcount
	rename Q pulmon_unaprev
	rename R epilep_regcount
	rename S epilep_unaprev
	rename T hypoty_regcount
	rename U hypoty_unaprev
	rename V cancer_regcount
	rename W cancer_unaprev
	rename X menhea_regcount
	rename Y menhea_unaprev
	rename Z asthma_regcount
	rename AA asthma_unaprev
	rename AB herfai_regcount
	rename AC herfai_unaprev
	rename AD herfa2_regcount
	rename AE herfa2_unaprev
	rename AF palliat_regcount
	rename AG palliat_unaprev
	rename AH demen_regcount
	rename AI demen_unaprev
	rename AJ depres_regcount
	rename AK depres_unaprev
	rename AL depre1_regcount
	rename AM depre1_unaprev
	rename AN kidney_regcount
	rename AO kidney_unaprev
	rename AP atrial_regcount
	rename AQ atrial_unaprev
	rename AR obesit_regcount
	rename AS obesit_unaprev
	rename AT leardi_regcount
	rename AU leardi_unaprev
	rename AV smoke_regcount
	rename AW smoke_unaprev
	rename AX cvdpre_regcount	
	rename AY cvdpre_unaprev
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
	clear		
	
* ********************************
	
import excel "2012/Prevalence/qof-12-13-data-tab-prac-prev.xlsx", allstring sheet("Prac_Prevalence") cellrange(A15:BE8034)
	gen year="2012"	

	rename A region_code
	rename B region_name
	rename C at_code
	rename D at_name
	rename E ccg_code
	rename F ccg_name
	rename G pra_code
	rename H pra_name
	rename I list
	rename J coronary_regcount
	rename K coronary_unaprev
	rename L strokeh_regcount
	rename M strokeh_unaprev
	rename N hypert_regcount
	rename O hypert_unaprev
	rename P diabet_regcount
	rename Q diabet_unaprev
	rename R pulmon_regcount
	rename S pulmon_unaprev
	rename T epilep_regcount
	rename U epilep_unaprev
	rename V hypoty_regcount
	rename W hypoty_unaprev
	rename X cancer_regcount
	rename Y cancer_unaprev
	rename Z menhea_regcount
	rename AA menhea_unaprev
	rename AB asthma_regcount
	rename AC asthma_unaprev
	rename AD herfai_regcount
	rename AE herfai_unaprev
	rename AF herfa2_regcount
	rename AG herfa2_unaprev
	rename AH palliat_regcount
	rename AI palliat_unaprev
	rename AJ demen_regcount
	rename AK demen_unaprev
	rename AL depres_regcount
	rename AM depres_unaprev
	rename AN depre1_regcount
	rename AO depre1_unaprev
	rename AP kidney_regcount
	rename AQ kidney_unaprev
	rename AR atrial_regcount
	rename AS atrial_unaprev
	rename AT obesit_regcount
	rename AU obesit_unaprev
	rename AV leardi_regcount
	rename AW leardi_unaprev
	rename AX smoke_regcount
	rename AY smoke_unaprev
	rename AZ cvdpre_regcount
	rename BA cvdpre_unaprev
	rename BB padpre_regcount
	rename BC padpre_unaprev
	rename BD osteop_regcount
	rename BE osteop_unaprev
	
	merge 1:1 pra_code using `codesFile', nogen keep(match master)
	
	save `myfile', replace
		
	restore
	append using `myfile'	
	
	
* ********************************	
order year

destring year list- osteop_unaprev, replace ignore("," "-")
order  sha_code sha_name pct_code pct_name  region_code region_name at_code at_name ccg_code ccg_name pra_code pra_name year  

xx

foreach varDep in coronary strokeh hypert diabet pulmon epilep hypoty cancer menhea asthma herfai herfa2 palliat demen depres kidney atrial obesit leardi smoke cvdpre padpre osteop {
	desc `varDep'_unaprev
	replace `varDep'_unaprev=`varDep'_unaprev/100 if year==2012
	sum `varDep'_unaprev
	*assert r(max)<1
	gen `varDep'_denom = `varDep'_regcount/`varDep'_unaprev
}

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
replace pct152name=pct_name if year>=2006

* *********************************************************
rename pct_code pct_codeX
rename pct152code pct_code
do "$scripts/99_pct_mergers_2006_2011_helper.do"
rename pct_code pct152code
rename pct_codeX pct_code
* *********************************************************


label data "Quality of Output Framework (GP) by practice (PCT 152, CCG)"


save "QOFprevalence-practicePanel.dta", replace

***********************************************
* Generates an equivalence table between CCG (254) and PCT (152) according to practice (might be imprecisse)
preserve

keep if year==2012
keep ccg_code ccg_name sha_code sha_name pct_code pct_name pct152code pct152name
duplicates drop
drop if pct_code=="" | ccg_code==""
// Now, there are practices that went into different areas,
// something that makes hard to compare them with the past
// The issue is that admin data at PCT/CCG level does not
// apply if I recofigure all based on practice level data
duplicates tag ccg_code, gen(dups)
*br if dups>=1
// Harsh solution: keep only those which might properly
drop if dups>=1
drop dups

label data "Equivalence, ONLY pcts and ccgs that match properly (133 PCTs)"

save "QOF_ccg_to_pct.dta", replace

restore
***********************************************

collapse (sum) list *_regcount *_denom , by(pct152code year)

foreach varDep in coronary strokeh hypert diabet pulmon epilep hypoty cancer menhea asthma herfai herfa2 palliat demen depres kidney atrial obesit leardi smoke cvdpre padpre osteop {
	gen `varDep'_unaprev = `varDep'_regcount/`varDep'_denom
}

save "QOF_collapsedPCT_prev.dta", replace


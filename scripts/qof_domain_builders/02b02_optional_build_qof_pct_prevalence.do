/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: qof_domain_builders/02b02_optional_build_qof_pct_prevalence.do
Language: Stata
Purpose: Recovered raw-to-Stata QOF domain builder.
Recovered original script: data/GPs/_sources/1.QoF_dos/QOF_02-PCT-Prevalences.do
Main output(s): QOFGP-PCT_nopanel.dta; QOFGP-PCT_panel152.dta
Run order: called by scripts/02_prepare_qof_domain_data.do, after 00 and after PCT map files exist.
Notes: This script was ported from legacy paths to the replication-folder structure. It still
       expects the original public QOF Excel workbooks to be placed in the same year folders
       used by the recovered code under data/GPs/QoF practice level/ or
       data/GPs/Quality and Outcomes Framework Achievement Data/.
****************************************************************************************/

* Quality and Outcomes Framework (QOF) prevalences data
* at PCT level (YOU NEED TO RUN FIRST THE practice level to get
* an equivalence between CCGs and PCTs in 2012 data)

clear all

cd "$dataGP/Quality and Outcomes Framework Achievement Data"




* Data from: http://www.hscic.gov.uk/qof
**************************************************************
**************************************************************
* Extract the info from Excel Files
clear all
tempfile myfile
import excel "2004-2005/qof-eng-04-05-data-pct-dise.xls", allstring sheet("PCTs Prevalence") cellrange(A6:AB308)
	gen year="2004"	
	preserve
	clear

	
import excel "2005-2006/qof-eng-05-06-achi-data-gp-pct-dise.xls", allstring sheet("PCTs Prevalence") cellrange(A14:AB316)
	gen year="2005"	
	save `myfile', replace
	restore
	append using `myfile'
	
		
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E practices
	rename F list
	rename G coronary_regcount
	rename H coronary_unaprev
	rename I disfunct_regcount
	rename J disfunct_unaprev
	rename K strokeh_regcount
	rename L strokeh_unaprev
	rename M hypert_regcount
	rename N hypert_unaprev
	rename O diabet_regcount
	rename P diabet_unaprev
	rename Q pulmon_regcount
	rename R pulmon_unaprev
	rename S epilep_regcount
	rename T epilep_unaprev
	rename U hypoty_regcount
	rename V hypoty_unaprev
	rename W cancer_regcount
	rename X cancer_unaprev
	rename Y menhea_regcount
	rename Z menhea_unaprev
	rename AA asthma_regcount
	rename AB asthma_unaprev

	tempfile part1
	save `part1', replace	
	clear
	
* ********************************	
* Change in the number of PCTs
	
import excel "2006-2007/QOF0607_PCTs_Prevalence.xls", allstring sheet("PCTs Prevalence") cellrange(A14:AN165)
	gen year="2006"	
	preserve
	clear	
	
import excel "2007-2008/qof-eng-07-08-pct-tabs-prev.xls", allstring sheet("Sheet1") cellrange(A15:AN166)
	gen year="2007"	
	save `myfile', replace
	restore
	append using `myfile'
		
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E practices
	rename F list
	rename G coronary_regcount
	rename H coronary_unaprev
	rename I herfai_regcount
	rename J herfai_unaprev
	rename K strokeh_regcount
	rename L strokeh_unaprev
	rename M hypert_regcount
	rename N hypert_unaprev
	rename O diabet_regcount
	rename P diabet_unaprev
	rename Q pulmon_regcount
	rename R pulmon_unaprev
	rename S epilep_regcount
	rename T epilep_unaprev
	rename U hypoty_regcount
	rename V hypoty_unaprev
	rename W cancer_regcount
	rename X cancer_unaprev
	rename Y palliat_regcount
	rename Z palliat_unaprev
	rename AA menhea_regcount
	rename AB menhea_unaprev
	rename AC asthma_regcount
	rename AD asthma_unaprev
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

	* Add the 1st part of the data
	append using `part1'	
	
	preserve
	clear
	
* **********************************	
		
import excel "2008-2009/qof-eng-08-09-pct-tabs-prev.xls", allstring sheet("All QOF Registers") cellrange(A15:AV166)
	gen year="2008"	
		
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E practices
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
	rename AC herfa2_regcount
	rename AD herfa2_unaprev
	rename AE palliat_regcount
	rename AF palliat_unaprev
	rename AG demen_regcount
	rename AH demen_unaprev
	rename AI depres_regcount
	rename AJ depres_unaprev
	rename AK depre1_regcount
	rename AL depre1_unaprev
	rename AM kidney_regcount
	rename AN kidney_unaprev
	rename AO atrial_regcount
	rename AP atrial_unaprev
	rename AQ obesit_regcount
	rename AR obesit_unaprev
	rename AS leardi_regcount
	rename AT leardi_unaprev
	rename AU smoke_regcount
	rename AV smoke_unaprev
	
	
	save `myfile', replace
	restore
	append using `myfile'
	
	
	tempfile part2
	save `part2', replace		
	clear			
	
* **********************************	
		
import excel "2009-2010/qof-09-10-data-tab-prev-pct.xls", allstring sheet("PCTs") cellrange(A15:AX166)
	gen year="2009"	
	save `myfile', replace
	preserve
	clear			
		
	
import excel "2010-2011/qof-10-11-data-tab-prev-pct.xls", allstring sheet("PCT Prevalence") cellrange(A15:AX165)
	gen year="2010"	
	save `myfile', replace
	restore
	append using `myfile'
	preserve
	clear			
			
import excel "2011-2012/qual-outc-fram-11-12-pcts-prev.xls", allstring sheet("PCT_Prevalence") cellrange(A15:AX165)
	gen year="2011"	
	save `myfile', replace
	restore
	append using `myfile'
	
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E practices
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
	rename AC herfa2_regcount
	rename AD herfa2_unaprev
	rename AE palliat_regcount
	rename AF palliat_unaprev
	rename AG demen_regcount
	rename AH demen_unaprev
	rename AI depres_regcount
	rename AJ depres_unaprev
	rename AK depre1_regcount
	rename AL depre1_unaprev
	rename AM kidney_regcount
	rename AN kidney_unaprev
	rename AO atrial_regcount
	rename AP atrial_unaprev
	rename AQ obesit_regcount
	rename AR obesit_unaprev
	rename AS leardi_regcount
	rename AT leardi_unaprev
	rename AU smoke_regcount
	rename AV smoke_unaprev	
	rename AW cvdpre_regcount
	rename AX cvdpre_unaprev	

	* Add the 2nd part of the data
	append using `part2'		
	preserve
	clear			
			
*****************************************************************			
			
clear			
			
import excel "2012-2013/Prevalence/qof-12-13-data-tab-ccg-prev.xlsx", allstring sheet("CCG_Prevalence") cellrange(A15:BD225)
	gen year="2012"	
			
	rename A region_code
	rename B region_name
	rename C at_code
	rename D at_name
	rename E ccg_code
	rename F ccg_name
	rename G practices
	rename H list
	rename I coronary_regcount
	rename J coronary_unaprev
	rename K strokeh_regcount
	rename L strokeh_unaprev
	rename M hypert_regcount
	rename N hypert_unaprev
	rename O diabet_regcount
	rename P diabet_unaprev
	rename Q pulmon_regcount
	rename R pulmon_unaprev
	rename S epilep_regcount
	rename T epilep_unaprev
	rename U hypoty_regcount
	rename V hypoty_unaprev
	rename W cancer_regcount
	rename X cancer_unaprev
	rename Y menhea_regcount
	rename Z menhea_unaprev
	rename AA asthma_regcount
	rename AB asthma_unaprev
	rename AC herfai_regcount
	rename AD herfai_unaprev
	rename AE herfa2_regcount
	rename AF herfa2_unaprev
	rename AG palliat_regcount
	rename AH palliat_unaprev
	rename AI demen_regcount
	rename AJ demen_unaprev
	rename AK depres_regcount
	rename AL depres_unaprev
	rename AM depre1_regcount
	rename AN depre1_unaprev
	rename AO kidney_regcount
	rename AP kidney_unaprev
	rename AQ atrial_regcount
	rename AR atrial_unaprev
	rename AS obesit_regcount
	rename AT obesit_unaprev
	rename AU leardi_regcount
	rename AV leardi_unaprev	
	rename AW smoke_regcount
	rename AX smoke_unaprev
	rename AY cvdpre_regcount
	rename AZ cvdpre_unaprev
	rename BA padpre_regcount
	rename BB padpre_unaprev
	rename BC osteop_regcount
	rename BD osteop_unaprev

	// Add pct information
	merge n:1 ccg_code using "$dataGP/QoF practice level/QOF_ccg_to_pct.dta", keep(match master) nogen
	
	save `myfile', replace
	restore
	append using `myfile'	
	
	
destring  practices-osteop_unaprev year, replace ignore("," "-")

destring year, replace

foreach varDep in coronary strokeh hypert diabet pulmon epilep hypoty cancer menhea asthma herfai herfa2 palliat demen depres kidney atrial obesit leardi cvdpre padpre {
	replace `varDep'_unaprev=`varDep'_unaprev/100 if year==2012
	sum `varDep'_unaprev
	assert r(max)<1
	gen `varDep'_denom = `varDep'_regcount/`varDep'_unaprev
}

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

save "QOFGP-PCT_nopanel.dta", replace
* ********************************************************

collapse (sum)  practices list *_regcount , by(pct152code year)

encode  pct152code, gen(pctid)
xtset pctid year
*xtline  listgp, ov

label data "Quality of Output Framework (GP) by PCT post 2006 (151 PCTs)"


save "QOFGP-PCT_panel152.dta", replace

/*
keep listgp pctid year list practices

reshape wide listgp list practices, i(pctid) j(year)
*/



/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: qof_domain_builders/02b03_optional_build_qof_pct_primary_prevention.do
Language: Stata
Purpose: Recovered raw-to-Stata QOF domain builder.
Recovered original script: data/GPs/_sources/1.QoF_dos/QOF_02-PCT-PrimaryPrevention.do
Main output(s): QOFprimPrev-PCT_panel152.dta
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

/*
CVD-PP001. In those patients with a new diagnosis of
hypertension aged 30 or over and under the age of 75,
recorded between the preceding 1 April to 31 March
(excluding those with pre-existing CHD, diabetes, stroke
and/or TIA), who have a recorded CVD risk assessment score
(using an assessment tool agreed with the NHS CB) of =20%
in the preceding 12 months: the percentage who are
currently treated with statins

CVD-PP002. The percentage of patients diagnosed with
hypertension (diagnosed on or after 1 April 2009) who are
given lifestyle advice in the preceding 12 months for:
smoking cessation, safe alcohol consumption and healthy
diet
*/

**************************************************************
**************************************************************
* Extract the info from Excel Files
clear all
tempfile myfile
import excel "2009-2010/qof-09-10-data-tab-pct-clin-card.xls", allstring sheet("QOF export") cellrange(A15:M166)
	gen year="2009"	
	save `myfile', replace
	preserve
	clear			
		
	
import excel "2010-2011/qof-10-11-data-tab-pct-clin-card.xls", allstring sheet("QOF export") cellrange(A15:M165)
	gen year="2010"	
	save `myfile', replace
	restore
	append using `myfile'
	
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E practices
	rename F pp01_points
	rename G pp01_numer
	rename H pp01_denom
	rename I pp01_achiev
	rename J pp02_points
	rename K pp02_numer
	rename L pp02_denom
	rename M pp02_achiev

	preserve
	clear		

* 2011: Add the 1st part of the data	
import excel "2011-2012/QOF-11-12-PCTs-cardio.xls", allstring sheet("PP01") cellrange(A15:M165)
	gen year="2011"	
	
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E practices
	rename F pp01_points
	rename G pp01_numer
	rename H pp01_denom
	rename I pp01_achiev
	rename J pp01_excep
	rename K pp01_exrat
	rename L pp01_denEx
	rename M pp01_ppTrea
	save `myfile', replace
	clear
	* 2011: Add the 2nd part of the data
import excel "2011-2012/QOF-11-12-PCTs-cardio.xls", allstring sheet("PP02") cellrange(A15:M165)
	gen year="2011"		
	
	rename A sha_code
	rename B sha_name
	rename C pct_code
	rename D pct_name
	rename E practices
	rename F pp02_points
	rename G pp02_numer
	rename H pp02_denom
	rename I pp02_achiev
	rename J pp02_excep
	rename K pp02_exrat
	rename L pp02_denEx
	rename M pp02_ppTrea

	merge 1:1 sha_code pct_code  using `myfile', nogen
		
	save `myfile', replace
	restore
	append using `myfile'
	
	
// ADD 2012 data!!!!!!	
	

destring  practices-  pp01_ppTrea year, replace ignore("," "-")
order  sha_code sha_name pct_code pct_name year  practices pp01* pp02*

* *********************************************************
do "$scripts/99_pct_mergers_2006_2011_helper.do"

collapse (sum) pp01_points pp01_numer pp01_denom pp01_excep pp01_denEx pp02_points pp02_numer pp02_denom pp02_excep pp02_denEx, by(year pct_code)
* *********************************************************
replace pp01_excep=. if year<2011
replace pp01_denEx=. if year<2011
replace pp02_excep=. if year<2011
replace pp02_denEx=. if year<2011

gen pp01_achiev=pp01_numer/pp01_denom
gen pp02_achiev=pp02_numer/pp02_denom

gen pp01_exrat= pp01_excep/ pp01_denEx
gen pp01_ppTrea = pp01_numer / pp01_denEx
gen pp02_exrat= pp02_excep/ pp02_denEx
gen pp02_ppTrea = pp02_numer / pp02_denEx


gen pct152code=pct_code

encode  pct152code, gen(pctid)
xtset pctid year
xtline  pp01_achiev, ov

label data "Quality of Output Framework (GP) by PCT post 2006 (151 PCTs)"


save "QOFprimPrev-PCT_panel152.dta", replace



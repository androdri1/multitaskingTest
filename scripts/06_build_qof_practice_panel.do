/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 06_build_qof_practice_panel.do
Language: Stata
Purpose: Merge QOF practice-level clinical domain files, prevalence files, GP directory
         files and static practice characteristics to build the analysis input panel.
Inputs expected under data/GPs:
  - QoF practice level/QOFprimPrev-practicePanel.dta
  - QoF practice level/QOFdiabetes-practicePanel.dta, QOFhyper-practicePanel.dta, ...
  - QoF practice level/QOFprevalence-practicePanel.dta
  - GPsdirectory/moredocreg/gp_egpcur.dta
  - National General Practice Profiles/NationalGeneralPracticeProfiles.dta
  - Modelled Prevalences/mhyp_practices.dta
  - Static IC Indicators 2011/GPstaticChars2011.dta
  - GIS/GPaddress.dta
Output:
  - data/derived/QOFpracticePanel.dta
Paper outputs: no figure/table directly; creates the panel used by the empirical scripts.
Run order: after 01_prepare_gp_source_data.do; before 07_analysis_bunching_and_results.do.
****************************************************************************************/

cap log close
clear all
set more off

* -----------------------------------------------------------------------------
* Portable replication paths
* IMPORTANT: before running, open Stata and cd to the root Rep_folder.
* -----------------------------------------------------------------------------
global root        "`c(pwd)'"
global scripts     "$root/scripts"
global dataGP      "$root/data/GPs"
global dataDerived "$root/data/derived"
global tableFold   "$root/output/tables"
global imageFold   "$root/output/figures"
global logsFold    "$root/output/logs"

cap mkdir "$dataDerived"
cap mkdir "$tableFold"
cap mkdir "$imageFold"
cap mkdir "$logsFold"

global main "$dataGP"
cd "$dataGP/QoF practice level"
global pra_controls "cont_PMS cont_other yrsexpIndi gp_1000p ONS_ruralD_*"
global genOpts `"  graphregion(color(white) lwidth(medium)) scheme(lean2) "'

log using "$logsFold/06_build_qof_practice_panel.log", replace text

// -----------------------------------------------------------------------------
// Builds: data/derived/QOFpracticePanel.dta
// Paper role: upstream practice-level panel used by all empirical tables/figures.
// -----------------------------------------------------------------------------
//
// Section A. Prepared QOF practice-domain inputs.
// These files are treated as already prepared analysis inputs in the recovered
// code bundle. If replication from raw QOF spreadsheets is required, add the
// missing raw-to-domain scripts before this step.
//
use "QOFprimPrev-practicePanel.dta", clear

merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFdiabetes-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFhyper-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFmental-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFdepr-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFcoron-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFatrial-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFasthma-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFckd-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFepil-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFsmoke-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFthyroid-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFstroke-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFheart-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFcancer-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFdem-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFcopd-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOForga-practicePanel.dta", nogen 
merge 1:1  year pra_code using "$dataGP/QoF practice level/QOFdomm-practicePanel.dta", nogen 
merge 1:1  year pra_code using "QOFprevalence-practicePanel.dta", keep(master match) nogen // <---- List data is coming from here

// -----------------------------------------------------------------------------
// Section B. ODS/EGPCUR GP directory controls.
// Built by: 01a_build_gp_directory_egpcur.do
// Adds: GP headcount, experience and practice seniority.
// -----------------------------------------------------------------------------
merge 1:1  year pra_code using "$dataGP/GPsdirectory/moredocreg/gp_egpcur.dta", keep(master match) nogen // Size of the practice, GP experience, seniority
// -----------------------------------------------------------------------------
// Section C. National General Practice Profiles.
// Prepared input checked by: 01_prepare_gp_source_data.do
// Adds: deprivation and profile indicators where available.
// -----------------------------------------------------------------------------
merge 1:1  year pra_code using "$dataGP/National General Practice Profiles/NationalGeneralPracticeProfiles.dta", keep(master match) nogen // Deprivation score


// -----------------------------------------------------------------------------
// Section D. APHO/ERPHO modelled prevalence controls.
// Built by: 01c_build_modelled_prevalence_practice.do
// Adds: modelled hypertension prevalence at practice level, available for 2008/2011.
// -----------------------------------------------------------------------------
merge 1:1  year pra_code using "$dataGP/Modelled Prevalences/mhyp_practices.dta", keep(master match) nogen // Only 2009 and 2011 data

// -----------------------------------------------------------------------------
// Section E. Static IC/HSCIC 2011 practice characteristics.
// Built by: 01d_build_static_ic_indicators_2011.do
// Adds: contract type, rurality, list size, GP headcount, years-of-service index.
// -----------------------------------------------------------------------------
merge m:1 pra_code using "$dataGP/Static IC Indicators 2011/GPstaticChars2011.dta", keep(match master) nogen

// -----------------------------------------------------------------------------
// Section F. Practice location.
// Prepared input checked by: 01_prepare_gp_source_data.do.
// -----------------------------------------------------------------------------
rename pra_code PracticeCode
merge m:1 PracticeCode using "$dataGP/GIS/GPaddress.dta", keepusing(postcode latitude longitude PracticeCode) keep(match master) nogen
rename PracticeCode pra_code 

encode pra_code, gen(prai)
xtset prai year

recode ONS_rural (1 2 3 4 7 8 =1)  (6 7 8=2) (5=3)
label def spar 1 "Sparse" 2 "Town Less Sparse" 3 "Urban 10K"
label val ONS_rural spar

tab ONS_rural, gen(ONS_ruralD_)

gen list1000=list/1000

label var coronary_unaprev "Coronary Heart Disease"
label var strokeh_unaprev "Stroke or Transient Ischaemic Attacks (TIA)"
label var hypert_unaprev "Hypertension"
label var diabet_unaprev "Diabetes Mellitus (Diabetes)"
label var pulmon_unaprev "Chronic Obstructive Pulmonary Disease"
label var epilep_unaprev "Epilepsy"
label var hypoty_unaprev "Hypothyroidism"
label var cancer_unaprev "Cancer"
label var menhea_unaprev "Mental Health"
label var asthma_unaprev "Asthma"
label var herfai_unaprev "Heart Failure"
label var herfa2_unaprev "Heart Failure Due to LVD "
label var palliat_unaprev "Palliative Care"
label var demen_unaprev "Dementia"
label var depres_unaprev "Depression"
label var depre1_unaprev "Depression1 Indicator"
label var kidney_unaprev "Chronic Kidney Disease"
label var atrial_unaprev "Atrial Fibrillation"
label var obesit_unaprev "Obesity"
label var leardi_unaprev "Learning Disabilities"
label var smoke_unaprev "Smoking"
label var cvdpre_unaprev "Cardiovascular Disease Primary Prevention"
label var padpre_unaprev "Peripheral Arterial Disease(PAD)"
label var osteop_unaprev "Osteoporosis: Secondary prevention of fragility fractures"


//////////////////////////////////////////////////////////////////////////////////////

* The prevalence factor ...........................................
gen denominPrev=(hypert_regcount-L.hypert_regcount)/list
sum denominPrev if year==2008

replace denominPrev=0 if denominPrev<0

gen prevalencFactor=(denominPrev/r(mean))  if year==2008

* The total potential factor .......................................
gen practsizeFactor=(list/5891) // This is the contractor population factor, 5891 seems to be "stable" on time

gen potentialFactor=prevalencFactor*practsizeFactor  if year==2008

* Achievement on PP01 in 2009 .......................................
*standarize it so the
* worse is "1" and the best is "0"
gen pp01_achievm=pp01_achiev if year==2009
bys  prai: egen pp01_achievM=max(pp01_achievm)	

cap drop pp01_norm
sum pp01_achievM, d
gen pp01_norm= 1 - ( (pp01_achievM-r(min))/(r(max)-r(min)) )
sum pp01_norm, d	
label var pp01_norm          "PP01 Inverse Ranking in 2009"


	
gen achi100=floor(pp01_achiev*100)
replace achi100=. if pp01_denom==0 | pp01_denom==.


gen dachi10=F.achi100-achi100
gen dachi11=F2.achi100-achi100
gen dachi12=F3.achi100-achi100

gen abv70=pp01_achiev>.7 if pp01_achiev!=.
gen D1Labv70=F.abv70-abv70
gen D2Labv70=F2.abv70-abv70

* Resources and payment..............................................
gen     payment=((1016-0)/(70-40))*(achi100-40)
replace payment=1016 if achi100>=70 & achi100!=.
replace payment=0    if achi100<=40
label var payment "Resources from QoF PP01 indicator Â£"

gen PotGains=(1016-payment)/100
replace PotGains=. if year!=2009
label var PotGains "Potential gains if improved preformance, 2009"

gen PotGainsAd=PotGains*L.potentialFactor
label var PotGainsAd "Potential gains if improved preformance, 2009 (adjusted by size and prev)"

xtile listQ=list1000 if year==2009, n(4)
_pctile list1000 if year==2009 ,n(4) // Get the cutoffs
label var listQ "List Size Quartile"

gen list1000x=listQ if year==2009
bys pra_code: egen listQ_09=max(list1000x)
drop list1000x
label var listQ_09 "List Size Quartile 2009"

save "$dataDerived/QOFpracticePanel.dta", replace
log close





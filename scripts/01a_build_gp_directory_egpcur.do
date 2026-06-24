/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 01a_build_gp_directory_egpcur.do
Language: Stata
Purpose: Convert ODS/EGPCUR GP directory CSV files into practice-year controls.
Source: NHS Organisation Data Service / EGPCUR practice and GP directory files.
Inputs expected:
  - data/GPs/GPsdirectory/moredocreg/raw/<year>/egpcur.csv, for years 2004-2015.
Outputs:
  - data/GPs/GPsdirectory/moredocreg/egpcur_2004_2015.dta
  - data/GPs/GPsdirectory/moredocreg/gp_egpcur.dta
Used by:
  - 06_build_qof_practice_panel.do, which merges gp_egpcur.dta to the QOF panel.
Paper output:
  - No direct table or figure. Provides practice controls used in empirical estimates.
Run order:
  - Component of 01_prepare_gp_source_data.do.
****************************************************************************************/

cap log close
clear all
set more off

global root        "`c(pwd)'"
global scripts     "$root/scripts"
global dataGP      "$root/data/GPs"
global logsFold    "$root/output/logs"

cap mkdir "$logsFold"
log using "$logsFold/01a_build_gp_directory_egpcur.log", replace text

cd "$dataGP/GPsdirectory/moredocreg/raw"


* The ideal frequency would be May, from 2004 to 2012.
* I can confirm that we are able to provide you with archived versions of the EGPCUR dataset - could you please confirm the frequency of the files you require? 
* We publish four full versions per year in February, May, August and, November.
 
* 2015 data is for August due to data availability

clear
gen uno=1

tempfile temp
save `temp'
foreach year in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 {
	import delimited "`year'/egpcur.csv", clear 
	gen year=`year'
	gen egpcurDate=mdy(5,1,`year')
	format egpcurDate  %td		
		
	rename v1 gnccode
	rename v2 gp_name
	rename v3 nationalgrouping
	rename v4 hlevgeography
	rename v5 gp_add1
	rename v6 gp_add2
	rename v7 gp_add3
	rename v8 gp_add4
	rename v9 gp_add5
	rename v10 gp_postcode
	rename v11 gp_opendate
	rename v12 gp_closedate
	rename v13 gp_statuscode
	rename v14 gp_subtypecode
	rename v15 gp_practicecode
	rename v16 gp_pracJoin
	rename v17 gp_pracLeft
	rename v18 gp_telephone
	rename v22 gp_amendedIndicator
	drop v19 v20 v21 v23 v24 
	cap drop v25 v26 v27	
	drop gp_add5 // Most of the time empty
	
	append using `temp'
	save `temp', replace
}


drop uno

label def statCod 1 "Active" 2 "Other (B)" 3  "Closed" 4 "Proposed" , replace
encode gp_statuscode, generate(gp_stcode)
label val gp_stcode statCod
drop gp_statuscode
label var gp_stcode "GP Activity Status"

label def subTyp 0 "Other GP" 1 "Principal GP" , replace
encode gp_subtypecode, generate(gp_subtype)
recode gp_subtype (1=0) (2=1)
label val gp_subtype subTyp
drop gp_subtypecode
label var gp_subtype "Is this the principal GP?"

replace gp_opendate=. if gp_opendate==19740401
gen gp_pracJoin_Y=floor(gp_opendate/10000)
gen gp_pracJoin_M=mod(floor(gp_opendate/100),100)
gen gp_pracJoin_D=mod(gp_opendate,100)
gen gp_opendateD=mdy( gp_pracJoin_M, gp_pracJoin_D, gp_pracJoin_Y)
format gp_opendateD  %td
drop gp_pracJoin_Y gp_pracJoin_M gp_pracJoin_D gp_opendate
label var gp_opendateD "GP Open Date"


replace gp_closedate=. if gp_closedate==19740401
gen gp_pracJoin_Y=floor(gp_closedate/10000)
gen gp_pracJoin_M=mod(floor(gp_closedate/100),100)
gen gp_pracJoin_D=mod(gp_closedate,100)
gen gp_closedateD=mdy( gp_pracJoin_M, gp_pracJoin_D, gp_pracJoin_Y)
format gp_closedateD  %td
drop gp_pracJoin_Y gp_pracJoin_M gp_pracJoin_D gp_closedate
label var gp_closedateD "GP Close Date"


replace gp_pracJoin=. if gp_pracJoin==19740401
gen gp_pracJoin_Y=floor(gp_pracJoin/10000)
gen gp_pracJoin_M=mod(floor(gp_pracJoin/100),100)
gen gp_pracJoin_D=mod(gp_pracJoin,100)
gen gp_pracJoinD=mdy( gp_pracJoin_M, gp_pracJoin_D, gp_pracJoin_Y)
format gp_pracJoinD  %td
drop gp_pracJoin_Y gp_pracJoin_M gp_pracJoin_D gp_pracJoin
label var gp_pracJoinD "Practice Join Date"


replace gp_pracLeft=. if gp_pracLeft==19740401
gen gp_pracJoin_Y=floor(gp_pracLeft/10000)
gen gp_pracJoin_M=mod(floor(gp_pracLeft/100),100)
gen gp_pracJoin_D=mod(gp_pracLeft,100)
gen gp_pracLeftD=mdy( gp_pracJoin_M, gp_pracJoin_D, gp_pracJoin_Y)
format gp_pracLeftD  %td
drop gp_pracJoin_Y gp_pracJoin_M gp_pracJoin_D gp_pracLeft
label var gp_pracLeftD "Practice Left Date"

gen seniority_total= (egpcurDate-gp_opendateD)/360 if egpcurDate-gp_opendateD>0 // There are a few negative numbers!
gen seniority_pract= (egpcurDate-gp_pracJoinD)/360 if egpcurDate-gp_pracJoinD>0 // There are a few negative numbers!

save "$dataGP/GPsdirectory/moredocreg/egpcur_2004_2015.dta", replace

///////////////////////////////////////////////////////////////////////////////

keep if gp_stcode==1
collapse (count) gp_subtype (mean) seniority_total seniority_pract , by(year gp_practicecode)

gen Size_SingleHandedHC= gp_subtype==1 if gp_subtype!=.
gen Size_SmallMediumHC = gp_subtype>1 & gp_subtype<=3 if gp_subtype!=.
gen Size_MediumLargeHC = gp_subtype>3 & gp_subtype<=6 if gp_subtype!=.
gen Size_LargeHC = gp_subtype>6 if gp_subtype!=.

label var Size_SingleHandedHC "Size (HC): Small, 1 GP"
label var Size_SmallMediumHC "Size (HC): Medium, (1,3] GP"
label var Size_MediumLargeHC "Size (HC): Large, (3,6] GP"
label var Size_LargeHC "Size (HC): Large, Abv 6 GP"

rename gp_subtype gp_HC
label var gp_HC "GP headcount according to the EGPCUR directory"

label var seniority_total "Experience of GP (years)"
label var seniority_pract "Seniority of GP in the practice (years)"

encode gp_practicecode, gen(temgpcode)

xtset temgpcode year

* Makes sense... huge persistency and every year is adding a "1"
xtdescribe
reg seniority_total L.seniority_total
reg seniority_pract L.seniority_pract

drop temgpcode
rename gp_practicecode pra_code

save "$dataGP/GPsdirectory/moredocreg/gp_egpcur.dta", replace


log close

/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 07_descriptive_tables_and_figures.do
Language: Stata
Purpose: Produce descriptive tables and diagnostic/descriptive figures from the practice-level QOF panel.
Main input:
  - data/derived/QOFpracticePanel.dta, created by 06_build_qof_practice_panel.do
Main outputs:
  - output/tables/summaryTab_GPprac.tex
  - output/tables/summaryTab_GPqofach.tex
  - output/tables/summaryTab_GPprev.tex
  - output/tables/qofindic_descrip.tex
  - output/tables/qofindic_descripSample.tex
  - output/figures/ExampleQOFpayments.pdf                 [main text Figure 1 / label fig:QOF-schedule support]
  - output/figures/allInsBunching.pdf                     [main text Figure 2 / label fig:bunching]
  - output/figures/NHS staf 2001-2013 v2.pdf              [appendix Figure / label fig:GPstaff]
  - output/figures/ExampleQOFvaria.pdf, Alt_ExampleQOFvaria.pdf [diagnostic]
  - output/figures/multibunchingDist.pdf, allInsBunching.pdf    [diagnostic]
Run order: after 00_programs_and_globals.do and 06_build_qof_practice_panel.do.
****************************************************************************************/

macro drop _all
clear all
set more off
set matsize 2000

* -----------------------------------------------------------------------------
* Portable replication paths
* IMPORTANT: before running, open Stata and cd to the root Rep_folder.
* -----------------------------------------------------------------------------
global mainDir     "`c(pwd)'"
global scripts     "$mainDir/scripts"
global dataGP      "$mainDir/data/GPs"
global dataDerived "$mainDir/data/derived"
global tableFold   "$mainDir/output/tables"
global imageFold   "$mainDir/output/figures"
global logsFold    "$mainDir/output/logs"

cap mkdir "$dataDerived"
cap mkdir "$tableFold"
cap mkdir "$imageFold"
cap mkdir "$logsFold"

cap log close
log using "$logsFold/07_descriptive_tables_and_figures.log", replace text

do "$scripts/00_programs_and_globals.do"

* -----------------------------------------------------------------------------
* Replication run switches. Set to 0 only if you want to skip a block.
* -----------------------------------------------------------------------------
global RUN_SUMMARY_TABLES                    1
global RUN_STAFF_CONTEXT                     1
global RUN_QOF_INDICATOR_DESCRIPTIVES        1
global RUN_FIGURE8_PAYMENT_SCHEME            1
global RUN_TIME_VARIATION_FIGURES            0
global RUN_MULTI_BUNCHING_HISTOGRAM          1
global RUN_ALL_INDICATORS_BUNCHING_HIS        1

glo pra_controls="cont_PMS cont_other yrsexpIndi gp_1000p ONS_ruralD_*"
glo genOpts=`"  graphregion(color(white) ) scheme(blind) "'

////////////////////////////////////////////////////////////////////////////////	
// GP practices descriptives
// Paper output: descriptive appendix table fragments summaryTab_GPprac.tex, summaryTab_GPqofach.tex, summaryTab_GPprev.tex
////////////////////////////////////////////////////////////////////////////////
if ${RUN_SUMMARY_TABLES} {
	use "$dataDerived/QOFpracticePanel.dta", clear

	* These raw prevalences are not reported directly in the public data; they are reconstructed below where needed.

	drop diabet_unaprev depres_unaprev

	gen diabet_unaprev=Diabetes2Denominator/list // Record of people with diabets, aged 17 and over

	gen depres_unaprev=DEP02Denominator/list

	label var diabet_unaprev "Diabetes $ \dagger$ "
	label var depres_unaprev "Depression new cases $ \dagger$ "

	label var coronary_unaprev "Coronary Heart Disease"
	label var strokeh_unaprev "Stroke or Transient Ischaemic Attacks (TIA)"
	label var hypert_unaprev "Hypertension"
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
	label var depre1_unaprev "Depression1 Indicator"
	label var kidney_unaprev "Chronic Kidney Disease"
	label var atrial_unaprev "Atrial Fibrillation"
	label var obesit_unaprev "Obesity"
	label var leardi_unaprev "Learning Disabilities"
	label var smoke_unaprev "Smoking"
	label var cvdpre_unaprev "Cardiovascular Disease Primary Prevention"
	label var padpre_unaprev "Peripheral Arterial Disease(PAD)"
	label var osteop_unaprev "Osteoporosis: Secondary prevention of fragility fractures"

	label var SUM_CLINICALAchievement "Clinical (697 points)"
	label var SUM_ORGANAchievement    "Organisational"
	label var SUM_PATEXPAchievement   "Patient Experience"
	label var SUM_ADDSERAchievement   "Additional Services"
	label var SUM_QOFAchievement      "Total (1000 points)" 

	local hypert_points09=81
	local obesit_points09=8
	local depres_points09=53
	local asthma_points09=45
	local diabet_points09=100
	local coronary_points09=87
	local hypoty_points09=7
	local kidney_points09=38
	local strokeh_points09=24
	local pulmon_points09=30
	local cvdpre_points09=13
	local cancer_points09=11
	local atrial_points09=27
	local menhea_points09=39
	local herfai_points09=29
	local epilep_points09=15
	local demenp_points09=20
	local leardi_points09=4
	local palliat_points09=6
	local smokep_points09=60


	foreach varDep of varlist *_unaprev SUM_CLINICALAchievement SUM_ORGANAchievement SUM_PATEXPAchievement SUM_ADDSERAchievement SUM_QOFAchievement {
		replace `varDep' = `varDep'*100
	} 

	xtset prai year
	gen Dlist=D.list
	label var Dlist "List size year variation"

	label var pp01_achiev "QOF: PP01 achievement"
	replace pp01_achiev=pp01_achiev*100
	label var list1000 "Number of patients in thousands (list size)"
	label var list "Number of patients (list size)"
	
	

	glo ctrs list

	cd "$tableFold"
	
	// Panel A: Basic details ......................
	texdoc init summaryTab_GPprac.tex, replace
	foreach varDep in $ctrs {
		local labelo : variable label `varDep'
		
		local labelo = subinstr("`labelo'","_"," ",.)
		local labelo = subinstr("`labelo'","&"," and ",.)
		local labelo = subinstr("`labelo'","%","\%",.)
		
		tex $ \quad$ `labelo'
		forval yr=2009(1)2011 {
			sum `varDep' if year==`yr'
			local mean : disp %5.2f r(mean)
			tex & `mean'
		}
		tex \\	
	}
	tex $ \quad$ Number of practices
	forval yr=2009(1)2011 {
		count if year==`yr'
		local ene =r(N)
		tex & `ene'
	}
	tex \\		
	tex \addlinespace	
	texdoc close
	
	*******************************************************
	// Panel B: QOF Results ......................	
	glo ctrs ///
		SUM_CLINICALAchievement SUM_ORGANAchievement SUM_PATEXPAchievement SUM_ADDSERAchievement SUM_QOFAchievement
			
	texdoc init summaryTab_GPqofach.tex, replace
	foreach varDep in $ctrs {
		local labelo : variable label `varDep'
		
		local labelo = subinstr("`labelo'","_"," ",.)
		local labelo = subinstr("`labelo'","&"," and ",.)
		local labelo = subinstr("`labelo'","%","\%",.)
		
		tex $ \quad$ `labelo'
		forval yr=2009(1)2011 {
			sum `varDep' if year==`yr'
			local mean : disp %5.2f r(mean)
			tex & `mean'
		}
		tex \\	
	}
	tex \addlinespace	
	texdoc close	
	
	*******************************************************
	// Panel C: Main Prevalences ......................	
	glo ctrs ///
		diabet hypert asthma coronary depres	
		
	texdoc init summaryTab_GPprev.tex, replace
	foreach varDep in $ctrs {
		local labelo : variable label `varDep'_unaprev
		
		local labelo = subinstr("`labelo'","_"," ",.)
		local labelo = subinstr("`labelo'","&"," and ",.)
		local labelo = subinstr("`labelo'","%","\%",.)		
		
		tex $ \quad$ `labelo'

		sum `varDep'_unaprev if year==2009, d
		local mean : disp %5.2f r(mean)
		local sd : disp %5.2f r(sd)
		tex & ``varDep'_points09' & `mean' & `sd' \\
	}
	
	texdoc close	

}

////////////////////////////////////////////////////////////////////////////////	
// GP staff numbers
// Paper output: appendix workforce context figure, label fig:GPstaff.
// Uses embedded counts from NHS Staff Table 1b and number of practices from QOF files.
////////////////////////////////////////////////////////////////////////////////
if ${RUN_STAFF_CONTEXT} {

clear

input year total_gps gp_practice_nurses phcs gps_per_phc nurses_per_phc
2001 26628 11163 . .
2002 26833 11998 . .
2003 27624 12967 . .
2004 28308 13563 8576 3.3 1.6
2005 29248 13793 8409 3.5 1.6
2006 30931 14616 8372 3.7 1.7
2007 30936 14554 8294 3.7 1.8
2008 30675 13962 8229 3.7 1.7
2009 32111 13582 8305 3.9 1.6
2010 31356 13167 8359 3.8 1.6
2011 31391 13573 8373 3.7 1.6
end

twoway (connected gps_per_phc year, mlabel(gps_per_phc) mlabposition(12)) ///
	(connected nurses_per_phc year, lpattern(dash) mlabel(nurses_per_phc) mlabposition(12)) ///
	, ylabel(0(1)5) legend(on order(1 "GPs" 2 "Nurses") position(6) cols(2)) ytitle(Full-time equivalent per PHC)
	graph export "$imageFold/workforce_GP_per_PHC.pdf", as(pdf) replace
	graph export "$imageFold/NHS staf 2001-2013 v2.pdf", as(pdf) replace
}

////////////////////////////////////////////////////////////////////////////////	
// QOF Indicators Descriptives (qofindic_descrip)
// Paper output: appendix table imported as tables/qofindic_descrip.tex.
////////////////////////////////////////////////////////////////////////////////
if ${RUN_QOF_INDICATOR_DESCRIPTIVES} {
	glo thresholds = "90		90		80			70			80			70	90			70		90		60		90		85		70		90		90		70		80		80		70		60		90	90		90		80		70		85		90		90		90			70			90		80		60		90		90		90			60			85			90			80			90"
	glo indicators = "AF03	AF04	ASTHMA03	ASTHMA06	ASTHMA08	BP5	CANCER03	CHD08	CHD09	CHD10	CHD12	COPD08	COPD10	COPD13	CKD02	CKD03	CKD05	CKD06	CVD02	DEM02	DM2	DM10	DM13	DM15	DM17	DM18	DM21	DM22	EPILEP06	EPILEP08	HF02	HF03	HF04	SMOKE03	SMOKE04	STROKE07	STROKE08	STROKE10	STROKE12	STROKE13	THYROI02"
	
	
	glo thresholdsSample = "90		90"
	glo indicatorsSample = "COPD13	THYROI02"
		

	foreach tipo in "" "Sample" {

		cd "$tableFold"
			
		use "$dataDerived/QOFpracticePanel.dta", clear

		rename Hyper* BP*
		rename Diabetes* DM*
		rename pp01_achiev	CVD01Achievement
		rename pp02_achiev  CVD02Achievement
		
		rename pp01_denom CVD01Denominator
		rename pp02_denom CVD02Denominator
		
		rename pp01_points CVD01Points
		rename pp02_points CVD02Points	

		tab year, gen(yea_)	
		gen Af= year>=2011
		label var Af "After: Fcl. Year>=2011"
		xtset prai year

		glo size="18cm"
		glo cols=10
		local gray=1
		qui {
			// Requires the following on the preamble
			//	\usepackage{array}
			//	\newcolumntype{C}[1]{>{\centering\let\newline\\\arraybackslash\hspace{0pt}}m{#1}}
			
			texdoc init qofindic_descrip`tipo' , replace force
			tex {
			tex \scriptsize
			tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
			tex \begin{longtable}{l{2.2cm} C{1.1cm} C{0.8cm} C{0.9cm} C{1.7cm} C{0.7cm} C{2.0cm}  C{2.2cm} C{2.2cm} c c c c c c c}
				if ("`tipo'"=="Sample") {
					tex \caption{COPD13 and THYROI02 QOF indicators descriptives for the 2010/11 financial year  $ (t=2) $ \label{tab:qofindic_descrip`tipo'}}\\
				}
				else {
					tex \caption{QOF indicators descriptives for 2010/11 financial year $ (t=2) $ \label{tab:qofindic_descrip}}\\
				}
				tex \toprule
				tex &    & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)}  & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} & \multicolumn{1}{c}{(8)} \\ //    & \multicolumn{1}{c}{(9)} & \multicolumn{1}{c}{(10)} \\ 
				*tex &    & \multicolumn{5}{c}{Year = 2010} & \multicolumn{5}{c}{Year = 2011} \\
				tex Indicator & UL & Number & $ E[x_2]$ & $ SD[x_2]$ & $ \text{P}[x_2<UL]$ & $ \rho(x_2)$ & $ E[ (x_2-x_1) \leq 5 ]$  & $ E[x_2-x_1$  & $ E[x_2-x_1$ \\
				tex &  & &  &  &  & & &  $ \quad \quad |x_1<UL]$  & $ \quad \quad |x_1>UL]$ \\
				tex \cmidrule(r){1-2} \cmidrule(r){3-10} // \cmidrule(r){8-12}
			tex \endfirsthead
				tex \caption[]{(Continued)} \\
				tex \toprule
				tex &    & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)}  & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} & \multicolumn{1}{c}{(7)} & \multicolumn{1}{c}{(8)} \\ //   & \multicolumn{1}{c}{(9)} & \multicolumn{1}{c}{(10)} \\ 			*tex &    & \multicolumn{5}{c}{Year = 2010} & \multicolumn{5}{c}{Year = 2011} \\
				tex Indicator & UL & Number & $ E[x_2]$ & $ SD[x_2]$ & $ \text{P}[x_2<UL]$ & $ \rho(x_2)$ & $ E[ (x_2-x_1) \leq 5 ]$ & $ E[x_2-x_1$  & $ E[x_2-x_1$ \\
				tex &  & &  &  &  & & &  $ \quad \quad |x_1<UL]$  & $ \quad \quad |x_1>UL]$ \\
				tex \cmidrule(r){1-2} \cmidrule(r){3-10} // \cmidrule(r){8-12}
			tex \endhead
				tex \midrule \multicolumn{$cols}{r}{\emph{Continued on next page}}
			tex \endfoot
				tex \bottomrule
				tex \addlinespace[3pt]
				tex \multicolumn{$cols}{l}{\parbox[l]{$size}{\textbf{Notes:} ///				
					Own calculations based on QOF data. ///
					\textbf{Number:} Number of GP practices, including those with 0 eligible patients for the given indicator. ///
					\textbf{$ E[x_2]$ :} Average achievement per indicator. ///
					\textbf{$ \text{P}[x_2<UL]$ :} Proportion of practices with an achievement below UL. ///
					\textbf{$ \rho(x_2)$ :} Correlation between 2010 and 2009 achievement. ///
					\textbf{$ E[ (x_2-x_1) \leq 5 ] $ :} Proportion of individuals with achievement on two consecutive years within 5 points. ///
					\textbf{$ E[x_2-x_1 |x_1>UL]$ :} Difference on achievement between 2010 and 2009, conditional on obtaining an achievement below UL in 2009. /// //					The stars of this last column presents the difference of means between columns 8 and 9. ///
					}} \\
			tex \endlastfoot
		}
		***************************

		local n : word count ${indicators`tipo'}
		forval i=1(1)`n'  {	// 
		*forval i=1(1)1  {	// 	
		
			local varDepo : word `i' of ${indicators`tipo'}
			local uppt   : word `i' of ${thresholds`tipo'}
			
			local varDep = "`varDepo'Achievement"
			
			disp in red "`varDep' with `uppt' "

		
			local lname : variable label `varDep'
			if "`lname'"=="" local lname ="`varDep'"
			local lname = subinstr("`lname'","_","",.)
			local lname = subinstr("`lname'","&"," and ",.)		

			
			gen Lx`varDep'=L.`varDep'			
			gen diff`varDep'=`varDep' - L.`varDep'		
			
			foreach yr in "10" "11" {	
				replace `varDep'=. if `varDepo'Points==.
			
				sum `varDep' if year==20`yr' & `varDep'!=.
				local ymean`yr'  : di %7.2f r(mean)*100
				local ysd`yr'  : di %7.2f r(sd)*100
				
				count if year==20`yr' & `varDep'!=.
				local ene`yr'=r(N)
				count  if year==20`yr' & `varDep'!=. & `varDep'<(`uppt'/100)
				local atmean`yr' : di %7.2f (r(N)/`ene`yr'')*100

					correl Lx`varDep' `varDep' if year==20`yr'
				local autoc`yr'  : di %7.2f r(rho)

				count if abs(Lx`varDep'-`varDep')<=0.05 & year==20`yr' & `varDep'!=.
				loc with`yr'=r(N)
				
				local within`yr' : di %7.2f (`with`yr''/`ene`yr'')*100
				
				sum diff`varDep' if year==20`yr' & diff`varDep'!=. & Lx`varDep'<(`uppt'/100)
				local belULmeanD`yr'  : di %7.2f r(mean)*100
				sum diff`varDep' if year==20`yr' & diff`varDep'!=. & Lx`varDep'>(`uppt'/100)
				local abvULmeanD`yr'  : di %7.2f r(mean)*100	
				
				cap drop abox
				gen abox=Lx`varDep'>(`uppt'/100)
				reg diff`varDep' abox if year==20`yr' & diff`varDep'!=. 

				scalar pval=2*ttail( e(df_r) , abs( _b[abox] / _se[abox] ))
			
				loc star`yr' = ""
				if ((pval < 0.1) )  loc star`yr' = "^{*}" 
				if ((pval < 0.05) ) loc star`yr' = "^{**}" 
				if ((pval < 0.01) ) loc star`yr' = "^{***}" 				
				
			}
			
			if (`gray'==1) & ("`tipo'"!="Sample") tex \rowcolor{Gray}
			tex \parbox[c]{2.1cm}{\raggedright `varDepo'} & `uppt'\% & `ene10' & `ymean10' & `ysd10' & `atmean10' & `autoc10' & `within10' & `belULmeanD10' & `abvULmeanD10' \\ //  `star10'  & `ene11' & `ymean11' & `autoc11' & `belULmeanD11' & `abvULmeanD11'  \\
			local gray=abs(`gray'-1)
		
		}

		***************************

		tex \end{longtable}
		tex }
		texdoc close	

		***************************
	}

}

////////////////////////////////////////////////////////////////////////////////
// Figure 8: Payment scheme and histogram for 2009 achievement for THYROI02, COPD13
// Paper output: Figure 8 / descriptive QOF payment histogram
if ${RUN_FIGURE8_PAYMENT_SCHEME} {
	use "$dataDerived/QOFpracticePanel.dta", clear
	xtset prai year
		
	replace THYROI02Achievement=THYROI02Achievement*100
	replace COPD13Achievement  =COPD13Achievement*100
	* THYROI02  COPD13
	
	if ${RUN_TIME_VARIATION_FIGURES} { // 3D version
		preserve

		gen var1 = round(THYROI02Achievement)
		gen var2 = round(COPD13Achievement)

		glo cuts="0 4 9 14 19 24 29 34 39 44 49 54 59 64 69 74 79 84 89 94 99 100"
		local len : word count $cuts
		
		forval i=1(1)2 {
			gen dim`i'bin=0 if var`i'==0
			forval j=2(1)`len'  {
				loc varo1  : word `j' of $cuts
				loc j0=`j'-1
				loc varo0  : word `j0' of $cuts
				replace dim`i'bin=`varo1' if var`i'>`varo0' & var`i'<=`varo1'			
			}		
		}
	
		gen interBin=1
		collapse (count) interBin, by(dim1bin dim2bin)
		drop if dim1bin==. | dim2bin==.
		
			keep if dim1bin>50 & dim2bin>50
		
		label var dim1bin "THYROI02 (UL=70)"
		label var dim2bin "COPD13 (UL=90)"
		label var interBin "Frequency"
		
		surface dim1bin dim2bin interBin , name(a1, replace)
		twoway (contour interBin dim2bin dim1bin, levels(10) heatmap)  , name(a2, replace)
		graph combine a1 a2, title(2 dim histogram)
		
		restore
	}
	
	* There is no practice with an achivement of 40% in this indicator, so just for the graph, I created one
	loc ob=_N+1
	set obs `ob'
	replace THYROI02Achievement=40 in `ob'
	replace year=2009 in `ob'

	gen     payf_as6=0  if THYROI02Achievement!=.
	replace payf_as6=6 if THYROI02Achievement>90 & THYROI02Achievement!=.
	replace payf_as6=(6/(90-40))*(THYROI02Achievement-40) if THYROI02Achievement>40 & THYROI02Achievement<90

	gen     payf_bp5=0  if COPD13Achievement!=.
	replace payf_bp5=9  if COPD13Achievement>90 & COPD13Achievement!=.
	replace payf_bp5=(9/(90-50))*(COPD13Achievement-50) if COPD13Achievement>50 & COPD13Achievement<90

	keep if year==2010
	sort THYROI02Achievement
	tw (line payf_as6 THYROI02Achievement, lwidth(thick)) , ///
		xline(40 90) $genOpts name(as6_points, replace) xtitle(Achievement , size(medlarge)) ///
		ytitle(Awarded Points , size(medlarge)) title(THYROI02) 
		
	sort COPD13Achievement
	tw (line payf_bp5 COPD13Achievement, lwidth(thick))   , ///
		xline(50 90) $genOpts name(bp5_points, replace) xtitle(Achievement , size(medlarge)) ///
		ytitle(Awarded Points , size(medlarge)) title(COPD13 )
		
	* Histograms
	hist THYROI02Achievement, width(2) xline(40 90) $genOpts name(as6_hist, replace) xtitle(Achievement , size(medlarge)) ytitle(Density , size(medlarge))
	hist COPD13Achievement  , width(2) xline(50 90) $genOpts name(bp5_hist, replace) xtitle(Achievement , size(medlarge)) ytitle(Density , size(medlarge))

	graph combine bp5_points as6_points bp5_hist as6_hist , scheme(Plotplainblind)
	graph export "$imageFold/ExampleQOFpayments.pdf", as(pdf) replace	
	
	* Counts for 2010
	count if THYROI02Achievement!=.
	count if THYROI02Denominator==0
	
	count if COPD13Achievement!=.
	count if COPD13Denominator==0	
	
	
}

////////////////////////////////////////////////////////////////////////////////
// Graph 2: Time variation
// Paper output: diagnostic figures not imported by the current manuscript.
if ${RUN_MULTI_BUNCHING_HISTOGRAM} {
	use "$dataDerived/QOFpracticePanel.dta", clear
	xtset prai year

	replace ASTHMA06Achievement=ASTHMA06Achievement*100
	replace Hyper5Achievement=Hyper5Achievement*100

	gen DASTHMA06Achievement=D.ASTHMA06Achievement
	gen DHyper5Achievement  =D.Hyper5Achievement

	gen LASTHMA06Achievement=L.ASTHMA06Achievement
	gen LHyper5Achievement  =L.Hyper5Achievement

	correl ASTHMA06Achievement L.ASTHMA06Achievement // 0.5735
	correl Hyper5Achievement L.Hyper5Achievement     // 0.6841

	keep if year==2010
	gen above_as06=LASTHMA06Achievement<70 if LASTHMA06Achievement!=.
	gen above_bp5=LHyper5Achievement<70 if LHyper5Achievement!=.

	sum DASTHMA06Achievement if LASTHMA06Achievement<70, d // 11 pp. (SD = 14.8 pp.) 
	sum DASTHMA06Achievement if LASTHMA06Achievement>70, d // -0.2 pp. (SD = 6.7 pp.) 
	ttest DASTHMA06Achievement, by(above_as06) unequal // Diff from 0, 99%

	sum DHyper5Achievement if LHyper5Achievement<70, d // 5.953337 pp. (SD = 9.944306 pp.) 
	sum DHyper5Achievement if LHyper5Achievement>70, d // -.088912 pp. (SD = 5.030401 pp.) 
	ttest DHyper5Achievement, by(above_bp5) unequal // Diff from 0, 99%


	tw (kdensity DASTHMA06Achievement if LASTHMA06Achievement<70 , lwidth(thick))  (kdensity DASTHMA06Achievement if LASTHMA06Achievement>70 , lwidth(thick)) ///
		, $genOpts name(as6_dens, replace) xtitle(Variation on Achievement , size(medlarge)) ytitle(Points , size(medlarge))  title(Asthma 6) ///
		  legend(order(1 "Below UL=70% in 2009/10" 2 "Above UL=70% in 2009/10"))	
	tw (kdensity DHyper5Achievement if LHyper5Achievement<70 , lwidth(thick))  (kdensity DHyper5Achievement if LHyper5Achievement>70 , lwidth(thick)) ///
		, $genOpts name(bp5_dens, replace) xtitle(Variation on Achievement , size(medlarge)) ytitle(Points , size(medlarge)) title(Hypertension 5 (BP5) ) ///
		  legend(order(1 "Below UL=70% in 2009/10" 2 "Above UL=70% in 2009/10"))
		
	grc1leg bp5_dens as6_dens , scheme(blind)
	graph export "$imageFold/ExampleQOFvaria.pdf", as(pdf) replace	
	
	****************************************************************************

	use "$dataDerived/QOFpracticePanel.dta", clear
	xtset prai year

	replace ASTHMA06Achievement=ASTHMA06Achievement*100
	replace Diabetes17Achievement=Diabetes17Achievement*100

	sum ASTHMA06Achievement if year==2009 // 78.9%
		loc cont=r(N)
		count if ASTHMA06Achievement<70 & year==2009
		disp r(N)/`cont' // Just 7%!!	
	sum Diabetes17Achievement if year==2009 // 83%
		loc cont=r(N)
		count if Diabetes17Achievement<70 & year==2009
		disp r(N)/`cont' // Just 3.1%!!
	
	gen DASTHMA06Achievement=D.ASTHMA06Achievement
	gen DDiabetes17Achievement  =D.Diabetes17Achievement

	gen LASTHMA06Achievement=L.ASTHMA06Achievement
	gen LDiabetes17Achievement  =L.Diabetes17Achievement

	correl ASTHMA06Achievement L.ASTHMA06Achievement // 0.5735
	correl Diabetes17Achievement L.Diabetes17Achievement     // 0.6544

	keep if year==2010
	gen above_as06=LASTHMA06Achievement<70 if LASTHMA06Achievement!=.
	gen above_bp5=LDiabetes17Achievement<70 if LDiabetes17Achievement!=.

	sum DASTHMA06Achievement if LASTHMA06Achievement<70, d // 11 pp. (SD = 14.8 pp.) 
	sum DASTHMA06Achievement if LASTHMA06Achievement>70, d // -0.2 pp. (SD = 6.7 pp.) 
	ttest DASTHMA06Achievement, by(above_as06) unequal // Diff from 0, 99%

	sum DDiabetes17Achievement if LDiabetes17Achievement<70, d // 8.7881 (SD = 18.14pp)
	sum DDiabetes17Achievement if LDiabetes17Achievement>70, d // -0.54548 (SD=5.0587pp)
	ttest DDiabetes17Achievement, by(above_bp5) unequal // -9.328148 Diff from 0, 99%


	tw (kdensity DASTHMA06Achievement if LASTHMA06Achievement<70 , lwidth(thick))  (kdensity DASTHMA06Achievement if LASTHMA06Achievement>70 , lwidth(thick)) ///
		, $genOpts name(as6_dens, replace) xtitle(Variation on Achievement , size(medlarge)) ytitle(Points , size(medlarge))  title(Asthma 6) ///
		  legend(order(1 "Below UL=70% in 2009/10" 2 "Above UL=70% in 2009/10"))	
	tw (kdensity DDiabetes17Achievement if LDiabetes17Achievement<70 , lwidth(thick))  (kdensity DDiabetes17Achievement if LDiabetes17Achievement>70 , lwidth(thick)) ///
		, $genOpts name(bp5_dens, replace) xtitle(Variation on Achievement , size(medlarge)) ytitle(Points , size(medlarge)) title(Diabetes 17 ) ///
		  legend(order(1 "Below UL=70% in 2009/10" 2 "Above UL=70% in 2009/10"))
		
	grc1leg bp5_dens as6_dens , scheme(blind)
	graph export "$imageFold/Alt_ExampleQOFvaria.pdf", as(pdf) replace	
}	
////////////////////////////////////////////////////////////////////////////////
// Graph 3: histogram on multibunching
// Paper output: diagnostic figure not imported by the current manuscript.
if 1==0 {

	use "$dataDerived/QOFpracticePanel.dta", clear
	xtset prai year
	
	rename Hyper* BP*
	rename Diabetes* DM*
	rename pp01_achiev	CVD01Achievement
	rename pp02_achiev  CVD02Achievement
	rename pp01_achievm PP01Achievement

	keep if year==2009		

	* All non-affected indicators
	glo thresholdsNA = "90		90		80			70			80			70	90			70		90		60		90		90		70		80		80		70		70		60		90	90		90		80		70		85		90		90		90			70			90		80		60		90		90		90			60			85			90			80			90"
	glo indicatorsNA = "AF03	AF04	ASTHMA03	ASTHMA06	ASTHMA08	BP5	CANCER03	CHD08	CHD09	CHD10	CHD12	CKD02	CKD03	CKD05	CKD06	CVD01	CVD02	DEM02	DM2	DM10	DM13	DM15	DM17	DM18	DM21	DM22	EPILEP06	EPILEP08	HF02	HF03	HF04	SMOKE03	SMOKE04	STROKE07	STROKE08	STROKE10	STROKE12	STROKE13	THYROI02"
	
	* All affected indicators
	glo thresholdsA = "90	90		70		90		80		90		70		90		90		90		90		90		90		60		90		50		70		90		90			90		90		50		90		90		90			70	"  // 80
	glo indicatorsA = "BP4	CHD05	CHD06	CHD07	CHD11	CHD02	PP01	DEP01	DEP02	DEP03	DM5		DM9		DM11	DM12	DM16	DM23	DM24	DM25	EPILEP07	MH04	MH05	MH06	MH07	MH09	STROKE05	STROKE06"  // COPD12
	
	glo superCondL5 = 5
	glo superTitlL5 = "Window of 5 pp."

	
	gen bunchedItems=0
	
	local numIn=0
	foreach endo in "NA" "A" {
		local n : word count ${indicators`endo'}
		forval i=1(1)`n'  {	// 

			local varDepo : word `i' of ${indicators`endo'}
			local uppt   : word `i' of ${thresholds`endo'}
			local varDep = "`varDepo'Achievement"
			
			disp in red "`varDep' with `uppt' "
			
			replace bunchedItems=bunchedItems+ 1 if `varDep'*100>=`uppt' & `varDep'*100<=(`uppt'+$superCondL5) 
			local numIn=`numIn'+1
		}
	}
	label var bunchedItems "Number of bunched indicators (out of `numIn') "
	hist  bunchedItems , $genOpts note(Bunched indicator: achievement between UL and UL+5)
	graph export "$imageFold/multibunchingDist.pdf", as(pdf) replace	
		
}


////////////////////////////////////////////////////////////////////////////////
// Graph 4: histograms in all indicators at once
// Paper output: diagnostic all-indicator bunching histogram.
if ${RUN_ALL_INDICATORS_BUNCHING_HIS} {


	use "$dataDerived/QOFpracticePanel.dta", clear
	xtset prai year
	
	rename Hyper* BP*
	rename Diabetes* DM*
	rename pp01_achiev	CVD01Achievement
	rename pp02_achiev  CVD02Achievement
	rename pp01_achievm PP01Achievement


	* All non-affected indicators
	glo thresholdsNA = "90		90		80			70			80			70	90			70		90		60		90		90		70		80		80		70		70		60		90	90		90		80		70		85		90		90		90			70			90		80		60		90		90		90			60			85			90			80			90"
	glo indicatorsNA = "AF03	AF04	ASTHMA03	ASTHMA06	ASTHMA08	BP5	CANCER03	CHD08	CHD09	CHD10	CHD12	CKD02	CKD03	CKD05	CKD06	CVD01	CVD02	DEM02	DM2	DM10	DM13	DM15	DM17	DM18	DM21	DM22	EPILEP06	EPILEP08	HF02	HF03	HF04	SMOKE03	SMOKE04	STROKE07	STROKE08	STROKE10	STROKE12	STROKE13	THYROI02"
	
	* All affected indicators
	glo thresholdsA = "90	90		70		90		80		90		70		90		90		90		90		90		90		60		90		50		70		90		90			90		90		50		90		90		90			70	"  // 80
	glo indicatorsA = "BP4	CHD05	CHD06	CHD07	CHD11	CHD02	PP01	DEP01	DEP02	DEP03	DM5		DM9		DM11	DM12	DM16	DM23	DM24	DM25	EPILEP07	MH04	MH05	MH06	MH07	MH09	STROKE05	STROKE06"  // COPD12
	
	glo superCondL5 = 5
	glo superTitlL5 = "Window of 5 pp."

	
	gen bunchedItems=0
	
	foreach endo in "NA" "A" {
		local n : word count ${indicators`endo'}
		forval i=1(1)`n'  {	// 

			local varDepo : word `i' of ${indicators`endo'}
			local uppt   : word `i' of ${thresholds`endo'}
			local varDep = "`varDepo'Achievement"
			
			disp in red "`varDep' with `uppt' "
			
			gen sx`varDepo' = `varDep'*100-`uppt' if `varDep'>0 & `varDep'<99
			
		}
	}
	
	keep prai year sx*
	
	reshape long sx, i(prai year) j(indicator) string
	
	histogram sx if sx>=-50 & sx<=9 & year==2011, ///
		discrete width(1) start(-50) percent fcolor(black) lcolor(none) ///
		barwidth(0.8) xline(0) xtitle(Achievement relative to UL) xlabel(-50(10)10)
	graph export "$imageFold/allInsBunching.pdf" , as(pdf) replace
}

log close

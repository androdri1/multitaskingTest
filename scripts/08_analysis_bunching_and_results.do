/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 08_analysis_bunching_and_results.do
Language: Stata
Purpose: Prepare the QOF analysis panel, run first-step bunching tests, run second-step
         regressions, and generate the empirical tables and figures.
Main input:
  - data/derived/QOFpracticePanel.dta, created by 06_build_qof_practice_panel.do
Main outputs:
  - data/derived/QOFpracticePanel_ready.dta
  - output/tables/testCornerv12alt.tex             [Appendix Table E1 / label tab:testCorner]
  - output/tables/testCornerv12_rob.tex            [Appendix Table E2]
  - output/tables/mainResults_L3.tex               [Appendix Table F1 / label tab:mainResults_L3]
  - output/tables/mainResults_Multih.tex           [Appendix robustness table / label tab:mainResults_Multih]
  - output/tables/mainResults_K#L#.tex             [additional window-specific copies]
  - output/tables/step2resultsB.csv, step2graph.csv [inputs for appendix summaries]
  - output/figures/ExampleBunchingTest.pdf         [example bunching figure]
  - output/figures/step1_summary.pdf, step2_summary.pdf
  - output/figures/ResultsDensities*.pdf
Run order: after 00_programs_and_globals.do and 06_build_qof_practice_panel.do. Set run switches below if only one block is needed.
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
cap mkdir "$imageFold/massProd"

cap log close
log using "$logsFold/08_analysis_bunching_and_results.log", replace text

do "$scripts/00_programs_and_globals.do"

* -----------------------------------------------------------------------------
* Replication run switches. Set to 0 only if you want to skip a time-consuming
* block. The comments below each block indicate the related paper table/figure.
* -----------------------------------------------------------------------------
global RUN_BUILD_READY_PANEL      1  // creates data/derived/QOFpracticePanel_ready.dta
global RUN_DIAGNOSTIC_DISTR       1  // Appendix Figure F6 / label fig:Distribution
global RUN_FIG10_EXAMPLES         1  // example bunching-test figures
global RUN_TABLE_E1               1  // first-step bunching table
global RUN_TABLE_E2_AND_FIG9      1  // first-step robustness table and summary figure
global RUN_TABLE_G1_PERSISTENCE   1  // persistence / Markov transition outputs
global RUN_MAIN_TABLE2            1  // main second-step results
global RUN_MULTI_BUNCHED          1  // multiple-bunching heterogeneity table
global RUN_PRACTICE_HETEROGENEITY 1  // Appendix heterogeneity figures
global RUN_SUR_ROBUSTNESS         0  // optional SUR robustness block
global RUN_RESULTS_DENSITIES      1  // results-density figures

glo pra_controls="cont_PMS cont_other yrsexpIndi gp_1000p ONS_ruralD_*"
glo genOpts=`"  graphregion(color(white) lwidth(medium)) scheme(lean2) "'

	* All 41 non-affected indicators (not modified in 2011)
	glo thresholdsNA = "90		90		80			70			80			70	90			70		90		60		90		85		70		90		90		70		80		80		70		60		90	90		90		80		70		85		90		90		90			70			90		80		60		90		90		90			60			85			90			80			90"
	glo indicatorsNA = "AF03	AF04	ASTHMA03	ASTHMA06	ASTHMA08	BP5	CANCER03	CHD08	CHD09	CHD10	CHD12	COPD08	COPD10	COPD13	CKD02	CKD03	CKD05	CKD06	CVD02	DEM02	DM2	DM10	DM13	DM15	DM17	DM18	DM21	DM22	EPILEP06	EPILEP08	HF02	HF03	HF04	SMOKE03	SMOKE04	STROKE07	STROKE08	STROKE10	STROKE12	STROKE13	THYROI02"
	glo pointsNA 	 = "12      10      6           20          15          57  6           17      7       7       7       6		7		9		6       11      9       6       5       15       3   3       3       3       6       3       5       3       4           6           6      10       9      30      30       2           5           2           4           2           6"
	
	* All affected indicators (modified/removed in 2011)
	*glo thresholdsA = "90	90		70		90		80		90		80		70		90		90		90		90		90		90		60		90		50		70		90		90			90		90		50		90		90		90			70	"  // 
	*glo indicatorsA = "BP4	CHD05	CHD06	CHD07	CHD11	CHD02	COPD12	PP01	DEP01	DEP02	DEP03	DM5		DM9		DM11	DM12	DM16	DM23	DM24	DM25	EPILEP07	MH04	MH05	MH06	MH07	MH09	STROKE05	STROKE06"  // 
	* All 19 affected indicators (modified in 2011)  
	glo thresholdsA = "90	70		80		90		80		70		90		90		90   	90		60		50		70		90		90		90		50		90		70	"  
	glo indicatorsA = "BP4	CHD06	CHD11	CHD02	COPD12	CVD01	DEP01	DEP02	DEP03   DM9		DM12	DM23	DM24	DM25	MH04	MH05	MH06	MH09	STROKE06"  
	glo pointsA     = "18    17      7       7      5		8       8       25		20    	3      18      17       8      10       1       2       6       23      5"
	
		
	* All indicators whose points were reduced or thershold set upwards
	glo thresholdsAlp = "90		70		80		90		70	"  
	glo indicatorsAlp = "BP4	CHD06	COPD12	DEP01	STROKE06"  	
	
	* Definir para los de 70, un top performer como 90+ en Alp
	
forval i=1(1)9 {
	glo superCondL`i' = `i'
	glo superTitlL`i' = "Control: UL + `i' pp., Responsive practices: UL - 10 pp."
}


* These are the indicators for the SECOND STEP, we had removed MANUALLY those 
* that failed in the first stage
glo thresholdsBU = "90		90		80			70			80			90			90		60		90		90		70		80		60		90		80		90		70			90		80		90		90		 60       	85			90			80			"
glo indicatorsBU = "AF03	AF04	ASTHMA03	ASTHMA06	ASTHMA08	CANCER03	CHD09	CHD10	CHD12	COPD13 	CKD03	CKD06	DEM02	DM13	DM15	DM21	EPILEP08	HF02	HF03	SMOKE04	STROKE07 STROKE08	STROKE10	STROKE12	STROKE13	"

	
///////////////////////////////////////////////////////////////////////////////////////   
// * get packages

* ssc install postrcspline // for mkspline2; we are not using it here
* http://maartenbuis.nl/presentations/bonn09.pdf

* Get lincomest, which enhances lincom


////////////////////////////////////////////////////////////////////////////////  
**# 1. Define programs needed for this file
if 1==1 { 
	* ******************************************************************************
	* This program estimates the excess bunching at a given distribution
	* 1st. McCrary density discontinuity test
	* 2nd. Saez, Kleven style ....
	* ******************************************************************************
	* Use it like this: bunchingEst	, whichone("BP5") ul(70) nknots($nknots) h(2) wind($window) bw(0) b(1) doGraph(1)
	cap program drop bunchingEst
	program define bunchingEst , rclass
	syntax  [if] [in] , whichone(string) ul(real) nknots(integer) h(real) wind(real) [bw(real 0) b(real 1) noGRaph]

		qui {
		preserve	
	/*	
		* Examples for testing
		use "$dataDerived/QOFpracticePanel.dta", clear

		rename Hyper* BP*
		local whichone = "BP5"
		*local whichone = "ASTHMA06"
		local ul=70
		local h = 5
		local wind=10
		local doGraph=1
		local bw=0
		local b= 1
	*/
			noisily disp "Running: `whichone', h=`h', knots=`nknots', windows=`wind'"
			marksample touse
			keep if `touse'
			keep if `whichone'Achievement>0 & `whichone'Achievement<1

			////////////////////////////////////////////////////////////////////////
			// McCrary DC test
		
			gen indi100=`whichone'Achievement*100
				
			if `bw'==0 {
				DCdensity indi100 , breakpoint(`ul') generate(Xj Yj r0 fhat se_fhat) nograph b(`b') 
				drop Xj Yj r0 fhat se_fhat
				loc bw=min(r(bandwidth),`wind')
			}
			
			DCdensity indi100 , breakpoint(`ul') generate(Xj Yj r0 fhat se_fhat) nograph h(`bw') b(`b') 
			glo `whichone'_bins = r(binsize)
			glo `whichone'_binsPr   : disp %5.2f r(binsize) // For printing		
			glo `whichone'_bw       : disp %5.2f r(bandwidth)
			glo `whichone'_jump     : disp %5.2f r(theta)
			glo `whichone'_jumpSE   : disp %5.2f r(se)
			glo `whichone'_jumpzstat : disp %5.2f r(theta) /r(se)
			glo `whichone'_jumppval : disp %5.4f 2*(1-normal( abs(r(theta) /r(se)) ) )

			glo `whichone'_jumpstar = ""
			if ((${`whichone'_jumppval} < 0.1) )  glo `whichone'_jumpstar = "*" 
			if ((${`whichone'_jumppval} < 0.05) ) glo `whichone'_jumpstar = "**" 
			if ((${`whichone'_jumppval} < 0.01) ) glo `whichone'_jumpstar = "***" 		
			
			scalar theta = r(theta)
		
			* ......................................................................
			gen c = Yj if Xj!=. & Xj>0.5 & Xj<99.5
			gen Yjor = Yj
			rename Xj indi100r
			
			////////////////////////////////////////////////////////////////////////
			// Density estimation
			
			keep if indi100r>=(`ul'-`wind') & indi100r<=(`ul'+`wind')

			* Gen dummies at and above ul
			* Find 1st one at ul
			local listSum="exc0r"	// This is for the test of hyphotesis
			loc Obs=_N
			loc acum=0
			local maxval=`ul'
			forval obs=0(1)`Obs' {
				if (indi100r[`obs']>=`ul') & (indi100r[`obs']<=`ul'+`h') {				
					gen     exc`acum'r= 0
					replace exc`acum'r= 1 in `obs'
					local maxval=indi100r[`obs']
					if `obs'>0 local listSum="`listSum'+exc`acum'r"
					loc ++acum
				}
			}

			* Use a spline for approximating the density	
			mkspline spliCu = indi100r , displayknots cubic nknots(`nknots')
			reg c spliCu* exc* , r
			*tobit c spliCu* exc*, ll(0)
			*truncreg c spliCu* exc*, ll(0)
			
			predict splinePred , xb	
			est store r1
			
			* Produce counterfactual beans using Spline terms only ...

				foreach dummy of varlist exc* {
					replace `dummy'=0			
				}
				predict splinePredExc , xb	
			* ........................................................	
			
			// The excess bunching is the sum of all dummies in the regression
			// Use lincomest, which is as lincom, but savets its results! 
			// Bunching coefficient is scaled by the bin size below.
			est restore r1 
			noisily lincomest "(`listSum')*${`whichone'_bins}" 
			mat Re = r(table)
			mat list Re
			glo `whichone'_b     : disp %5.3f Re[1,1]
			glo `whichone'_bSE   : disp %5.3f Re[2,1]
			glo `whichone'_bzstat : disp %5.2f Re[3,1]
			glo `whichone'_bpval : disp %5.3f Re[4,1]		
			
			glo `whichone'_bstar = ""	
			if ((${`whichone'_bpval} < 0.1) )  glo `whichone'_bstar = "*" 
			if ((${`whichone'_bpval} < 0.05) ) glo `whichone'_bstar = "**" 
			if ((${`whichone'_bpval} < 0.01) ) glo `whichone'_bstar = "***" 		
						
			// An estimate of the amount of bunching, relative to the mass in 
			// the estimation window
			egen totalArea= total(splinePredExc)
			replace totalArea=totalArea*${`whichone'_bins}
			sum totalArea 
			glo `whichone'_avg   : disp %5.1f abs(${`whichone'_b}/r(mean))*100 
			
			noisily disp in red "Estimated b=${`whichone'_b} ${`whichone'_bstar} [t-stat=${`whichone'_bzstat}] (${`whichone'_avg}%)"
			scalar b     = ${`whichone'_avg}

			* ........................................................	
			if ("`graph'"!="nograph") {			
				
				foreach varDep in Yjor splinePred splinePredExc {
					replace `varDep'=`varDep'*100
					replace `varDep'=15 if `varDep'>15 & `varDep'!=.
					replace `varDep'=0 if `varDep'<0 & `varDep'!=.
				}
				
				loc ulL=`ul' +`h'
				tw (bar Yjor indi100r, fcolor(gs10) lcolor(gs10) barwidth(${`whichone'_bins})) ///
				   (line splinePred indi100r if splinePred>0, lcolor(orange_red) lwidth(medthick) lpattern(solid)) ///
				   (line splinePredExc indi100r if splinePredExc>0, lcolor(black) lwidth(medthick) lpattern(solid)) ///
				   , xline(`ul' `ulL' , lwidth(medthick) lpattern(dash) ) ///
				   graphregion(color(white) lwidth(medium)) scheme(Plotplain)  plotregion(margin(zero) lcolor(black)) ///
				   legend(order(1 "Empirical Density" 2 "Fitted Model" 3 "Counterfactual Density") position(6)) ///
				   title("`whichone'" "Estimated b=${`whichone'_b} ${`whichone'_bstar} [t-stat=${`whichone'_bzstat}]  (${`whichone'_avg}%)") /// // 				   title("`whichone'" "Estimated b=${`whichone'_avg}% ") 
				   caption("Binsize = ${`whichone'_binsPr}") ///
				   xtitle("Achievement") ytitle("Density") name( bunch_`whichone'  ,replace) ///
				   yscale(range(0 15)) ylabel(0 5 10 15)
			}
			
			return scalar b     = b
			return scalar theta = theta					
			
		restore	
		}
	end	

	* ******************************************************************************
	* Write a new line in the results table
	* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	* @ args: [varDepo] analysed indicator, [threshold] uppt
	cap program drop writeRow
	program define writeRow	, rclass
	args varDep uppt

		myCoeff2 1 1 "DAch`varDep':Below`varDep'"
		myCoeff2 2 1 "DAch`varDep':Af"
		myCoeff2 3 1 "DAch`varDep':inter`varDep'"
		
		qui count if e(sample)==1 & year==2010 & Below`varDep'==1 & OutzL`varDep'==0 & OutzU`varDep'==0
		local eneBel = r(N)
		qui count if e(sample)==1 & year==2010 & Below`varDep'==0 & OutzL`varDep'==0 & OutzU`varDep'==0
		local eneAbv = r(N)
		
		local comp = ""
		if ($pval3<0.05 & _b[DAch`varDep':inter`varDep']<0 ) local comp = "Comp"
		if ($pval3<0.05 & _b[DAch`varDep':inter`varDep']>0 ) local comp = "Subs"
		
		tex \rowcolor{Gray}
		tex \parbox[c]{3.5cm}{\raggedright `varDep'} & `uppt'\% & `eneBel' & `eneAbv' & $ $coef1 $star1 $ & $ $coef2 $star2 $ & $ $coef3 $star3 $ & `comp' \\*
		tex                                         &          &          &          & $ $sep1 $         & $ $sep2 $         & $ $sep3 $         &        \\
	end
	* ******************************************************************************
}
////////////////////////////////////////////////////////////////////////////////   
// -----------------------------------------------------------------------------
// Builds data/derived/QOFpracticePanel_ready.dta. Required input for all empirical outputs.
// -----------------------------------------------------------------------------
if ${RUN_BUILD_READY_PANEL} {
use "$dataDerived/QOFpracticePanel.dta", clear
rename Hyper* BP*
rename Diabetes* DM*
rename pp01_achiev	CVD01Achievement
rename pp02_achiev  CVD02Achievement

tab year, gen(yea_)	
gen Af= year>=2011
label var Af "After: Fcl. Year>=2011"
xtset prai year

// For these two, theare missings on prevalence for most years, however I found no 
// document that says that diabetes, CKD or epilepsy were not adjsuted by prevalence
replace diabet_unaprev= diabet_regcount/list
replace epilep_unaprev= epilep_regcount/list
replace kidney_unaprev= kidney_regcount/list

	* Determine the number of indicators in which the practice selected to be in
	* the corner solution UL
	forval yr=2009(1)2010 {
		preserve // ................................................................
		keep if year==`yr'
		
		cap rename Hyper* BP*
		cap rename Diabetes* DM*
		cap rename pp01_achiev	CVD01Achievement
		cap rename pp02_achiev  CVD02Achievement
		cap rename pp01_achievm PP01Achievement
		
		
		gen bunchedItems=0	
		gen topPerformers=0

		local numIn=0		
		foreach endo in "NA" "A" "Alp" {
			qui {
			gen bunchedItems`endo'=0	
			gen topPerformers`endo'=0
			local numIn`endo'=0
		
			local n : word count ${indicators`endo'}
			forval i=1(1)`n'  {	// 

				local varDepo : word `i' of ${indicators`endo'}
				local uppt   : word `i' of ${thresholds`endo'}
				local varDep = "`varDepo'Achievement"
				
				* Top performers and bunching per year .........................
				*disp in red "(yr=`yr') `varDep' with `uppt' "

				* 95 onwards, unless it is a difficult indicator
				loc top=95
				if `uppt'<=80 loc top=90	
				
				if ("`endo'"!="Alp") {
					replace bunchedItems=bunchedItems+ 1 if (`varDep'*100>=`uppt') & (`varDep'*100<=(`uppt'+$superCondL5) )				
					replace topPerformers=topPerformers+ 1 if (`varDep'*100>=`top') & (`varDep'<.)
					local numIn=`numIn'+1
				}
				
				if ("`endo'"!="") {
					replace bunchedItems`endo' =bunchedItems`endo' + 1 if (`varDep'*100>=`uppt') & (`varDep'*100<=(`uppt'+$superCondL5) )				
					replace topPerformers`endo'=topPerformers`endo'+ 1 if (`varDep'*100>=`top') & (`varDep'<.)
					local numIn`endo'=`numIn`endo''+1
				}					
			}
			
			}
			disp as text "(yr=`yr') Num Indicators `endo': `numIn`endo''"
		}
		disp as text "(yr=`yr') Num Indicators in total: `numIn'"		
		
		label var bunchedItems    "Number of restricted indicators by `yr' (out of `numIn') "
		label var bunchedItemsA   "Number of MODIFIED restricted indicators by `yr' (out of `numInA') "
		label var bunchedItemsAlp "Number of LOWERED SLOPE restricted indicators by `yr' (out of `numInAlp') "
		
		label var topPerformers    "Number of indicators in which the practice is a top performer by `yr' (out of `numIn') "
		label var topPerformersA   "Number of MODIFIED indicators in which the practice is a top performer by `yr' (out of `numInA') "
		label var topPerformersAlp "Number of LOWERED SLOPE indicators in which the practice is a top performer by `yr' (out of `numInAlp') "
		keep prai bunchedItems* topPerformers*
		gen year=`yr'+1
		
		rename bunchedItems*  bunchedItems*`yr'
		rename topPerformers* topPerformers*`yr'
		tempfile bitems
		save `bitems'
		
		restore  // ................................................................
		merge n:1 prai year using `bitems' , nogen
	}

	// Construct two versions: one for only modified indicators, one for all possible indicators
	loc tit=""
	loc titA  ="MODIFIED"
	loc titAlp="LOWERED SLOPE"
	foreach tipo in "" "A" "Alp" {
		gen bunchedItems`tipo'=.
		replace bunchedItems`tipo'=bunchedItems`tipo'2009 if year==2010
		replace bunchedItems`tipo'=bunchedItems`tipo'2010 if year==2011
		label var bunchedItems`tipo' "Number of `tit`tipo'' restricted indicators in t-1 (out of `numIn`tipo'') "

		gen topPerformers`tipo'=.
		replace topPerformers`tipo'=topPerformers`tipo'2009 if year==2010
		replace topPerformers`tipo'=topPerformers`tipo'2010 if year==2011
		label var topPerformers`tipo' "Number of `tit`tipo'' indicators with top performence in t-1 (out of `numIn`tipo'') "	
		
		* Now expand the info on top performance and multi-bunching over time
		foreach varo of varlist bunchedItems`tipo'2009 bunchedItems`tipo'2010  topPerformers`tipo'2009 topPerformers`tipo'2010 {
			cap drop xxx
			bys pra_code: egen xxx = max(`varo')
			replace `varo'= xxx
			drop xxx
		}
		
	}

	
	if ${RUN_DIAGNOSTIC_DISTR} { // Optional diagnostic distribution graphs
		hist  bunchedItems2010 if year==2010, xline(10 14 20 , lwidth(thick) ) d ///
			scheme(plotplain) xsize(5) ysize(6) xtitle(Number of indicators at the bunching window [UL, UL+3] in 2010)
		graph export "$imageFold/bunchedItemsDistribution2010.pdf", as(pdf) replace		

		hist  bunchedItems2009 if year==2010, xline(10 14 20 , lwidth(thick) ) d ///
			scheme(plotplain) xsize(5) xtitle(Number of indicators at the bunching window [UL, UL+3] in 2009)
		graph export "$imageFold/bunchedItemsDistribution2009.pdf", as(pdf) replace				
		
		histogram bunchedItemsA if year==2010, discrete xtitle( ///
			"Number of MODIFIED indicators (e{subscript:2})" "restricted at e{subscript:2}=UL{subscript:2} in t-1 (out of 19) ") ///
			scheme(plotplain) xsize(5) ysize(6) xlabel(0(4)16)
		graph export "$imageFold/bunchedItemsADistribution2010.pdf", as(pdf) replace	
			
		histogram topPerformersA if year==2010, discrete xtitle( ///
			"Number of MODIFIED indicators (e{subscript:2})" "with top performence in t-1 (out of 19) ") ///
			scheme(plotplain) xsize(5) ysize(6) xlabel(0(4)16)
		graph export "$imageFold/topPerformersADistribution2010.pdf", as(pdf) replace	
	}
	

	foreach endo in "NA" "A" {	
	
		local n : word count ${indicators`endo'}
		forval i=1(1)`n'  {	// 

			local varDepo : word `i' of ${indicators`endo'}
			local uppt   : word `i' of ${thresholds`endo'}
			local varDep = "`varDepo'Achievement"
			* .....................................
			* In order to obtain the relevant "Raw Practice Disease Prevalence"
			if substr("`varDepo'",1,2)=="AF" {
				qui gen relePrevalence`varDepo'=atrial_unaprev
			}
			else if substr("`varDepo'",1,2)=="HF" {
				qui gen relePrevalence`varDepo'=herfai_unaprev			
			}
			else if substr("`varDepo'",1,2)=="BP" {
				qui gen relePrevalence`varDepo'=hypert_unaprev			
			}
			else if substr("`varDepo'",1,2)=="DM" {
				qui gen relePrevalence`varDepo'=diabet_unaprev			
			}
			else if substr("`varDepo'",1,2)=="MH" {
				qui gen relePrevalence`varDepo'=menhea_unaprev			
			}			
			else if substr("`varDepo'",1,3)=="AST" {
				qui gen relePrevalence`varDepo'=asthma_unaprev			
			}
			else if substr("`varDepo'",1,3)=="CAN" {
				qui gen relePrevalence`varDepo'=cancer_unaprev			
			}			
			else if substr("`varDepo'",1,3)=="CHD" {
				qui gen relePrevalence`varDepo'=coronary_unaprev			
			}		
			else if substr("`varDepo'",1,3)=="CKD" {
				qui gen relePrevalence`varDepo'=kidney_unaprev			
			}		
			else if substr("`varDepo'",1,3)=="CVD" {
				qui gen relePrevalence`varDepo'=cvdpre_unaprev			
			}		
			else if substr("`varDepo'",1,3)=="DEM" {
				qui gen relePrevalence`varDepo'=demen_unaprev			
			}		
			else if substr("`varDepo'",1,3)=="DEP" {
				qui gen relePrevalence`varDepo'=depres_unaprev			
			}		
			else if substr("`varDepo'",1,3)=="EPI" {
				qui gen relePrevalence`varDepo'=epilep_unaprev			
			}		
			else if substr("`varDepo'",1,3)=="COP" {
				qui gen relePrevalence`varDepo'=pulmon_unaprev			
			}			
			else if substr("`varDepo'",1,3)=="SMO" {
				qui gen relePrevalence`varDepo'=smoke_unaprev		// FOCUS ON QOF PAYMETS (2013):  Achievement Payments for palliative care (PC001 and PC002), SMOK001, SMOK003, SMOK004 and BP001, will be calculated by multiplying the total number of Achievement Points by the QOF point value (Â£156.92).	
			}		
			else if substr("`varDepo'",1,3)=="STR" {
				qui gen relePrevalence`varDepo'=strokeh_unaprev			
			}		
			else if substr("`varDepo'",1,3)=="THY" {
				qui gen relePrevalence`varDepo'=hypoty_unaprev			
			}		
			
			qui sum relePrevalence`varDepo' if year==2009, d
			gen topPreval`varDepo' = relePrevalence`varDepo'>r(p75) if  relePrevalence`varDepo'!=.
		}
	}
	
	save "$dataDerived/QOFpracticePanel_ready.dta", replace
}
xx
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////	
**# 2. (First Step) Determining if there is a Corner Solution at UL...
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// a. Example bunching-test graphs =============================================
// Paper output: Figure 10 / empirical-strategy example figures.
// Output: output/figures/ExampleBunchingTest.pdf and alternative example PDFs.
if ${RUN_FIG10_EXAMPLES} { 
	use "$dataDerived/QOFpracticePanel_ready.dta", clear
	glo h = 3 		// Excluded range
	glo nknots = 5 	// 5 is the "default"	
	glo window = 10

	bunchingEst if year>=2009 & year<=2010 , whichone("THYROI02") ul(90) nknots($nknots) h($h) wind($window) 
	bunchingEst if year>=2009 & year<=2010 , whichone("COPD13") ul(90) nknots($nknots) h($h) wind($window)
	
	grc1leg bunch_THYROI02 bunch_COPD13 , scheme(Plotplain)
	graph export "$imageFold\ExampleBunchingTest.pdf", as(pdf) replace	
	*caption("Restricted Cubic Spline based on knots=$nknots. Bin width = 0.5 pp." "Included domain around UL = $window, excluded range=[UL,UL+$h]")
	
	****************
	* Alternative example

	bunchingEst if year>=2009 & year<=2010 , whichone("ASTHMA06") ul(70) nknots($nknots) h($h) wind($window) 
	bunchingEst if year>=2009 & year<=2010 , whichone("CHD12") ul(90) nknots($nknots) h($h) wind($window)
			
	grc1leg bunch_ASTHMA06 bunch_CHD12 , scheme(Plotplain)
	graph export "$imageFold\Alt_ExampleBunchingTest.pdf", as(pdf) replace		
	

	bunchingEst if year>=2009 & year<=2010 , whichone("CKD06") ul(80) nknots($nknots) h($h) wind($window) 
	bunchingEst if year>=2009 & year<=2010 , whichone("COPD13") ul(90) nknots($nknots) h($h) wind($window)

	
	grc1leg bunch_CKD06 bunch_COPD13 , scheme(Plotplain)
	graph export "$imageFold\Alt_ExampleBunchingTest2.pdf", as(pdf) replace		
	
	
	bunchingEst if year>=2009 & year<=2010 , whichone("DM17") ul(70) nknots($nknots) h($h) wind($window) 
	bunchingEst if year>=2009 & year<=2010 , whichone("CKD02") ul(90) nknots($nknots) h($h) wind($window)
	
	grc1leg bunch_DM17 bunch_CKD02 , scheme(Plotplain)
	graph export "$imageFold\Alt_ExampleBunchingTest3.pdf", as(pdf) replace		
	
	
	bunchingEst if year>=2009 & year<=2010 , whichone("BP5") ul(70) nknots($nknots) h($h) wind($window) 
	bunchingEst if year>=2009 & year<=2010 , whichone("COPD13") ul(90) nknots($nknots) h($h) wind($window)	
	grc1leg bunch_BP5 bunch_COPD13 , scheme(Plotplain)
	graph export "$imageFold\Alt_ExampleBunchingTest4.pdf", as(pdf) replace		
	
}

// b. Full first-step bunching exercise ========================================
// Paper output: Appendix Table E1; supporting per-indicator mass-production PNGs.
// Output: output/tables/testCornerv12alt.tex and output/figures/massProd/*.png.
if ${RUN_TABLE_E1} {
	
	use "$dataDerived/QOFpracticePanel_ready.dta", clear

	loc par_w "10 10 "
	loc par_h " 2  3 "
	loc par_b " 1  1 "

	loc opts = wordcount("`par_w'")

	* Start the table!!!
	cd "$tableFold"
	glo size="9cm"
	glo cols=`opts'+3
	loc colm1=$cols

		// Requires the following on the preamble
		//	\usepackage{array}
		//	\newcolumntype{C}[1]{>{\centering\let\newline\\\arraybackslash\hspace{0pt}}m{#1}}
		
		texdoc init testCornerv12alt , replace force
	qui {		
		tex {
		tex \scriptsize
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
		tex \begin{longtable}{l c c c c c c c c c c c c}
			tex \caption{QOF indicators corner test \label{tab:testCorner}}\\
			tex \toprule
				forval i=1(1)`colm1' {
					tex & \multicolumn{1}{c}{(`i')}
				}
				tex \\
			tex Indicator & UL //
				forval j=1(1)`opts' {
					local w : word `j' of `par_w'
					local h : word `j' of `par_h'
					local b : word `j' of `par_b'
					tex & \parbox[l]{0.9cm}{w=`w', h=`h', b=`b'}
				}
				tex & Bunched & \\			
			
			tex \midrule
		tex \endfirsthead
			tex \caption[]{(Continued)} \\
			tex \toprule
				forval i=1(1)`colm1' {
					tex & \multicolumn{1}{c}{(`i')}
				}
				tex \\
			tex Indicator & UL //
				forval j=1(1)`opts' {
					local w : word `j' of `par_w'
					local h : word `j' of `par_h'
					local b : word `j' of `par_b'
					tex & \parbox[l]{0.9cm}{w=`w', h=`h', b=`b'}
				}
				tex & Bunched & \\			
				
			tex \midrule
			
		tex \endhead
			tex \midrule \multicolumn{$cols}{r}{\emph{Continued on next page}}
		tex \endfoot
			tex \bottomrule
			tex \multicolumn{$cols}{l}{\parbox[l]{$size}{\textbf{Notes:} ///				
				Own calculations based on QOF data. ///
				In each column, a spline with 5 knots is estimated over the histogram of the indicator in the interval [UL-\textit{w},UL+\textit{w}]. ///
				The regressor includes dummies $ \gamma_k$ for each bin of size \textit{b} located in [UL,UL+\textit{h}]. ///
				Each coefficient in the table corresponds to the estimate of excess density (\textit{B}) at [UL,UL+\textit{h}] relative to the total number of practices included in  [UL-\textit{w},UL+\textit{w}]. ///
				The z-stats in brackets corresponds to H0: $ \sum_k \gamma_k = 0.$ /// // Optimal bin sizes (BS) and bandwidths (BW) for each indicator are chosen following McCrary implementation of the test. ///
				Significance: ** 5\%, *** 1\%. }} \\
		tex \endlastfoot
	}
	***************************
	
	/* For testing...
	glo thresholdsNA = "90   90"
	glo indicatorsNA = "AF03 THYROI02"
	*/	
	
	local n : word count $indicatorsNA
	forval i=1(1)`n'  {	// 

		local varDep : word `i' of $indicatorsNA
		local uppt   : word `i' of $thresholdsNA
		
		disp in red "`varDep' with `uppt' "
	
		local lname : variable label `varDep'Achievement
		if "`lname'"=="" local lname ="`varDep'"
		local lname = subinstr("`lname'","_","",.)
		local lname = subinstr("`lname'","&"," and ",.)		

		**************************************************
		glo line1=""
		glo line2=""
		
		
		loc Acbcoef=0
		loc Acbpval=0
		
		forval j=1(1)`opts' {
			local w : word `j' of `par_w'
			local h : word `j' of `par_h'
			local b : word `j' of `par_b'
			
			if `j'==2 { // Present: binsize, bw, jump***			
				qui bunchingEst if year>=2009 & year<=2010 & `varDep'Achievement>0 & `varDep'Achievement<100 & `varDep'Achievement!=. ///
					, whichone("`varDep'") ul(`uppt') nknots(5) h(`h') wind(`w') b(`b')
					
				loc bs=`b'*10
				gen bunchE`varDep'_w`w'h`h'b`bs'=${`varDep'_avg}
					
				graph export "$imageFold/massProd/`varDep'v11.png", as(png) replace

				window manage close graph "bunch_`varDep'"
				window manage close graph "Densi2nd_`varDep'"				
			}
			else {
				qui bunchingEst if year>=2009 & year<=2010 & `varDep'Achievement>0 & `varDep'Achievement<100 & `varDep'Achievement!=. ///
					, whichone("`varDep'") ul(`uppt') nknots(5) h(`h') wind(`w') b(`b') nograph
				loc bs=`b'*10
				gen bunchE`varDep'_w`w'h`h'b`bs'=${`varDep'_avg}
			}
		
			loc Acbcoef =max(`Acbcoef',${`varDep'_avg})
			loc Acbpval =max(`Acbpval',${`varDep'_bpval})
			disp "`Acbpval'"
			
			glo line1 = " $line1 & ${`varDep'_avg} $ ^{${`varDep'_bstar}} $ "
			glo line2 = " $line2 & [${`varDep'_bzstat}] "	
							
		}
		
		loc Goes=""
		if `Acbpval'<0.05 & `Acbcoef'>1 {
				loc Goes="Bunched"
		}
		
		tex \rowcolor{Gray}
		tex \parbox[c]{2.5cm}{\raggedright `lname'} & `uppt' $line1 & `Goes' \\ 
		tex                                         &        $line2 &        \\ 
		
	}
	***************************
	qui {
		tex \end{longtable}
		tex }
	}
	texdoc close
	***************************
		
}

// c. First-step robustness and summary graph ==================================
// Paper output: Appendix Table E2 and first-step summary figure.
// Output: output/tables/testCornerv12_rob.tex; output/figures/step1_summary.pdf.
if ${RUN_TABLE_E2_AND_FIG9} { 

	use "$dataDerived/QOFpracticePanel_ready.dta", clear

	loc par_w "10 10 12 12 10 "  // Windows above and bellow
	loc par_h " 2  3  2  3  4 "  // bunched area amplitude (F in the equations)
	loc par_b " 1  1  1  1  1 "  // bin-size

	loc opts = wordcount("`par_w'")


	* Start the table!!!
	cd "$tableFold"
	glo size="11cm"
	glo cols=`opts'+2
	loc colm1=$cols-1

		// Requires the following on the preamble
		//	\usepackage{array}
		//	\newcolumntype{C}[1]{>{\centering\let\newline\\\arraybackslash\hspace{0pt}}m{#1}}
		
		texdoc init testCornerv12_rob , replace force
	qui {		
		tex {
		tex \scriptsize
		tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
		tex \begin{longtable}{l c c c c c c c c c c c}
			tex \caption{QOF indicators corner test: additional exercises \label{tab:testCornerv12_rob}}\\
			tex \toprule
				forval i=1(1)`colm1' {
					tex & \multicolumn{1}{c}{(`i')}
				}
				tex \\
			tex Indicator & UL //
				forval j=1(1)`opts' {
					local w : word `j' of `par_w'
					local h : word `j' of `par_h'
					local b : word `j' of `par_b'
					tex & \parbox[l]{0.9cm}{w=`w', h=`h', b=`b'}
				}
				tex \\			
			
			tex \midrule
		tex \endfirsthead
			tex \caption[]{(Continued)} \\
			tex \toprule
				forval i=1(1)`colm1' {
					tex & \multicolumn{1}{c}{(`i')}
				}
				tex \\
			tex Indicator & UL //
				forval j=1(1)`opts' {
					local w : word `j' of `par_w'
					local h : word `j' of `par_h'
					local b : word `j' of `par_b'
					tex & \parbox[l]{0.9cm}{w=`w', h=`h', b=`b'}
				}
				tex \\			
			tex \midrule
			
		tex \endhead
			tex \midrule \multicolumn{$cols}{r}{\emph{Continued on next page}}
		tex \endfoot
			tex \bottomrule
			tex \multicolumn{$cols}{l}{\parbox[l]{$size}{\textbf{Notes:} ///				
				Own calculations based on QOF data. ///
				In each column, a spline with 5 knots is estimated over the histogram of the indicator in the interval [UL-\textit{w},UL+\textit{w}]. ///
				The regressor includes dummies $ \gamma_k$ for each bin of size \textit{b} located in [UL,UL+\textit{h}]. ///
				Each coefficient in the table corresponds to the estimate of excess density (\textit{B}) at [UL,UL+\textit{h}] relative to the total number of practices included in  [UL-\textit{w},UL+\textit{w}]. ///
				The z-stats in brackets corresponds to H0: $ \sum_k \gamma_k = 0.$ /// // Optimal bin sizes (BS) and bandwidths (BW) for each indicator are chosen following McCrary implementation of the test. ///
				Significance: ** 5\%, *** 1\%. }} \\
		tex \endlastfoot
	}
	***************************

	cap mat drop resultsB
	
	/* For testing...
	glo thresholdsNA = "90   90"
	glo indicatorsNA = "AF03 THYROI02"
	*/
	
	local n : word count $indicatorsNA
	forval i=1(1)`n'  {	// 

		local varDep : word `i' of $indicatorsNA
		local uppt   : word `i' of $thresholdsNA
		
		disp in red "`varDep' with `uppt' "
	
		local lname : variable label `varDep'Achievement
		if "`lname'"=="" local lname ="`varDep'"
		local lname = subinstr("`lname'","_","",.)
		local lname = subinstr("`lname'","&"," and ",.)		

		**************************************************
		glo line1=""
		glo line2=""
		
		
		loc Acbcoef=0
		loc Acbpval=0
		
		forval j=1(1)`opts' {
			local w : word `j' of `par_w'
			local h : word `j' of `par_h'
			local b : word `j' of `par_b'
			
			if `j'==2 { // Present: binsize, bw, jump***			
				qui bunchingEst if year>=2009 & year<=2010 & `varDep'Achievement>0 & `varDep'Achievement<100 & `varDep'Achievement!=. ///
					, whichone("`varDep'") ul(`uppt') nknots(5) h(`h') wind(`w') b(`b') nograph
					
				loc bs=`b'*10
				gen bunchE`varDep'_w`w'h`h'b`bs'=${`varDep'_avg}
					
				*graph export "$imageFold/massProd/`varDep'v11.png", as(png) replace

				*window manage close graph "bunch_`varDep'"
				*window manage close graph "Densi2nd_`varDep'"				
			}
			else {
				qui bunchingEst if year>=2009 & year<=2010 & `varDep'Achievement>0 & `varDep'Achievement<100 & `varDep'Achievement!=. ///
					, whichone("`varDep'") ul(`uppt') nknots(5) h(`h') wind(`w') b(`b') nograph
				loc bs=`b'*10
				gen bunchE`varDep'_w`w'h`h'b`bs'=${`varDep'_avg}
			}
		
			loc Acbcoef =max(`Acbcoef',${`varDep'_avg})
			loc Acbpval =max(`Acbpval',${`varDep'_bpval})
			disp "`Acbpval'"
			
			glo line1 = " $line1 & ${`varDep'_avg} $ ^{${`varDep'_bstar}} $ "
			glo line2 = " $line2 & [${`varDep'_bzstat}] "	
			
			mat define miRow = [`i',`j',`w',`h',`b', ${`varDep'_avg} , ${`varDep'_bzstat} , ${`varDep'_bpval}, `Acbcoef' , `Acbpval' ]
			mat rowname miRow = "`varDep'"
			mat define resultsB = nullmat(resultsB) \ miRow			
				
		}
		
		tex \rowcolor{Gray}
		tex \parbox[c]{2.5cm}{\raggedright `lname'} & `uppt' $line1 \\ 
		tex                                         &        $line2 \\ 
	
	}

	***************************
	qui {
		tex \end{longtable}
		tex }
	}
	texdoc close
	***************************
	
	
	
	mat colnames resultsB = i j w h b avg bzstat bpval Acbcoef Acbpval
	mat list resultsB	
	
	
	clear
	svmat2 resultsB , names(i j w h b avg bzstat bpval Acbcoef Acbpval) rnames(variable)
	*export delimited using "$tableFold/step1graph.csv" , replace	
	
	

	****************************************************
	* 2. Grupo clÃ­nico (prefijo del nombre del indicador)
	****************************************************
	* Extract the alphabetic prefix, e.g. AF03 -> AF, ASTHMA03 -> ASTHMA.
	gen str group = regexr(variable, "[0-9]+", "")   // remove digits
	replace group = "OTHER" if missing(group)

	* Define a stable plotting order.
	encode group, gen(groupid)
	label var group "Clinical group"
		
	* Create a plotting index with spacing between clinical groups.
	preserve
	keep variable groupid
	bysort variable: keep if _n == 1
	gen yi=_n
	tempname ypos	
	save `ypos' , replace
	restore
	* Volver a los datos completos
	merge m:1 variable using `ypos', nogen

	****************************************************
	* 3. Calcular SE e intervalos de confianza a partir de bzstat
	****************************************************
	* bzstat == z, entonces se = |avg / z|
	gen se = . 
	replace se = abs(avg / bzstat) if bzstat != 0

	gen ci_lo = avg - 1.96*se
	gen ci_hi = avg + 1.96*se

	****************************************************
	* 4. Indicador bunched por tu regla:
	*    bunched si Acbpval < 0.05 & Acbcoef > 1
	****************************************************
	gen byte bunched_row = (Acbpval < 0.05 & Acbcoef > 1)

	bysort variable w b: egen byte bunched = min(bunched_row) if h==2 | h==3    // To meet the table criteria

	****************************************************
	* 5. Construir el eje Y: un valor por indicador
	*    (las dos filas de h=2 y h=3 comparten la misma Y)
	****************************************************

	* Opcional: etiqueta de eje Y con nombre del indicador y â si es bunched	
	*bysort variable: egen byte bunched_ind = max(bunched)
	*gen str laby = variable
	*replace laby = laby + " â" if bunched_ind == 1

	

	* Ãndice base de 1..N en orden de grupo y variable, creando un espacio entre 
	* los grupos
	qui sum groupid
	gen y = yi+groupid - r(min)	
	
	cap label drop y
	labmask y , values(variable) lblname(y)

	* Put whit spaces in the labels of the "empty" indexes
	qui sum y
	loc lmax = r(max)
	* Loop over all possible values 1 to 55
	forvalues v = 1/`lmax' {
		capture local lab : label (y) `v'
		disp "`v': `lab'"
		if _rc | "`lab'"=="`v'"  {                         // if no label exists for this value
			label define y `v' " ", modify 
		}
	}	

	****************************************************
	* 6. GrÃ¡fico tipo forest plot
	*    - rcap: intervalos de confianza
	*    - scatter: puntos para h=2 (cÃ­rculo) y h=3 (cuadrado)
	*    - color distinto y tamaÃ±o mayor para bunched
	****************************************************
	
	
	
	qui sum y // To ensure the number of "ticks" in the label
	glo lmax=r(max)
	twoway ///
	(rcap ci_lo ci_hi y if h == 2, horizontal lcolor(gs12)) /// 	// IC para h = 2
	(scatter y avg if h == 2 & bunched == 0, /// 	// Puntos no bunched, h = 2
		msymbol(Oh) mcolor(black) msize(small)) ///
	(scatter y avg if h == 2 & bunched == 1, /// 	// Puntos bunched, h = 2 (mÃ¡s grandes y azul)
		msymbol(O) mcolor(navy) msize(small)) ///
	if w==10, ///
    ///
	text(0   -5 "Atrial Fibrillation", 		size(small) placement(e) justification(left) color(gs8) ) ///
	text(3   -5 "Asthma", 					size(small) placement(e) justification(left) color(gs8) ) ///
	text(7   -5 "Blood Pressure", 			size(small) placement(e) justification(left) color(gs8) ) ///
	text(9   -5 "Cancer", 					size(small) placement(e) justification(left) color(gs8) ) ///
	text(11  -5 "Coronary Heart Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
	text(16  -5 "Chronic Kidney Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
	text(21  -5 "C.O. Pulmonary Disease", size(small) placement(e) justification(left) color(gs8) ) ///
	text(25  -5 "Cardiovascular Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
	text(27  -5 "Dementia", 				size(small) placement(e) justification(left) color(gs8) ) ///
	text(29  -5 "Diabetes Mellitus", 		size(small) placement(e) justification(left) color(gs8) ) ///
	text(38  -5 "Epilepsy", 				size(small) placement(e) justification(left) color(gs8) ) ///
	text(41  -5 "Heart Failure", 			size(small) placement(e) justification(left) color(gs8) ) ///
	text(45  -5 "Smoking", 					size(small) placement(e) justification(left) color(gs8) ) ///
	text(48  -5 "Stroke and T.I.Attack", size(small) placement(e) justification(left) color(gs8) ) ///
	text(54  -5 "Thyroid Disease", 			size(small) placement(e) justification(left) color(gs8) ) ///
	///
	ylabel( 1(1)$lmax , valuelabel angle(horizontal) labsize(vsmall)  ) ///
	xlabel( -5 0 10 20 30 40) ///
	yscale(reverse) ///
	xline(0, lpattern(dash) lcolor(gs10)) ///
	xtitle("Excess bunching at UL with 95% CI", size(small)) ///
	ytitle("") ///
	legend(order(2 "No evidence of bunching" ///
				 3 "Evidence of bunching" ///
		   ) size(medsmall) region(lstyle(none))) ///
	xsize(5) ysize(10) title("(a) F=2", size(medsmall)) plotregion(margin(t=6)) ///
	name(a1, replace)
	
	twoway ///
	(rcap ci_lo ci_hi y if h == 3, horizontal lcolor(gs12)) /// 	// IC para h = 3
	(scatter y avg if h == 3 & bunched == 0, /// 	// Puntos no bunched, h = 3
		msymbol(Oh) mcolor(black) msize(small)) ///
	(scatter y avg if h == 3 & bunched == 1, /// 	// Puntos bunched, h = 3 (mÃ¡s grandes y azul)
		msymbol(O) mcolor(navy) msize(small)) ///
	if w==10, ///
    ///
	text(0   -5 "Atrial Fibrillation", 		size(small) placement(e) justification(left) color(gs8) ) ///
	text(3   -5 "Asthma", 					size(small) placement(e) justification(left) color(gs8) ) ///
	text(7   -5 "Blood Pressure", 			size(small) placement(e) justification(left) color(gs8) ) ///
	text(9   -5 "Cancer", 					size(small) placement(e) justification(left) color(gs8) ) ///
	text(11  -5 "Coronary Heart Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
	text(16  -5 "Chronic Kidney Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
	text(21  -5 "C.O. Pulmonary Disease", size(small) placement(e) justification(left) color(gs8) ) ///
	text(25  -5 "Cardiovascular Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
	text(27  -5 "Dementia", 				size(small) placement(e) justification(left) color(gs8) ) ///
	text(29  -5 "Diabetes Mellitus", 		size(small) placement(e) justification(left) color(gs8) ) ///
	text(38  -5 "Epilepsy", 				size(small) placement(e) justification(left) color(gs8) ) ///
	text(41  -5 "Heart Failure", 			size(small) placement(e) justification(left) color(gs8) ) ///
	text(45  -5 "Smoking", 					size(small) placement(e) justification(left) color(gs8) ) ///
	text(48  -5 "Stroke and T.I.Attack", size(small) placement(e) justification(left) color(gs8) ) ///
	text(54  -5 "Thyroid Disease", 			size(small) placement(e) justification(left) color(gs8) ) ///
	///
	ylabel( 1(1)$lmax , valuelabel angle(horizontal) labsize(vsmall)  ) ///
	xlabel( -5 0 10 20 30 40) ///
	yscale(reverse) ///
	xline(0, lpattern(dash) lcolor(gs10)) ///
	xtitle("Excess bunching at UL with 95% CI" , size(small)) ///
	ytitle("") ///
	legend(order(2 "No evidence of bunching" ///
				 3 "Evidence of bunching" ///
		   ) size(medsmall) region(lstyle(none))) ///
	xsize(5) ysize(10)  title("(b) F=3", size(medsmall)) plotregion(margin(t=6)) ///
	name(a2, replace)
	
	grc1leg2 a1 a2 , xsize(7) ysize(10) graphregion(margin(l 0 r 10) )

	
	graph export "$imageFold/step1_summary.pdf" , as(pdf) replace
	
}

// d. Markov transition matrix / persistence analysis ==========================
// Paper output: Appendix persistence table/diagnostic outputs.
// Output: data/derived/QOFind0910Markov.csv; data/derived/persistence_indicators.csv;
//         output/figures/HistogramGeneralBunching_modi*.pdf.
// It also provides a list of indicators with their persistence between 2009 and 2010.
if ${RUN_TABLE_G1_PERSISTENCE} {
	
	use "$dataDerived/QOFpracticePanel_ready.dta", clear
	
	glo lista=""
	foreach endo in "NA" "A" {
		local n : word count ${indicators`endo'}
		forval i=1(1)`n'  {	

			local varDepo : word `i' of ${indicators`endo'}
			local uppt   : word `i' of ${thresholds`endo'}
			local points   : word `i' of ${points`endo'}
			local varDep = "`varDepo'Achievement"	

			qui gen modi`varDepo'= "`endo'"=="A"
			
			gen achR`varDepo'= `varDep'*100 - `uppt'
			glo lista="$lista achR`varDepo'"
			
			gen points`varDepo'= `points'
				
		}
	}

	
	destring *Achievement, force replace
	keep prai year $lista modi* *Achievement relePrevalence* points*
	keep if year==2009 | year==2010	

	qui reshape long achR@ modi@ @Achievement relePrevalence@ points@ ///
		, i(prai year) j(indicator) string

	drop if Achievement==.
	drop if modi==.	
	
	recode achR (-100/-0.0000001=-1) (0/5=1) (5.0000000001/100=2), gen(categAchiP5)
	label define dx1 -1 "Below UL" 1 "[UL,UL+5]" 2 "Above UL+5" , replace
	label val categAchiP5 dx1
	
	recode achR (-100/-0.0000001=-1) (0/3=1) (3.0000000001/100=2), gen(categAchiP3)
	label define dx2 -1 "Below UL" 1 "[UL,UL+3]" 2 "Above UL+3" , replace
	label val categAchiP3 dx2
	
	recode achR (-100/-10.0000001=0) (-10/-0.0000001=1) (0/100=0), gen(categTreat)	
	label define dx3 1 "[UL-10,UL)" 0 "UL and above" , replace
	label val categTreat dx3	
	recode achR (-100/-0.0000001=0) (0/5=1) (5.0000000001/100=0), gen(categCont)	
	label define dx4 1 "Bunched" 0 "Not bunched" , replace
	label val categCont dx4
	
	
	reshape wide Achievement relePrevalence achR categAchiP5 categAchiP3 categTreat categCont points , i(prai indicator) j(year)
	export delimited using "$dataDerived/QOFind0910Markov.csv", replace nolabel
	
	

	*******************************************************************************
	* Super histogram
	import delimited "$dataDerived/QOFind0910Markov.csv", clear
	
	histogram achr2010 if modi==0 & achr2010>-10 & achr2010<10, width(1) percent xline(0) ///
		xtitle("Relative achievement in 2010") ylabel(0(5)15) ///
		xsize(4) ysize(5) scheme(plotplain) 
	graph export "$imageFold/HistogramGeneralBunching_modi0.pdf", as(pdf) replace			
	
	histogram achr2010 if modi==1 & achr2010>-10 & achr2010<10, width(1) percent xline(0) ///
		xtitle("Relative achievement in 2010") ylabel(0(5)15) ///
		xsize(4) ysize(5) scheme(plotplain)
	graph export "$imageFold/HistogramGeneralBunching_modi1.pdf", as(pdf) replace			
		
	
	*******************************************************************************
	* This is for the heat map of persistence ..................................	

	import delimited "$dataDerived/QOFind0910Markov.csv", clear	case(preserve)
	tab categAchiP52009 categAchiP52010, cell nofreq
	tab categAchiP32009 categAchiP32010, cell nofreq

	* ..........................................................................
	* Now, let's try to produce a persistence index of the indicators ..........
	* The goal here is to understand if characteristics of the indicator predict
	* the results we get. So far, nope
	
	gen keepsP5= categAchiP52009==categAchiP52010 if categAchiP52009!=.
	gen keepsP3= categAchiP32009==categAchiP32010 if categAchiP32009!=.

	gen keepsP5conB= categAchiP52009==categAchiP52010 if categAchiP52009==1
	gen keepsP3conB= categAchiP32009==categAchiP32010 if categAchiP32009==1	
	
	drop points2010
	
	collapse (mean) keepsP3 keepsP5 keepsP3conB keepsP5conB modi Achievement2009 relePrevalence* points2009 (sum) categTreat* categCont* , by(indicator) 
	*scatter keepsP5 keepsP3 // It's almost the same with both versions
	
	gen sizeCoverTre09=categCont2009/categTreat2009	// Size[UL,UL+5]/Size[UL-10,UL)
	gen sizeCoverTALL09=categCont2009/8305			// Apx total number of practices
	gen sizeCoverCALL09=categTreat2009/8305			// Apx total number of practices	
	gen armen=2/(1/sizeCoverTALL09+1/sizeCoverCALL09) // Harmonic mean
	drop categCont* categTreat*
	
	* Indicators flagged as bunched in the first-step exercise.
	gen sig=0
	replace sig=1 if indicator=="AF03"
	replace sig=1 if indicator=="AF04"
	replace sig=1 if indicator=="ASTHMA06"
	replace sig=1 if indicator=="CHD08"
	replace sig=1 if indicator=="CKD06"
	replace sig=1 if indicator=="CVD02"
	replace sig=1 if indicator=="DM13"
	replace sig=1 if indicator=="EPILEP08"
	
	reg sig points2009 armen keepsP5conB //... nope!

	sort indicator // The result is exported into âpersistence indicators.xlsxâ
	export delimited using "$dataDerived/persistence_indicators.csv", replace
	*restore	
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
**# 3. (Second Step) Run the test 2nd step for [UL-10,UL+3]
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

* Test ground for regresions .......................................
use "$dataDerived/QOFpracticePanel_ready.dta", clear
	glo controles = "bunchedItems"
	loc scond = "L3"
	loc varDepo = "AF03"
	local uppt = 90
	

	local varDep = "`varDepo'Achievement"
			
			disp in red "`varDep' with `uppt' "
		
			local lname : variable label `varDep'
			if "`lname'"=="" local lname ="`varDep'"
			local lname = subinstr("`lname'","_","",.)
			local lname = subinstr("`lname'","&"," and ",.)		
		
			xtset prai year 
			cap drop Below
			cap drop Be
			cap drop inter
			cap drop DAch
			cap drop Ach
			
			gen Be=`varDep'<(`uppt'/100) if `varDep'!=.
			replace Be=. if `varDep'>((`uppt'+ ${superCond`scond'} )/100)  // [UL+`scond',100]
			replace Be=. if `varDep'<((`uppt'- 10 )/100)                   // [  0 ,UL-10]
			gen Below=L.Be
	
			gen inter=Below*Af			
			
			label var Below "Below: Achiev<Th in t-1"
			label var inter "Below*After"

			gen Ach = `varDep'
			gen LAch = L.`varDep'
			gen DAch=D.`varDep' if year>=2010 // Variations from before might be induced by other changes of QOF
			
			reg   DAch Below if inrange(year,2010,2011), cluster(prai) // FD only for mMean reversion
				est store x0		
			xtreg   Ach Below i.year if inrange(year,2009,2011), fe cluster(prai) // FE only for mean reversion
				est store x1
			reg   DAch inter Below Af if inrange(year,2010,2011), cluster(prai)
				est store x2
			xtreg  Ach inter Below Af i.year if inrange(year,2009,2011), fe cluster(prai) // With data from 2010
				est store x3
					
			esttab x0 x1 x2 x3 , star(* 0.1 ** 0.05 *** 0.01) ///
				keep(inter Below Af SUM_QOFAchievement) order(inter Below Af SUM_QOFAchievement) ///
				mtitles("FD (Mrev)" "FE (Mrev)" "FD DiD" "FE" ) label				
				
*/				



**#  a. Main second-step OLS results ============================================
// Paper output: Main Table 2 and Appendix Table G2/F1 inputs.
// Output: output/tables/mainResults_K#L#.tex; output/tables/step2resultsB.csv;
//         output/tables/step2graph.csv; output/figures/step2_summary.pdf.
if ${RUN_MAIN_TABLE2} { 

	
	cd "$tableFold"

	cap mat drop resultsB
	glo controles = ""
	foreach k in 3 2 {  // Use if you want to add other specifications
	foreach l in 5 10 {  // Use if you want to add other specifications

		***************************
		* Automatic table. You can avoid running this bit if you don't want the table
		glo size="15cm"
		glo cols=8
		qui {
			// Requires the following on the preamble
			//	\usepackage{array}
			//	\newcolumntype{C}[1]{>{\centering\let\newline\\\arraybackslash\hspace{0pt}}m{#1}}
			
			local table_stub "mainResults_K`k'L`l'"
			local table_label "tab:mainResults_K`k'L`l'"
			if (`k'==3 & `l'==10) {
				local table_stub "mainResults_L3"
				local table_label "tab:mainResults_L3"
			}
			texdoc init `table_stub' , replace force
			tex {
			tex \scriptsize
			tex \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
			tex \begin{longtable}{l C{0.8cm} C{0.8cm} C{1.3cm} C{1.3cm} C{1.3cm} c c c c c}
				tex \caption{QOF indicators results: ${superTitlL`k'}  \label{`table_label'}}\\
				tex \toprule
				tex           &    & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)}  & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)}  \\
				tex           &    & \multicolumn{2}{c}{Descriptives} & \multicolumn{3}{c}{Estim. Regression Coefficients} & Classif. \\
				tex \cmidrule(r){1-2} \cmidrule(r){3-4} \cmidrule(r){5-7} 
				tex Indicator & UL & N     & N     & BELOW       & AFTER       & INTER         \\		
				tex           &    & Below & Above & $ \alpha_1$ & $ \alpha_2$ & $ \alpha_3$ \\
				tex \cmidrule(r){1-2} \cmidrule(r){3-4} \cmidrule(r){5-7} \cmidrule(r){8-8}
			tex \endfirsthead
				tex \caption[]{(Continued)} \\
				tex \toprule
				tex           &    & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)}  & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)}  \\
				tex           &    & \multicolumn{2}{c}{Descriptives} & \multicolumn{3}{c}{Estim. Regression Coefficients} & Classif. \\
				tex \cmidrule(r){1-2} \cmidrule(r){3-4} \cmidrule(r){5-7} 
				tex Indicator & UL & N     & N     & BELOW       & AFTER       & INTER         \\		
				tex           &    & Below & Above & $ \alpha_1$ & $ \alpha_2$ & $ \alpha_3$ \\
				tex \cmidrule(r){1-2} \cmidrule(r){3-4} \cmidrule(r){5-7} \cmidrule(r){8-8}
				
			tex \endhead
				tex \midrule \multicolumn{$cols}{r}{\emph{Continued on next page}}
			tex \endfoot
				tex \bottomrule
				tex \multicolumn{$cols}{l}{\parbox[l]{$size}{\textbf{Notes:} ///				
					Own calculations based on QOF data. ///
					\textbf{BELOW:} To have attained below the respective upper thershold in the first year of the variation (2009 for 2009-2010 and 2010 for 2010-2011). \textbf{AFTER:} 2010 to 2011 variation. \textbf{INTER:} Interaction between BELOW and AFTER. ///				
					All regressions include the number of items in which the practice was in the bunching area $ [UL, UL+5]$ in the previous year as a control. ///
					Clustered at practice-level standard errors in parenthesis. $ \dagger$ practices' descriptives are presented according to 2010 achievement, within the ${superCondL`k'} points window around $ UL$ . ///
					Significance: * 1\%, ** 5\%, *** 1\%. }} \\
					*Controls include the numbers of GPs per 1000 registered patients, patients list size, whether there is a GMS contract, average GPs years of reckonable service, rurality index, and practice-level calculated prevalence of coronary, stroke and hypertension diseases.
			tex \endlastfoot
		}
		***************************

		
		use "$dataDerived/QOFpracticePanel_ready.dta", clear	
		preserve		

		local n : word count $indicatorsBU
		
		disp in red "in"
		forval i=1(1)`n'  {	// 
	

		*forval i=1(1)1  {	// 	Testing purpuposes
		
			local varDepo : word `i' of $indicatorsBU
			local uppt   : word `i' of $thresholdsBU
			
			local varDep = "`varDepo'Achievement"
			
			disp in red "L`l' , K`k', `varDep' with `uppt' "
		qui {
		
			local lname : variable label `varDep'
			if "`lname'"=="" local lname ="`varDep'"
			local lname = subinstr("`lname'","_","",.)
			local lname = subinstr("`lname'","&"," and ",.)		
		
			xtset prai year 
			cap drop Below
			cap drop Be
			cap drop inter
			cap drop Ach
			cap drop DAch
			
			gen Be=`varDep'<(`uppt'/100) if `varDep'!=.
			replace Be=. if `varDep'>((`uppt'+ ${superCondL`k'} )/100)  // [UL+L`k',100]
			replace Be=. if `varDep'<((`uppt'- `l' )/100)                   // [  0 ,UL-`l']
			gen Below=L.Be
			
			replace Below=0 if year==2009 & Below==.
			
			gen inter=Below*Af
			
			label var Below "Below: Achiev<Th in t-1"
			label var inter "Below*After"

			gen Ach =  `varDep'
			gen DAch=D.`varDep' if year>=2010 // Variations from before might be induced by other changes of QOF
			
			reg   DAch Below $controles if year==2010, cluster(prai) // Mean reversion
				estadd ysumm
				sum Be if year==2009 & e(sample)==1
				estadd scalar atmean10=r(mean)	
				sum `varDep' if year==2009 & e(sample)==1
				estadd scalar meanAch10=r(mean)
				sum Be if year==2010 & e(sample)==1
				estadd scalar atmean11=r(mean)
				est store x0		
			reg   DAch Below $controles if year==2011, cluster(prai) // Difference without the mean reversion
				estadd ysumm
				sum Be if year==2010 & e(sample)==1
				estadd scalar atmean10=r(mean)	
				sum `varDep' if year==2010 & e(sample)==1
				estadd scalar meanAch10=r(mean)
				sum Be if year==2011 & e(sample)==1
				estadd scalar atmean11=r(mean)
				est store x1
			reg   DAch inter Below Af $controles if inrange(year,2010,2011), cluster(prai) // Main version
				estadd ysumm
				sum Be if year==2010 & e(sample)==1
				estadd scalar atmean10=r(mean)	
				sum `varDep' if year==2010 & e(sample)==1
				estadd scalar meanAch10=r(mean)
				sum Be if year==2011 & e(sample)==1
				estadd scalar atmean11=r(mean)
				tab prai if e(sample)==1
				estadd scalar enePra=r(r)			
				tab prai if e(sample)==1 & 	Below==1		
				estadd scalar eneBel=r(r)			
				tab prai if e(sample)==1 & 	Below==0
				estadd scalar eneAbv=r(r)			
				est store x2

			reghdfe  Ach inter Below Af $controles if inrange(year,2009,2011), a(prai year) cluster(prai) // Alternative FE specification requested during revision
			
				estadd ysumm
				sum Be if year==2010 & e(sample)==1
				estadd scalar atmean10=r(mean)		
				sum `varDep' if year==2010 & e(sample)==1
				estadd scalar meanAch10=r(mean)
				sum Be if year==2011 & e(sample)==1
				estadd scalar atmean11=r(mean)
				tab prai if e(sample)==1
				estadd scalar enePra=r(r)
				est store x3			
				
			reghdfe  Ach inter Below Af $controles if inrange(year,2005,2011), a(prai year) cluster(prai) // Alternative longer-panel FE specification
			
				estadd ysumm
				sum Be if year==2010 & e(sample)==1
				estadd scalar atmean10=r(mean)		
				sum `varDep' if year==2010 & e(sample)==1
				estadd scalar meanAch10=r(mean)
				sum Be if year==2011 & e(sample)==1
				estadd scalar atmean11=r(mean)
				tab prai if e(sample)==1
				estadd scalar enePra=r(r)
				est store x4				
						
		}
		disp in red "`varDep', with upper Th=`uppt'"
	 
		esttab x0 x1 x2 x3 x4 , star(* 0.1 ** 0.05 *** 0.01) keep(inter Below Af SUM_QOFAchievement) order(inter Below Af SUM_QOFAchievement) stats(N N_clust r2 ymean meanAch10 atmean10 atmean11 ) ///
			mtitles("2010 (Mrev)" "2011" "Basic" "+cont" ) label
			
		********
		* Fill table with the main results (x2) ...............................
			est restore x2
			myCoeff2 1 1 Below	
			myCoeff2 2 1 Af
			myCoeff2 3 1 int
			
			count if e(sample)==1 & year==2010 & Below==1
			local eneBel = r(N)
			count if e(sample)==1 & year==2010 & Below==0
			local eneAbv = r(N)
				
			local comp = ""
			if ($pval3<0.1 & _b[inter]<0 ) local comp = "Comp"
			if ($pval3<0.1 & _b[inter]>0 ) local comp = "Subs"
			
			tex \rowcolor{Gray}
			tex \parbox[c]{3.5cm}{\raggedright `varDepo'} & `uppt'\% & `eneBel' & `eneAbv' & $ $coef1 $star1 $ & $ $coef2 $star2 $ & $ $coef3 $star3 $ & `comp' \\*
			tex                                         &          &          &          & $ $sep1 $         & $ $sep2 $         & $ $sep3 $         &        \\

		* Fill the matrix for the graph ........................................
			* Load the alternative estimates for robustness plots
			
			mat define miRow = [`l',`k',`uppt' , `eneBel' , `eneAbv' ,  $coef1 , $se1 , $pval1  ,  $coef2 , $se2 , $pval2  ,  $coef3 , $se3 , $pval3  ]
			est restore x3
			myCoeff2 1 1 Below	
			myCoeff2 2 1 Af
			myCoeff2 3 1 int
			mat define miRow = [miRow ,  $coef1 , $se1 , $pval1  ,  $coef2 , $se2 , $pval2  ,  $coef3 , $se3 , $pval3  ]
			
			est restore x4
			myCoeff2 1 1 Below	
			myCoeff2 2 1 Af
			myCoeff2 3 1 int			
		mat define miRow = [miRow ,  $coef1 , $se1 , $pval1  ,  $coef2 , $se2 , $pval2  ,  $coef3 , $se3 , $pval3  ]
			
			mat rowname miRow = "`varDep'"
			mat define resultsB = nullmat(resultsB) \ miRow	
			
	}
	restore
	
		***************************
		qui {
			tex \end{longtable}
			tex }
			texdoc close	
			if (`k'==3 & `l'==10) copy "$tableFold/mainResults_L3.tex" "$tableFold/mainResults_K3L10.tex", replace
		}
		***************************
		
	}
	}

	
	mat colnames resultsB = l k uppt eneBel eneAbv 	coef1 se1 pval1 coef2 se2 pval2 coef3 se3 pval3 ///
												xt1coef1 xt1se1 xt1pval1 xt1coef2 xt1se2 xt1pval2 xt1coef3 xt1se3 xt1pval3 ///
												xt2coef1 xt2se1 xt2pval1 xt2coef2 xt2se2 xt2pval2 xt2coef3 xt2se3 xt2pval3
	mat list resultsB	
	
	clear
	svmat2 resultsB , names(l k uppt eneBel eneAbv ///
												coef1 se1 pval1 coef2 se2 pval2 coef3 se3 pval3 ///
												xt1coef1 xt1se1 xt1pval1 xt1coef2 xt1se2 xt1pval2 xt1coef3 xt1se3 xt1pval3 ///
												xt2coef1 xt2se1 xt2pval1 xt2coef2 xt2se2 xt2pval2 xt2coef3 xt2se3 xt2pval3 ///
	                    	) rnames(variable)
	export delimited using "$tableFold/step2resultsB.csv" , replace
	
	* **************************************************************************
	* Produce other results
	* **************************************************************************
	
	import delimited using "$tableFold/step2resultsB.csv", clear

	****************************************************
	* 1. Clinical group from indicator prefix
	****************************************************
	* Extract the alphabetic prefix, e.g. AF03 -> AF, ASTHMA03 -> ASTHMA.
	gen str group = regexr(variable, "[0-9]+", "")   // remove digits
	replace group = regexr(group, "Achievement", "")   // remove Achievement suffix
	replace group = "OTHER" if missing(group)
	
	
	* Define a stable plotting order.
	encode group, gen(groupid)
	label var group "Clinical group"
		
	* Create a plotting index with spacing between clinical groups.
	preserve
	keep variable groupid
	bysort variable: keep if _n == 1
	gen yi=_n
	tempname ypos	
	save `ypos' , replace
	restore
	* Volver a los datos completos
	merge m:1 variable using `ypos', nogen

	
	****************************************************
	* 2. Holm-Sidak step-down adjustment
	****************************************************
	* 1.1. Con todos los 25 indicadores ...............
		
	
	tempfile filo
	gen p_holm_sidak =.
	
	foreach k in 3 2 {  // Use if you want to add other specifications
	foreach l in 5 10 {  // Use if you want to add other specifications	
		disp "k`k' l  `l' "
		preserve
			drop p_holm_sidak			
			keep if k==`k' & l==`l'
			* pval3 contains the p-values.

			gen long id = _n

			* Ordenar por pval3
			sort pval3
			gen int i = _n
			count
			local m = r(N)

			* Holm-Sidak raw adjustment
			gen double p_hs_raw = 1 - (1 - pval3)^(`m' - i + 1)

			* Monotonize the step-down adjusted p-values.
			gen double p_holm_sidak = p_hs_raw
			replace p_holm_sidak = p_holm_sidak[_n-1] if _n>1 & p_holm_sidak < p_holm_sidak[_n-1]
			replace p_holm_sidak = min(p_holm_sidak, 1)

			* Return to the original order.
			sort id
			drop i p_hs_raw
			drop id
			
			rename p_holm_sidak p_holm_sidaktemp
			keep k l variable p_holm_sidaktemp
			save `filo' , replace
		restore	
		merge 1:1 variable k l using `filo' , nogen
		replace p_holm_sidak = p_holm_sidaktemp if k==`k' & l==`l'
		drop p_holm_sidaktemp
	}
	}

	* 1.2. Vamos a hacerlo por cada dominio ...
	gen p_holm_sidak_domain =.
	
	levelsof groupid , local(grupos)
	foreach k in 3 2 {  // Use if you want to add other specifications
	foreach l in 5 10 {  // Use if you want to add other specifications	
	foreach gp in `grupos' {		
		disp "k`k' l  `l' gp `gp'"
		preserve
			drop p_holm_sidak_domain
			keep if k==`k' & l==`l' & groupid==`gp'
			* pval3 contains the p-values.

			gen long id = _n

			* Ordenar por pval3
			sort pval3
			gen int i = _n
			count
			local m = r(N)

			* Holm-Sidak raw adjustment
			gen double p_hs_raw = 1 - (1 - pval3)^(`m' - i + 1)

			* Monotonize the step-down adjusted p-values.
			gen double p_holm_sidak`gp' = p_hs_raw
			replace p_holm_sidak`gp' = p_holm_sidak`gp'[_n-1] if _n>1 & p_holm_sidak < p_holm_sidak[_n-1]
			replace p_holm_sidak`gp' = min(p_holm_sidak`gp', 1)

			* Return to the original order.
			sort id
			drop i p_hs_raw
			drop id
			
			keep k l variable p_holm_sidak`gp'
			save `filo' , replace
		restore	
		merge 1:1 variable k l using `filo' , nogen
		replace p_holm_sidak_domain = p_holm_sidak`gp' if groupid==`gp' & k==`k' & l==`l'
		drop p_holm_sidak`gp'
	}
	}
	}
	
	
	export delimited using "$tableFold/step2graph.csv" , replace nolabel // <----------- Hacer la Tabla G2 con esto!!!
	
		
	* *************************************************************************
	* Now, the graphs
	* *************************************************************************
	import delimited using "$tableFold/step2graph.csv", clear case(preserve)
	keep if l==10  & k==3 
	
	foreach varo of varlist *coef* *se* {
		replace `varo' = `varo'*100 // Let's put these results in percentage points
	}	
	****************************************************
	* 3. Calcular SE e intervalos de confianza 90% a partir de bzstat
	****************************************************

	foreach suf in "" "xt1" "xt2" {
		gen `suf'ci_lo = `suf'coef3 - 1.645*`suf'se3
		gen `suf'ci_hi = `suf'coef3 + 1.645*`suf'se3		
	}
	


	****************************************************
	* 4. Indicador complemento/sustituto por tu regla:
	****************************************************
	
	gen complement = p_holm_sidak_domain<0.1 & coef3<0
	gen substitute = p_holm_sidak_domain<0.1 & coef3>0
		
	
	****************************************************
	* 5. Construir el eje Y: un valor por indicador
	*    (las dos filas de h=2 y h=3 comparten la misma Y)
	****************************************************

	* Opcional: etiqueta de eje Y con nombre del indicador y â si es bunched	
	gen str laby = regexr(variable, "Achievement", "")
	replace laby = laby + " (Comp)" if complement == 1
	replace laby = laby + " (Subs)" if substitute == 1

	

	* Ãndice base de 1..N en orden de grupo y variable, creando un espacio entre 
	* los grupos
	qui sum groupid
	gen y = yi+groupid - r(min)	
	
	cap label drop y
	labmask y , values(laby) lblname(y)

	* Put whit spaces in the labels of the "empty" indexes
	qui sum y
	loc lmax = r(max)
	* Loop over all possible values 1 to 55
	forvalues v = 1/`lmax' {
		capture local lab : label (y) `v'
		disp "`v': `lab'"
		if _rc | "`lab'"=="`v'"  {                         // if no label exists for this value
			label define y `v' " ", modify 
		}
	}	

	****************************************************
	* 6. GrÃ¡fico tipo forest plot
	*    - rcap: intervalos de confianza
	*    - scatter: puntos para h=2 (cÃ­rculo) y h=3 (cuadrado)
	*    - color distinto y tamaÃ±o mayor para bunched
	****************************************************
	
	gen xlab = ci_hi + 0.3   // offset to the right of CI for the text label
	gen str coef_lbl = string(coef3, "%4.2f")

	* p-values labels
	format %4.3f p_holm_sidak_domain // Nice format for the graph
	cap drop xlmi
	gen xlmi = 5
		
	qui sum y // To ensure the number of "ticks" in the label
	loc lmax=r(max)
	twoway ///
	(rcap ci_lo ci_hi y , horizontal lcolor(gs12)) /// 	// IC
	(scatter y coef3 if complement == 0, /// 	// Puntos nada
		msymbol(Oh) mcolor(black) msize(small)) ///
	(scatter y coef3 if complement == 1, /// 	// Puntos complement
		msymbol(O) mcolor(black) msize(small)) ///
	(scatter y xlab,  msymbol(none) mlabel(coef_lbl) /// // mLabel text
		mlabpos(0) mlabsize(vsmall) mlabcolor(gs6) ) /// 
	(scatter y xlmi if p_holm_sidak_domain>0.1,  msymbol(none) mlabel(p_holm_sidak_domain) /// // p-val mLabel text not-signif
		mlabpos(0) mlabsize(vsmall) mlabcolor(gs12) ) /// 		
	(scatter y xlmi if p_holm_sidak_domain<0.1,  msymbol(none) mlabel(p_holm_sidak_domain) /// // p-val mLabel text signif
		mlabpos(0) mlabsize(vsmall) mlabcolor(black) ) /// 				
	, ///
    ///
	text(0   -10 "Atrial Fibrillation", 	size(small) placement(e) justification(left) color(gs8) ) ///
	text(3   -10 "Asthma", 					size(small) placement(e) justification(left) color(gs8) ) ///
	text(7   -10 "Cancer", 					size(small) placement(e) justification(left) color(gs8) ) ///
	text(9   -10 "Coronary Heart Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
	text(13  -10 "Chronic Kidney Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
	text(16  -10 "Chronic Obstructive Pulmonary Disease", size(small) placement(e) justification(left) color(gs8) ) ///
	text(18  -10 "Dementia", 				size(small) placement(e) justification(left) color(gs8) ) ///
	text(20  -10 "Diabetes Mellitus", 		size(small) placement(e) justification(left) color(gs8) ) ///
	text(24  -10 "Epilepsy", 				size(small) placement(e) justification(left) color(gs8) ) ///
	text(26  -10 "Heart Failure", 			size(small) placement(e) justification(left) color(gs8) ) ///
	text(29  -10 "Smoking", 				size(small) placement(e) justification(left) color(gs8) ) ///
	text(31  -10 "Stroke and Transient Ischaemic Attack", size(small) placement(e) justification(left) color(gs8) ) ///
	///
	text(-0.5  3.8 "MHT p-val", size(small) placement(e) justification(left) color(gs8) ) ///
	///
	ylabel( 1(1)`lmax' , valuelabel angle(horizontal) labsize(vsmall)  ) ///
	yscale(reverse) ///
	xline(0, lpattern(dash) lcolor(gs10)) ///
	xtitle("Variation on achievement (pp.)") 	///
	ytitle("") ///
	legend(order(2 "Not statistically significant" ///
				 3 "Complement") pos(6) ///
		   region(lstyle(none))) ///
	xsize(5) ysize(6)	

	graph export "$imageFold/step2_summary.pdf" , as(pdf) replace
	
		
		
	*******************************************************
**# b TABLE: Robustness to other specifications (Needs to run first the main second-step block so we get step2graph)
// Paper output: Table F1 / robustness variants, subject to final manuscript cross-check.
	*******************************************************

	cd "$tableFold"

	*******************************************************
	* 1. Import Excel results
	*******************************************************

	import delimited using "$tableFold/step2graph.csv", clear case(preserve)

	rename variable ind_id

	*******************************************************
	* 2. Temporary dictionary with table labels
	*******************************************************

	tempfile lblmap
	preserve
	clear
	input str25 ind_id str244 ind_label
	"AF03Achievement"       "AF 3 - AF patients on anticoagulants/antiplatelets (UL=90)"
	"AF04Achievement"       "AF 4 - AF diagnosis confirmed by ECG/specialist (UL=90)"
	"ASTHMA06Achievement"   "ASTHMA 6 - Asthma review in last 15 months (UL=70)"
	"ASTHMA08Achievement"   "ASTHMA 8 - Asthma diagnosis with variability test (UL=80)"
	"COPD13Achievement"     "COPD 13 - COPD review with breathlessness assessment (UL=90)"
	"CKD06Achievement"      "CKD 6 - Albumin/creatinine ratio in CKD patients (UL=80)"
	"DEM02Achievement"      "DEM 2 - Dementia patient care review (UL=60)"
	"DM13Achievement"       "DM 13 - Microalbuminuria test in diabetes patients (UL=90)"
	"SMOKE04Achievement"    "SMOKING 4 - Smoking cessation advice for smokers (UL=90)"
	"STROKE10Achievement"   "STROKE 10 - Flu vaccine in stroke/TIA patients (UL=85)"
	end

	gen ind_order = _n
	save "`lblmap'", replace
	restore

	merge m:1 ind_id using "`lblmap'", nogen keep(match)

	*******************************************************
	* 3. Keep only relevant (k,l) combinations
	*******************************************************

	keep if (k==2 & inlist(l,5,10)) | (k==3 & inlist(l,5,10))

	gen str8 spec = "k" + string(k) + "l" + string(l)

	keep ind_id ind_label ind_order spec coef3 p_holm_sidak_domain

	reshape wide coef3 p_holm_sidak_domain, i(ind_id ind_label ind_order) j(spec) string

	sort ind_order

	*******************************************************
	* 4. Export LaTeX table
	*******************************************************

	texdoc init mainResults_Multih, replace force

	texdoc write "\begin{table}[H]"
	texdoc write "\caption{Estimates of the interaction term in regression (4) on the QOF dataset. Alternative window configurations \label{tab:mainResults_Multih}}"
	texdoc write "\begin{adjustbox}{max width=1.1\textwidth}"
	texdoc write "\begin{tabular}{l c c c c}"
	texdoc write "\toprule"
	texdoc write "\multicolumn{5}{l}{Estimate of \$ \alpha_3\$ under alternative \$(k,l)\$ configurations in \$ [UL-l,UL+k]\$} \\"
	texdoc write "\multicolumn{5}{l}{Holm-Sidak adjusted \$p\$-values in brackets; coefficients in bold if \$p<0.05\$.} \\"
	texdoc write "\midrule"
	texdoc write "Indicator & \$k=2,\,l=5\$ & \$k=2,\,l=10\$ & \$k=3,\,l=5\$ & \$k=3,\,l=10\$ \\"
	texdoc write "\midrule"

	quietly {
		forvalues i = 1/`=_N' {

			local lbl = ind_label[`i']

			foreach s in k2l5 k2l10 k3l5 k3l10 {

				local coef_`s' = coef3`s'[`i']
				local p_`s'    = p_holm_sidak_domain`s'[`i']

				if missing(`coef_`s'') {
					local cell_`s' ""
					local pcell_`s' ""
				}
				else {
					local c : display %9.3f `coef_`s''
					local c = trim("`c'")
					if `p_`s'' < 0.05 {
						local cell_`s' "\textbf{\$`c'\$}"
					}
					else {
						local cell_`s' "\$`c'\$"
					}

					local pv : display %9.3f `p_`s''
					local pv = trim("`pv'")
					local pcell_`s' "\$[`pv']\$"
				}
			}

			texdoc write "\rowcolor{Gray}"
			texdoc write "\parbox[c]{5.2cm}{\raggedright `lbl'} & `cell_k2l5' & `cell_k2l10' & `cell_k3l5' & `cell_k3l10' \\"
			texdoc write " & `pcell_k2l5' & `pcell_k2l10' & `pcell_k3l5' & `pcell_k3l10' \\"
			texdoc write ""
		}
	}

	texdoc write "\bottomrule"
	texdoc write "\multicolumn{5}{l}{\parbox[l]{22cm}{\textbf{Notes:} Holm-Sidak adjusted \$p\$-values are reported in brackets for each \$(k,l)\$ configuration; coefficients are bold if \$p<0.05\$.}} \\"
	texdoc write "\end{tabular}"
	texdoc write "\end{adjustbox}"
	texdoc write "\end{table}"

	texdoc close
	copy "$tableFold/mainResults_Multih.tex" "$tableFold/alpha3_holmsidak_altKL.tex", replace
	
}


* ****************************************************************************
**# d. Bunching in multiple indicators heterogeneity
*    This is done with interactions, not with conditions.
*    Af is not interacted with the restriction variable, so the comparison is
*    done against [UL, UL+3] irrespective of the condition.
*    Paper output: appendix table on multiple-bunching heterogeneity.
*    Output: output/tables/multiBunched_L3.tex.
if ${RUN_MULTI_BUNCHED} {
	

	glo size="8cm"
	glo cols=4

		// Requires the following on the preamble
		//	\usepackage{array}
		//	\newcolumntype{C}[1]{>{\centering\let\newline\\\arraybackslash\hspace{0pt}}m{#1}}
		
		texdoc init multiBunched_L3 , replace force
	qui {
		tex \begin{table}[H] 
		tex \caption{Estimates of $\alpha_{3}$. Heterogeneity according to the number of indicators that PHCs have at the bunching window $ [UL,UL+3]$ \label{tab:multiBunched_`scond'}}\\
		tex \begin{adjustbox}{max width=\textwidth}
		tex %\begin{tabular}{l C{2.3cm} C{2.3cm} C{2.3cm} C{2.3cm}}
		tex \begin{tabular}{l C{2.5cm} C{2.3cm} C{2.3cm} C{2.3cm}}
		tex \toprule
		tex & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)}  & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)}  \\
		tex Indicator & Main & \multicolumn{3}{c}{At the bunching region $[UL,UL+3]$ in at least} \\
		tex \cmidrule(r){3-5}
		tex  &  & 20 indicators & 14 indicators & 10 indicators  \\
		tex \cmidrule(r){2-2} \cmidrule(r){3-5}			
	}
	***************************	
	
	glo top=3
	
	use "$dataDerived/QOFpracticePanel_ready.dta", clear	
	* 0 for few bunched
	cap drop interato*
	
	gen interato1 = bunchedItems2010>=20 // The 0 covers 78% of the practices
	gen interato2 = bunchedItems2010>=14 // The 0 covers 45% of the practices
	gen interato3 = bunchedItems2010>=10 // The 0 covers 21% of the practices

	cap mat drop resultsB
	
	local n : word count $indicatorsBU
	forval i=1(1)`n'  {	// 
	
		local varDepo : word `i' of $indicatorsBU
		local uppt   : word `i' of $thresholdsBU
		local varDep = "`varDepo'Achievement"

		disp in red "`i',`varDepo', `uppt'"
		* ......................................................................
		* The following lines generate the code for estimating the main effect --- Reference
		* ..................................................................

		
		xtset prai year 
		cap drop Below
		cap drop Be
		cap drop inter
		cap drop DAch
		
		gen Be=`varDep'<(`uppt'/100) if `varDep'!=.
		replace Be=. if `varDep'>((`uppt'+ 3 )/100)    // [UL+3, 100]
		replace Be=. if `varDep'<((`uppt'- 10 )/100)    // [0   ,UL-10]						
		
		gen Below=L.Be
		gen inter=Below*Af
		
		label var Below "Below: Achiev<Th in t-1"
		label var inter "Below*After"

		gen DAch=D.`varDep' if year>=2010 // Variations from before might be induced by other changes of QOF

		reg   DAch inter Below Af  $controles  if inrange(year,2010,2011), cluster(prai)		
		
		est store r`i'_0
	
		myCoeff2 10 1 "inter"
		mat define miRow = [`i',0, $coef10 , $se10 , $pval10   ]
		mat rowname miRow = "`varDepo'"
		mat define resultsB = nullmat(resultsB) \ miRow			

	
		* ......................................................................
		* The following lines generate the code for estimating  With Interactions
		*  ..................................................................
		
		
		forval conda=1(1)$top {
			
								
			xtset prai year 
			cap drop Below
			cap drop Be
			cap drop inter
			cap drop DAch
			cap drop BelowZ
			cap drop interZ
			cap drop AfZ
			
			
			gen Be=`varDep'<(`uppt'/100) if `varDep'!=.
			replace Be=. if `varDep'>((`uppt'+ 3 )/100)    // [UL+3, 100]
			replace Be=. if `varDep'<((`uppt'- 10 )/100)    // [0   ,UL-10]						
			
			gen Below=L.Be
			gen inter=Below*Af
			
			label var Below "Below: Achiev<Th in t-1"
			label var inter "Below*After"
			
			gen  BelowZ=Below*interato`conda'
			gen  AfZ   =Af*interato`conda'
			gen  interZ=inter*interato`conda'

			gen DAch=D.`varDep' if year>=2010 // Variations from before might be induced by other changes of QOF

			reg   DAch inter Below Af  interZ BelowZ AfZ $controles  if inrange(year,2010,2011), cluster(prai)		
			
			est store r`i'_`conda'						
			
			myCoeff2 10 1 "inter"
			mat define miRow = [`i',`conda', $coef10 , $se10 , $pval10   ]
			mat rowname miRow = "`varDepo'"
			mat define resultsB = nullmat(resultsB) \ miRow				
			
		}
	}
	
	mat colname resultsB = i conda coef10 se10 pval10
	mat list resultsB		

	* ......................................................................
	* Multiple hypotheses testing	
	
	* 1. Clinical group from indicator prefix ..................
	
	clear
	svmat2 resultsB , names(i conda coef10 se10 pval10) rnames(variable)		
	drop i 
	
	* Extract the alphabetic prefix, e.g. AF03 -> AF, ASTHMA03 -> ASTHMA.
	gen str group = regexr(variable, "[0-9]+", "")   // remove digits
	replace group = regexr(group, "Achievement", "")   // remove Achievement suffix
	replace group = "OTHER" if missing(group)
	
	
	* Define a stable plotting order.
	encode group, gen(groupid)
	label var group "Clinical group"
		
	* Create a plotting index with spacing between clinical groups.
	preserve
	keep variable groupid
	bysort variable: keep if _n == 1
	gen yi=_n
	tempname ypos	
	save `ypos' , replace
	restore
	* Volver a los datos completos
	merge m:1 variable using `ypos', nogen

	
	* 2. Holm-Sidak step-down adjustment ...........................
	
	gen p_holm_sidak_domain =.
	
	tempfile filo
	levelsof groupid , local(grupos)
	foreach conda in 0 1 2 3 {  // Use if you want to add other specifications
	foreach gp in `grupos' {		
		disp "conda`conda' gp `gp'"
		preserve
			drop p_holm_sidak_domain
			keep if conda==`conda' & groupid==`gp'
			* La variable pval10 tiene los p-values

			gen long id = _n

			* Ordenar por pval10
			sort pval10
			gen int i = _n
			count
			local m = r(N)

			* Holm-Sidak raw adjustment
			gen double p_hs_raw = 1 - (1 - pval10)^(`m' - i + 1)

			* Monotonize the step-down adjusted p-values.
			gen double p_holm_sidak`gp' = p_hs_raw
			replace p_holm_sidak`gp' = p_holm_sidak`gp'[_n-1] if _n>1 & p_holm_sidak < p_holm_sidak[_n-1]
			replace p_holm_sidak`gp' = min(p_holm_sidak`gp', 1)

			* Return to the original order.
			sort id
			drop i p_hs_raw
			drop id
			
			keep conda variable p_holm_sidak`gp'
			save `filo' , replace
		restore	
		merge 1:1 variable conda using `filo' , nogen
		replace p_holm_sidak_domain = p_holm_sidak`gp' if groupid==`gp' & conda==`conda'
		drop p_holm_sidak`gp'
	}
	}

	tempfile results_pvals
	save `results_pvals'

	
	* Temporary dictionary with table labels ..................................
	

	tempfile lblmap
	preserve
	clear
	input str25 variable str244 ind_label
    "AF03"       "AF 3 - AF patients on anticoagulants/antiplatelets (UL=90)"
    "AF04"       "AF 4 - AF diagnosis confirmed by ECG/specialist (UL=90)"
    "ASTHMA03"   "ASTHMA 3 - Smoking status in young asthma patients (UL=80)"
    "ASTHMA06"   "ASTHMA 6 - Asthma review in last 15 months (UL=70)"
    "ASTHMA08"   "ASTHMA 8 - Asthma diagnosis with variability test (UL=80)"
    "CANCER03"   "CANCER 3 - Cancer review 6 months post-diagnosis (UL=90)"
    "CHD09"      "CHD 9 - CHD patients on antiplatelets/anticoagulants (UL=90)"
    "CHD10"      "CHD 10 - CHD patients on beta-blockers (UL=60)"
    "CHD12"      "CHD 12 - Flu vaccine in CHD patients (UL=90)"
    "COPD13"     "COPD 13 - COPD review with breathlessness assessment (UL=90)"
    "CKD03"      "CKD 3 - BP â¤140/85 in CKD patients (UL=70)"
    "CKD06"      "CKD 6 - Albumin/creatinine ratio in CKD patients (UL=80)"
    "DEM02"      "DEM 2 - Dementia patient care review (UL=60)"
    "DM13"       "DM 13 - Microalbuminuria test in diabetes patients (UL=90)"
    "DM15"       "DM 15 - ACE/ARB therapy in diabetes with proteinuria (UL=80)"
    "DM21"       "DM 21 - Retinal screening in diabetes patients (UL=90)"
    "EPILEP08"   "EPILEPSY 8 - Seizure-free epilepsy patients recorded (UL=70)"
    "HF02"       "HF 2 - HF diagnosis confirmed by echo/specialist (UL=90)"
    "HF03"       "HF 3 - HF patients on ACE/ARB therapy (UL=80)"
    "SMOKE04"    "SMOKING 4 - Smoking cessation advice for smokers (UL=90)"
    "STROKE07"   "STROKE 7 - Cholesterol recorded in stroke/TIA patients (UL=90)"
    "STROKE08"   "STROKE 8 - Cholesterol â¤5mmol/L in stroke/TIA patients (UL=60)"
    "STROKE10"   "STROKE 10 - Flu vaccine in stroke/TIA patients (UL=85)"
    "STROKE12"   "STROKE 12 - Antiplatelet/anticoagulant in stroke/TIA patients (UL=90)"
    "STROKE13"   "STROKE 13 - New stroke/TIA patients referred for tests (UL=80)"
	end


	gen ind_order = _n
	save `lblmap', replace
	restore
	
	* ......................................................................
	* Put relevant results in the TeX table

	local n : word count $indicatorsBU
	forval i=1(1)`n'  {	// 
		use `lblmap', clear
		local varDepo : word `i' of $indicatorsBU
		local uppt   : word `i' of $thresholdsBU

		keep if variable == "`varDepo'"		
		loca varLab = ind_label[1]
		if "`varLab'"=="" loc varLab = "`varDepo'"
		
		loc anything=0
		loc linea1=""
		loc linea2=""	
		forval conda=0(1)$top {

			preserve // Load the p-vals after the multiple hypothesis testing
			use `results_pvals', clear
			keep if conda==`conda' & variable=="`varDepo'"
			
			disp in red "`varDepo': conda `conda' "
			summarize pval10			
			summarize p_holm_sidak_domain
			loc mhtpval : disp %4.3f r(mean)
			
			restore			
			
			
			est restore r`i'_`conda'
			myCoeff2 10 1 "inter"
			loc linea1 = "`linea1' & $ $coef10 $" 
			*loc linea2 = "`linea2' & $ $sep10 $"		
			loc linea2 = "`linea2' & $ [`mhtpval'] $"		
			loc something=$pval10 < 0.1
			loc anything=max(`anything',`something')	
			disp "$pval10"
			
		}
		disp "`varDepo' & `linea1' & `anything'"
		
		if `anything'==1 {		
			tex \rowcolor{Gray}
			tex \parbox[c]{5.2cm}{\raggedright `varLab'} `linea1' \\
			tex 									      `linea2' \\
		}
	
	}
		

	***************************
	qui {
		tex \bottomrule
		tex \addlinespace
		tex \multicolumn{5}{l}{\parbox[l]{14cm}{\textbf{Notes:}  Own calculations based on QOF data.                  ///
			Estimates obtained using the regression (4)), but with interactions ///
			between the covariates and the dummy variable $\mathbbm{1}\{ PB_i \geq s \} $ that indicates whether ///
			PHC $i$ has at least $s$ indicators in the bunching region, $[UL,UL+3]$, in 2009-10. Columns (2), (3), (4) ///
			report the estimates of $\alpha_{3}$, without the interaction with $\mathbbm{1}\{ PB_i \geq s \}$, hence ///
			the coefficient corresponding to the PHCs with fewer than $s$ indicators in the bunching window. ///
			All regressions include the number of indicators in which the PHC was in the bunching area $ [UL, UL+3]$ ///
			in 2009-10 as a control. Standard errors, reported in parenthesis, are clustered at PHC level.
		tex	Significance: * 10\%, ** 5\%, *** 1\%. }} \\
		tex \end{tabular}
		tex \end{adjustbox}
		tex \end{table}
	}
	texdoc close	
	***************************		
	

	
}

* ****************************************************************************
**# e. Heterogeneity on PHC/GP-practice characteristics


*1. Create closures variables, proxied with the disappearance of patients.
* 1.1. Get the population at risk with the denominators of the register indicators.
* 1.2. If the PCT shrinks to below 10% of its level, it is a closure.
*2. Define if the PCT was affected by a PHC closure in these years.
* Paper output: Figure 7 / workforce and practice-structure diagnostics, if included.
if ${RUN_PRACTICE_HETEROGENEITY} {

forval case = 1(1)5 { // Usar sÃ³lo si se quieren correr todos al tiempo

	*loc case=1 // Testing

	use "$dataDerived/QOFpracticePanel_ready.dta", clear
	
	/*
	collapse (mean) gp_HC (count) PHCs=prai  , by(year)
	tw (line gp_HC year)	(line PHCs year  ,yaxis(2) )
	*/
	
	keep prai pct_code year list gp_1000p
	xtset prai year

	tsfill , full
	replace list=0 if list==. & year>2004

	ge varilist = (list-L.list)/L.list
	ge dissap = varilist<-.5 if varilist!=.
	ge highgr = varilist>.5 if varilist!=.
	label var dissap "GP practice shrinked by 50% or more"
	label var highgr "GP practice grew by 50% or more"
	
	cap drop zero
	ge zero= list==0 if L.list>0 & L.list!=.

	
	* ) one in which they exclude PHCs in which there was a sudden increase in the pool of patients registered<<<<<

	bys pct_code: egen hayDisapp = max(dissap)
	bys pct_code: egen hayHighgr = max(highgr)
	label var hayDisapp "At least one GP in the PCT shrinked by 50% or more"
	label var hayHighgr "At least one GP in the PCT grew more than 50%"
	
	
	* Number of events per year
	tab dissap year
	tab zero year
	tab highgr year	

	* How many PCTs
	levelsof pct_code if year==2009
	return list
	/* How many practices per PCT
	collapse (count) gp_1000p (mean) hayDisapp hayHighgr  , by( pct_code year)
	bys year: sum gp_1000p hayDisapp hayHighgr
	
	*/
		
	
	xtile gp_1000pC =gp_1000p , n(2)
	label var gp_1000pC "GP size by gps per 1000 patients: 1(small) 2 (large)"
	
	
	keep if year==2011
	keep prai hayDisapp hayHighgr dissap highgr gp_1000pC
	tempfile pctGrow
	save `pctGrow'

use "$dataDerived/QOFpracticePanel_ready.dta", clear
	merge m:1 prai using `pctGrow' , nogen

	** Definition of the group
	if `case'==1 {
		gen I= listQ_09==3 | listQ_09==4
		
		glo Itit0 = "Small list" // "{it:I}=0"
		glo Itit1 = "Large list" // "{it:I}=1"
		glo Itit  = "listSize"
	}
	if `case'==2 {
		gen I= Size_SingleHandedHC==1 | Size_SmallMediumHC==1
		
		glo Itit0 = "1 to 3 GPs" // "{it:I}=0"
		glo Itit1 = "4 GPs or more" // "{it:I}=1"
		glo Itit  = "gps"
	}
	if `case'==3 {
		gen I= gp_1000pC==2
		
		glo Itit0 = "Not large by GPs pc" // "{it:I}=0"
		glo Itit1 = "Large by GPs pc" // "{it:I}=1"
		glo Itit  = "gppc"
	}	
	if `case'==4 {
		gen I= hayDisapp==1 if dissap!=1
			
		glo Itit0 = "No High Loss PCT" // "{it:I}=0"
		glo Itit1 = "High Loss PCT" // "{it:I}=1"
		glo Itit  = "HighLoss"
	}
	if `case'==5 {
		gen I= hayHighgr==1 if highgr!=1
			
		glo Itit0 = "No High Growth PCT" // "{it:I}=0"
		glo Itit1 = "High Growth PCT" // "{it:I}=1"
		glo Itit  = "HighGrowth"
	}

	*********************

	loc par_w "10  10"
	loc par_h " 2  3 "
	loc par_b " 1  1 "
	loc opts = wordcount("`par_w'")
	loc scond ="L3"
	
	/* For testing...
	glo thresholdsNA = "90   90"
	glo indicatorsNA = "AF03 THYROI02"
	*/	
	
	cap mat drop resultsS2
	cap mat drop resultsB
	
	local n : word count $indicatorsNA
	forval i=1(1)`n'  {	// 

		local varDep : word `i' of $indicatorsNA
		local uppt   : word `i' of $thresholdsNA
		
		disp in red "`varDep' with `uppt' "
	
		local lname : variable label `varDep'Achievement
		if "`lname'"=="" local lname ="`varDep'"
		local lname = subinstr("`lname'","_","",.)
		local lname = subinstr("`lname'","&"," and ",.)		

		**************************************************
		
		loc Acbcoef=0
		loc Acbpval=0
		
		disp "Step 1" // =====================================================
		
		forval j=1(1)`opts' {
			local w : word `j' of `par_w'
			local h : word `j' of `par_h'
			local b : word `j' of `par_b'
			
			disp "ok2 `j': `w' `h' `b'"
			
			forval ii=0(1)1 { // The two potential variables of the interaction var
				qui bunchingEst if I==`ii' & year>=2009 & year<=2010 & `varDep'Achievement>0 & `varDep'Achievement<100 & `varDep'Achievement!=. ///
					, whichone("`varDep'") ul(`uppt') nknots(5) h(`h') wind(`w') b(`b') nograph
						
			
				loc Acbcoef =max(`Acbcoef',${`varDep'_avg})
				loc Acbpval =max(`Acbpval',${`varDep'_bpval})
				disp "`Acbpval'"
				
				mat define miRow = [`ii',`i',`j',`w',`h',`b', ${`varDep'_avg} , ${`varDep'_bzstat} , ${`varDep'_bpval}, `Acbcoef' , `Acbpval' ]
				mat rowname miRow = "`varDep'"
				mat define resultsB = nullmat(resultsB) \ miRow			
			}
				
		}
		
		disp "Step 2" // =====================================================
		
					
			local varDep = "`varDep'Achievement"
			
			disp in red "`varDep' with `uppt' "
		qui {
		
			xtset prai year 
			cap drop Below*
			cap drop Be*
			cap drop inter*
			cap drop Ach*
			cap drop DAch*
			cap drop AfI
			cap drop AfNI
			
			gen Be=`varDep'<(`uppt'/100) if `varDep'!=.
			replace Be=. if `varDep'>((`uppt'+ ${superCond`scond'} )/100)  // [UL+`scond',100]
			replace Be=. if `varDep'<((`uppt'- 10 )/100)                   // [  0 ,UL-10]
			gen Below=L.Be
			
			replace Below=0 if year==2009 & Below==.
			
			gen inter=Below*Af
			
			label var Below "Below: Achiev<Th in t-1"
			label var inter "Below*After"

			gen Ach =  `varDep'
			gen DAch=D.`varDep' if year>=2010 // Variations from before might be induced by other changes of QOF
			
			* The interactions with a fixed characteristic
			gen interI=inter*I
			gen BelowI=Below*I
			gen AfI   =Af*I
			
			gen interNI=inter*(1-I)
			gen BelowNI=Below*(1-I)
			gen AfNI   =Af*(1-I)			
			
		}
		
			reg   DAch 	interI  BelowI  AfI ///
						interNI BelowNI AfNI I ///
						$controles if inrange(year,2010,2011), cluster(prai) // Main version
				estadd ysumm
				qui sum Be if year==2010 & e(sample)==1
				estadd scalar atmean10=r(mean)	
				qui sum `varDep' if year==2010 & e(sample)==1
				estadd scalar meanAch10=r(mean)
				qui sum Be if year==2011 & e(sample)==1
				estadd scalar atmean11=r(mean)
				qui tab prai if e(sample)==1
				estadd scalar enePra=r(r)			
				qui tab prai if e(sample)==1 & 	Below==1		
				estadd scalar eneBel=r(r)			
				qui tab prai if e(sample)==1 & 	Below==0
				estadd scalar eneAbv=r(r)			
				
				est store x2
	
			myCoeff2 4 1 interI
			myCoeff2 5 1 interNI
			
			count if e(sample)==1 & year==2010 & Below==1
			local eneBel = r(N)
			count if e(sample)==1 & year==2010 & Below==0
			local eneAbv = r(N)
				

		* Fill the matrix  ........................................
		disp "`uppt' , `eneBel' , `eneAbv' , $coef4 , $se4 , $pval4 , $coef5 , $se5 , $pval5 "
			
			mat define miRow = [`uppt' , `eneBel' , `eneAbv' , $coef4 , $se4 , $pval4 , $coef5 , $se5 , $pval5  ]

			
			mat rowname miRow = "`varDep'"
			mat define resultsS2 = nullmat(resultsS2) \ miRow					
		
		
	}
	mat colnames resultsB = I i j w h b avg bzstat bpval Acbcoef Acbpval
	mat list resultsB	

	
	mat colnames resultsS2 = uppt eneBel eneAbv coef4 se4 pval4 coef5 se5 pval5 
	mat list resultsS2	

	* Integrate into a unique dataset (run from here to avoid running regs again) ....
	clear
	svmat2 resultsB , names(I i j w h b avg bzstat bpval Acbcoef Acbpval 	) rnames(variable)		
	drop j
	reshape wide avg bzstat bpval Acbcoef Acbpval , i(I i w b variable) j(h)
	gen signif= Acbpval2<0.1 & Acbpval3<0.1
	
	keep signif I i w b variable
	reshape wide signif , i(i w b variable) j(I)
	
	tempfile FSt
	save  `FSt'
	clear
	svmat2 resultsS2 , names(uppt eneBel eneAbv coef4 se4 pval4 coef5 se5 pval5 ) rnames(variable)	
	replace variable = subinstr(variable, "Achievement", "", .)
	merge 1:1 variable using `FSt'
	
	keep variable signif* coef4 se4 pval4 coef5 se5 pval5
	
	* Forest plot ................................................................
	* Assumes your dataset already has:
	* coef4 se4 pval4 coef5 se5 pval5 variable signif



	****************************************************
	* 1. Clinical group, y positioning, labels (same logic as your code)
	****************************************************
	gen str group = regexr(variable, "[0-9]+", "")
	replace group = regexr(group, "Achievement", "")
	replace group = "OTHER" if missing(group)

	encode group, gen(groupid)
	label var group "Clinical group"

	preserve
		keep variable groupid
		bysort variable: keep if _n==1
		gen yi = _n
		tempfile ypos
		save `ypos', replace
	restore
	merge m:1 variable using `ypos', nogen

	* Build y (with spacing by groupid)
	qui sum groupid
	gen y = yi + groupid - r(min)
	replace y=y*2
	


	* 2. Holm-Sidak step-down adjustment ...........................
	
	gen p_holm_sidak_domain4 =.
	gen p_holm_sidak_domain5 =.
	
	tempfile filo
	levelsof groupid , local(grupos)
	foreach gp in `grupos' {		
		disp " gp `gp'"
		preserve
		
			drop p_holm_sidak_domain4 p_holm_sidak_domain5
			keep if groupid==`gp'
			
			reshape long pval , i(variable) j(whichcoe)
			
			* La variable pval tiene los p-values

			gen long id = _n

			* Ordenar por pval
			sort pval
			gen int i = _n
			count
			local m = r(N)

			* Holm-Sidak raw adjustment
			gen double p_hs_raw = 1 - (1 - pval)^(`m' - i + 1)

			* Monotonize the step-down adjusted p-values.
			gen double p_holm_sidak`gp' = p_hs_raw
			replace p_holm_sidak`gp' = p_holm_sidak`gp'[_n-1] if _n>1 & p_holm_sidak < p_holm_sidak[_n-1]
			replace p_holm_sidak`gp' = min(p_holm_sidak`gp', 1)

			* Return to the original order.
			sort id
			drop i p_hs_raw
			drop id
			
			keep  variable p_holm_sidak`gp' whichcoe
			reshape wide p_holm_sidak`gp' , i(variable) j(whichcoe)
			
			keep  variable p_holm_sidak`gp'4 p_holm_sidak`gp'5
			save `filo' , replace
		restore	
		merge 1:1 variable using `filo' , nogen
		replace p_holm_sidak_domain4 = p_holm_sidak`gp'4 if groupid==`gp' 
		replace p_holm_sidak_domain5 = p_holm_sidak`gp'5 if groupid==`gp' 
		drop p_holm_sidak`gp'4 p_holm_sidak`gp'5
	}

	tempfile results_pvals
	save `results_pvals'	
	
	
	
	
	
	
	* *************************************************************************
	* Now, the graphs
	* *************************************************************************	
	
	****************************************************
	* 0. Put results in percentage points
	****************************************************
	foreach v of varlist coef4 se4 coef5 se5 {
		replace `v' = `v'*100
	}
	
	
	
	* Labels: mark complement/substitute using coef4 (I=1) as reference
	gen complement4 = (p_holm_sidak_domain4<0.1 & coef4<0)
	gen substitute4 = (p_holm_sidak_domain4<0.1 & coef4>0)

	gen complement5 = (p_holm_sidak_domain5<0.1 & coef5<0)
	gen substitute5 = (p_holm_sidak_domain5<0.1 & coef5>0)	
	
	gen str laby = regexr(variable, "Achievement", "")

	cap label drop y
	labmask y, values(laby) lblname(y)

	qui sum y
	local lmax = r(max)
	forvalues v = 1/`lmax' {
		capture local lab : label (y) `v'
		if _rc | "`lab'"=="`v'"  {
			label define y `v' " ", modify
		}
	}

	****************************************************
	* 2. 90% CIs for coef4 (I=1) and coef5 (I=0)
	****************************************************
	gen ci4_lo = coef4 - 1.645*se4
	gen ci4_hi = coef4 + 1.645*se4
	gen ci5_lo = coef5 - 1.645*se5
	gen ci5_hi = coef5 + 1.645*se5

	****************************************************
	* 3. Two coefficients per line: y offsets
	****************************************************
	local dy = 0.3
	gen y_I1 = y + `dy'   // coef4, I=1 (slightly above)
	gen y_I0 = y - `dy'   // coef5, I=0 (slightly below)

	
	****************************************************
	* 4. Optional numeric labels (one per point)
	****************************************************
	gen xlab4 = ci4_hi + 0.3
	gen xlab5 = ci5_hi + 0.3
	gen str lbl4 = string(coef4, "%4.2f")
	gen str lbl5 = string(coef5, "%4.2f")

	****************************************************
	* 5. Forest plot with transparency when signif==0
	****************************************************

	
	* p-values labels
	format %4.3f p_holm_sidak_domain4 // Nice format for the graph
	cap drop xlmi4
	gen xlmi4 = 10	
	format %4.3f p_holm_sidak_domain5 // Nice format for the graph
	cap drop xlmi5
	gen xlmi5 = 15		
	
	* To ensure we know where it should start
	sum ci4_lo
	loc min1=r(min)
	sum ci5_lo
	loc min2=r(min)
	loc mini= min(`min1',`min2')
	
	qui levelsof y, local(yticks)
	twoway ///
		(scatter y coef4 , msymbol(Oh) msize(small) mcolor(none)) ///
		/* CI: I=1 (coef4)  */ ///
		(rcap ci4_lo ci4_hi y_I1 if signif1==1 & complement4 == 0, horizontal lcolor("204 102 0") ) ///
		(rcap ci4_lo ci4_hi y_I1 if signif1==1 & (complement4 == 1 | substitute4==1), horizontal lcolor("204 102 0")) ///
		(rcap ci4_lo ci4_hi y_I1 if signif1==0, horizontal lcolor(orange%20)) ///
		/* CI: I=0 (coef5) */ ///
		(rcap ci5_lo ci5_hi y_I0 if signif0==1 & complement5 == 0, horizontal lcolor(navy)) ///
		(rcap ci5_lo ci5_hi y_I0 if signif0==1 & (complement5 == 1 | substitute5==1), horizontal lcolor(navy)) ///
		(rcap ci5_lo ci5_hi y_I0 if signif0==0, horizontal lcolor(navy%20)) ///
		/* Points: I=1 (coef4) */ ///
		(scatter y_I1 coef4 if signif1==1 & complement4 == 0, msymbol(Oh)  msize(small) mcolor("204 102 0")) ///
		(scatter y_I1 coef4 if signif1==1 & complement4 == 1, msymbol(O)  msize(small) mcolor("204 102 0")) ///
		(scatter y_I1 coef4 if signif1==1 & substitute4 == 1, msymbol(square)  msize(small) mcolor("204 102 0")) ///
		(scatter y_I1 coef4 if signif1==0, msymbol(Oh)  mcolor(orange%20)  msize(small)) ///
		/* Points: I=0 (coef5) */ ///
		(scatter y_I0 coef5 if signif0==1 & complement5 == 0, msymbol(Oh) msize(small) mcolor(navy)) ///
		(scatter y_I0 coef5 if signif0==1 & complement5 == 1, msymbol(O) msize(small) mcolor(navy)) ///
		(scatter y_I0 coef5 if signif0==1 & substitute5 == 1, msymbol(square) msize(small) mcolor(navy)) ///
		(scatter y_I0 coef5 if signif0==0, msymbol(Oh) mcolor(navy%20)  msize(small)) ///
		///
		(scatter y xlmi4 if p_holm_sidak_domain4>0.1,  msymbol(none) mlabel(p_holm_sidak_domain4)  /// // p-val mLabel text not-signif
			mlabpos(0) mlabsize(vsmall) mlabcolor(gs12) ) /// 		
		(scatter y xlmi4 if p_holm_sidak_domain4<0.1,  msymbol(none) mlabel(p_holm_sidak_domain4) /// // p-val mLabel text signif
			mlabpos(0) mlabsize(vsmall) mlabcolor("204 102 0") ) /// 
		///
		(scatter y xlmi5 if p_holm_sidak_domain5>0.1,  msymbol(none) mlabel(p_holm_sidak_domain5) /// // p-val mLabel text not-signif
			mlabpos(0) mlabsize(vsmall) mlabcolor(gs12) ) /// 		
		(scatter y xlmi5 if p_holm_sidak_domain5<0.1,  msymbol(none) mlabel(p_holm_sidak_domain5) /// // p-val mLabel text signif
			mlabpos(0) mlabsize(vsmall) mlabcolor(navy) ) /// 			
		, ///
		text(0   `mini' "Atrial Fibrillation", 	size(small) placement(e) justification(left) color(gs8) ) ///
		text(6   `mini' "Asthma", 					size(small) placement(e) justification(left) color(gs8) ) ///
		text(14  `mini' "Blood Pressure",			size(small) placement(e) justification(left) color(gs8) ) ///
		text(18  `mini' "Cancer", 					size(small) placement(e) justification(left) color(gs8) ) ///
		text(22  `mini' "Coronary Heart Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
		text(32  `mini' "Chronic Kidney Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
		text(42  `mini' "Chronic Obstructive Pulmonary Disease", size(small) placement(e) justification(left) color(gs8) ) ///
		text(50  `mini' "Cardiovascular Disease",  size(small) placement(e) justification(left) color(gs8) ) ///
		text(54  `mini' "Dementia", 				size(small) placement(e) justification(left) color(gs8) ) ///
		text(58  `mini' "Diabetes Mellitus", 		size(small) placement(e) justification(left) color(gs8) ) ///
		text(76  `mini' "Epilepsy", 				size(small) placement(e) justification(left) color(gs8) ) ///
		text(82  `mini' "Heart Failure", 			size(small) placement(e) justification(left) color(gs8) ) ///
		text(90  `mini' "Smoking", 				size(small) placement(e) justification(left) color(gs8) ) ///
		text(96  `mini' "Stroke and Transient Ischaemic Attack", size(small) placement(e) justification(left) color(gs8) ) ///
		text(108 `mini' "Thyroid Disorders", 		size(small) placement(e) justification(left) color(gs8) ) ///
		///
		text(-1.5   8.8 "MHT p-val", size(small) placement(e) justification(left) color(gs8) ) ///
		text(-0.2   1 "${Itit1}" , size(tiny) placement(e) justification(left) color(gs8) ) ///
		text(-0.2  12.8 "${Itit0}" , size(tiny) placement(e) justification(left) color(gs8) ) ///
		///
		yscale(reverse) ///
		ylabel(`yticks', valuelabel angle(horizontal) labsize(vvsmall)) ///
		xline(0, lpattern(dash) lcolor(gs10)) ///
		xtitle("Variation on achievement (pp.)") ///
		ytitle("") ///
		legend(size(small) colgap(10) ///
				order(	8  "${Itit1} (Non conclusive)" 12 "${Itit0} (Non conclusive)" ///
						9  "${Itit1} (Complement)"     13 "${Itit0} (Complement)"     ///
						10 "${Itit1} (Substitutes)"    14 "${Itit0} (Substitutes)"     ///
						11 "${Itit1} (No bunching)"    15 "${Itit0} (No bunching)" ///
						) pos(6) cols(2) region(lstyle(none) margin(l=-10) )) ///
		xsize(3) ysize(6)

	graph export "$imageFold/step2_summaryby_${Itit}.pdf", as(pdf) replace


}
	
}	


// SUR robustness block. Run after the main second-step block if required.
// Paper output: robustness appendix, if included in the manuscript.
if ${RUN_SUR_ROBUSTNESS} { 

	
forval case = 4(1)5 { // Usar sÃ³lo si se quieren correr todos al tiempo
	
		use "$dataDerived/QOFpracticePanel_ready.dta", clear
	keep prai pct_code year list gp_1000p
	xtset prai year

	tsfill , full
	replace list=0 if list==. & year>2004

	ge varilist = (list-L.list)/L.list
	ge dissap = varilist<-.5 if varilist!=.
	ge highgr = varilist>.5 if varilist!=.
	label var dissap "GP practice shrinked by 50% or more"
	label var highgr "GP practice grew by 50% or more"
	
	cap drop zero
	ge zero= list==0 if L.list>0 & L.list!=.

	
	* ) one in which they exclude PHCs in which there was a sudden increase in the pool of patients registered<<<<<

	bys pct_code: egen hayDisapp = max(dissap)
	bys pct_code: egen hayHighgr = max(highgr)
	label var hayDisapp "At least one GP in the PCT shrinked by 50% or more"
	label var hayHighgr "At least one GP in the PCT grew more than 50%"
	
	
	* Number of events per year
	tab dissap year
	tab zero year
	tab highgr year	

	* How many PCTs
	levelsof pct_code if year==2009
	return list
	/* How many practices per PCT
	collapse (count) gp_1000p (mean) hayDisapp hayHighgr  , by( pct_code year)
	bys year: sum gp_1000p hayDisapp hayHighgr
	
	*/
		
	
	xtile gp_1000pC =gp_1000p , n(2)
	label var gp_1000pC "GP size by gps per 1000 patients: 1(small) 2 (large)"
	
	
	keep if year==2011
	keep prai hayDisapp hayHighgr dissap highgr gp_1000pC
	tempfile pctGrow
	save `pctGrow'

use "$dataDerived/QOFpracticePanel_ready.dta", clear
	merge m:1 prai using `pctGrow' , nogen

	

	** Definition of the group
	if `case'==1 {
		gen I= listQ_09==3 | listQ_09==4
		
		glo NotI = "Small list" // "{it:I}=0"
		glo Intera = "Interaction" // "{it:I}=1"
		glo Itit  = "listSize"
	}
	if `case'==2 {
		gen I= Size_SingleHandedHC==1 | Size_SmallMediumHC==1
		
		glo NotI = "1 to 3 GPs" // "{it:I}=0"
		glo Intera = "Interaction" // "{it:I}=1"
		glo Itit  = "gps"
	}
	if `case'==3 {
		gen I= gp_1000pC==2
		
		glo NotI = "Not large by GPs pc" // "{it:I}=0"
		glo Intera = "Interaction" // "{it:I}=1"
		glo Itit  = "gppc"
	}	
	if `case'==4 {
		gen I= hayDisapp==1 if dissap!=1
			
		glo NotI = "No High Loss PCT" // "{it:I}=0"
		glo Intera = "Interaction" // "{it:I}=1"
		glo Itit  = "HighLoss"
	}
	if `case'==5 {
		gen I= hayHighgr==1 if highgr!=1
			
		glo NotI = "No High Growth PCT" // "{it:I}=0"
		glo Intera = "Interaction" // "{it:I}=1"
		glo Itit  = "HighGrowth"
	}

	*********************

	loc par_w "10  10"
	loc par_h " 2  3 "
	loc par_b " 1  1 "
	loc opts = wordcount("`par_w'")
	loc scond ="L3"
	
	/* For testing...
	glo thresholdsNA = "90   90"
	glo indicatorsNA = "AF03 THYROI02"
	*/	
	
	cap mat drop resultsS2
	cap mat drop resultsB
	
	local n : word count $indicatorsNA
	forval i=1(1)`n'  {	// 

		local varDep : word `i' of $indicatorsNA
		local uppt   : word `i' of $thresholdsNA
		
		disp in red "`varDep' with `uppt' "
	
		local lname : variable label `varDep'Achievement
		if "`lname'"=="" local lname ="`varDep'"
		local lname = subinstr("`lname'","_","",.)
		local lname = subinstr("`lname'","&"," and ",.)		

		**************************************************
		
		loc Acbcoef=0
		loc Acbpval=0
		
		disp "Step 1" // =====================================================
		
		forval j=1(1)`opts' {
			local w : word `j' of `par_w'
			local h : word `j' of `par_h'
			local b : word `j' of `par_b'
			
			disp "ok2 `j': `w' `h' `b'"
			
			forval ii=0(1)1 { // The two potential variables of the interaction var
				qui bunchingEst if I==`ii' & year>=2009 & year<=2010 & `varDep'Achievement>0 & `varDep'Achievement<100 & `varDep'Achievement!=. ///
					, whichone("`varDep'") ul(`uppt') nknots(5) h(`h') wind(`w') b(`b') nograph
						
			
				loc Acbcoef =max(`Acbcoef',${`varDep'_avg})
				loc Acbpval =max(`Acbpval',${`varDep'_bpval})
				disp "`Acbpval'"
				
				mat define miRow = [`ii',`i',`j',`w',`h',`b', ${`varDep'_avg} , ${`varDep'_bzstat} , ${`varDep'_bpval}, `Acbcoef' , `Acbpval' ]
				mat rowname miRow = "`varDep'"
				mat define resultsB = nullmat(resultsB) \ miRow			
			}
				
		}
		
		disp "Step 2" // =====================================================
		
					
			local varDep = "`varDep'Achievement"
			
			disp in red "`varDep' with `uppt' "
		qui {
		
			xtset prai year 
			cap drop Below*
			cap drop Be*
			cap drop inter*
			cap drop Ach*
			cap drop DAch*
			cap drop AfI
			cap drop AfNI
			
			gen Be=`varDep'<(`uppt'/100) if `varDep'!=.
			replace Be=. if `varDep'>((`uppt'+ ${superCond`scond'} )/100)  // [UL+`scond',100]
			replace Be=. if `varDep'<((`uppt'- 10 )/100)                   // [  0 ,UL-10]
			gen Below=L.Be
			
			replace Below=0 if year==2009 & Below==.
			
			gen inter=Below*Af
			
			label var Below "Below: Achiev<Th in t-1"
			label var inter "Below*After"

			gen Ach =  `varDep'
			gen DAch=D.`varDep' if year>=2010 // Variations from before might be induced by other changes of QOF
			
			* The interactions with a fixed characteristic
			gen interI=inter*I
			gen BelowI=Below*I
			gen AfI   =Af*I
			
			gen interNI=inter*(1-I)
			gen BelowNI=Below*(1-I)
			gen AfNI   =Af*(1-I)			
			
		}
		
			reg   DAch 	interI  BelowI  AfI ///
						inter Below Af I ///
						$controles if inrange(year,2010,2011), cluster(prai) // Main version
				estadd ysumm
				qui sum Be if year==2010 & e(sample)==1
				estadd scalar atmean10=r(mean)	
				qui sum `varDep' if year==2010 & e(sample)==1
				estadd scalar meanAch10=r(mean)
				qui sum Be if year==2011 & e(sample)==1
				estadd scalar atmean11=r(mean)
				qui tab prai if e(sample)==1
				estadd scalar enePra=r(r)			
				qui tab prai if e(sample)==1 & 	Below==1		
				estadd scalar eneBel=r(r)			
				qui tab prai if e(sample)==1 & 	Below==0
				estadd scalar eneAbv=r(r)			
				
				est store x2
	
			myCoeff2 4 1 inter
			myCoeff2 5 1 interI
			
			count if e(sample)==1 & year==2010 & Below==1
			local eneBel = r(N)
			count if e(sample)==1 & year==2010 & Below==0
			local eneAbv = r(N)
				

		* Fill the matrix  ........................................
		disp "`uppt' , `eneBel' , `eneAbv' , $coef4 , $se4 , $pval4 , $coef5 , $se5 , $pval5 "
		
		mat define miRow = [`uppt' , `eneBel' , `eneAbv' , $coef4 , $se4 , $pval4 , $coef5 , $se5 , $pval5  ]

			
			mat rowname miRow = "`varDep'"
			mat define resultsS2 = nullmat(resultsS2) \ miRow					
		
		
	}
	mat colnames resultsB = I i j w h b avg bzstat bpval Acbcoef Acbpval
	mat list resultsB	

	
	mat colnames resultsS2 = uppt eneBel eneAbv coef4 se4 pval4 coef5 se5 pval5 
	mat list resultsS2	

	* Integrate into a unique dataset (run from here to avoid running regs again) ....
	clear
	svmat2 resultsB , names(I i j w h b avg bzstat bpval Acbcoef Acbpval 	) rnames(variable)		
	drop j
	reshape wide avg bzstat bpval Acbcoef Acbpval , i(I i w b variable) j(h)
	gen signif= Acbpval2<0.1 & Acbpval3<0.1
	
	keep signif I i w b variable
	reshape wide signif , i(i w b variable) j(I)
	
	tempfile FSt
	save  `FSt'
	clear
	svmat2 resultsS2 , names(uppt eneBel eneAbv coef4 se4 pval4 coef5 se5 pval5 ) rnames(variable)	
	replace variable = subinstr(variable, "Achievement", "", .)
	merge 1:1 variable using `FSt'
	
	keep variable signif* coef4 se4 pval4 coef5 se5 pval5
	
	* Forest plot ................................................................
	* Assumes your dataset already has:
	* coef4 se4 pval4 coef5 se5 pval5 variable signif



	****************************************************
	* 1. Clinical group, y positioning, labels (same logic as your code)
	****************************************************
	gen str group = regexr(variable, "[0-9]+", "")
	replace group = regexr(group, "Achievement", "")
	replace group = "OTHER" if missing(group)

	encode group, gen(groupid)
	label var group "Clinical group"

	preserve
		keep variable groupid
		bysort variable: keep if _n==1
		gen yi = _n
		tempfile ypos
		save `ypos', replace
	restore
	merge m:1 variable using `ypos', nogen

	* Build y (with spacing by groupid)
	qui sum groupid
	gen y = yi + groupid - r(min)
	replace y=y*2
	


	* 2. Holm-Sidak step-down adjustment ...........................
	
	gen p_holm_sidak_domain4 =.
	gen p_holm_sidak_domain5 =.
	
	tempfile filo
	levelsof groupid , local(grupos)
	foreach gp in `grupos' {		
		disp " gp `gp'"
		preserve
		
			drop p_holm_sidak_domain4 p_holm_sidak_domain5
			keep if groupid==`gp'
			
			reshape long pval , i(variable) j(whichcoe)
			
			* La variable pval tiene los p-values

			gen long id = _n

			* Ordenar por pval
			sort pval
			gen int i = _n
			count
			local m = r(N)

			* Holm-Sidak raw adjustment
			gen double p_hs_raw = 1 - (1 - pval)^(`m' - i + 1)

			* Monotonize the step-down adjusted p-values.
			gen double p_holm_sidak`gp' = p_hs_raw
			replace p_holm_sidak`gp' = p_holm_sidak`gp'[_n-1] if _n>1 & p_holm_sidak < p_holm_sidak[_n-1]
			replace p_holm_sidak`gp' = min(p_holm_sidak`gp', 1)

			* Return to the original order.
			sort id
			drop i p_hs_raw
			drop id
			
			keep  variable p_holm_sidak`gp' whichcoe
			reshape wide p_holm_sidak`gp' , i(variable) j(whichcoe)
			
			keep  variable p_holm_sidak`gp'4 p_holm_sidak`gp'5
			save `filo' , replace
		restore	
		merge 1:1 variable using `filo' , nogen
		replace p_holm_sidak_domain4 = p_holm_sidak`gp'4 if groupid==`gp' 
		replace p_holm_sidak_domain5 = p_holm_sidak`gp'5 if groupid==`gp' 
		drop p_holm_sidak`gp'4 p_holm_sidak`gp'5
	}

	tempfile results_pvals
	save `results_pvals'	
	
	
	
	
	
	
	* *************************************************************************
	* Now, the graphs
	* *************************************************************************	
	
	****************************************************
	* 0. Put results in percentage points
	****************************************************
	foreach v of varlist coef4 se4 coef5 se5 {
		replace `v' = `v'*100
	}
	
	
	
	* Labels: mark complement/substitute using coef4 (term withot the I interaction) as reference
	gen complement4 = (p_holm_sidak_domain4<0.1 & coef4<0)
	gen substitute4 = (p_holm_sidak_domain4<0.1 & coef4>0)

	gen complement5 = (p_holm_sidak_domain5<0.1 & coef5<0)
	gen substitute5 = (p_holm_sidak_domain5<0.1 & coef5>0)	
	
	gen str laby = regexr(variable, "Achievement", "")

	cap label drop y
	labmask y, values(laby) lblname(y)

	qui sum y
	local lmax = r(max)
	forvalues v = 1/`lmax' {
		capture local lab : label (y) `v'
		if _rc | "`lab'"=="`v'"  {
			label define y `v' " ", modify
		}
	}

	****************************************************
	* 2. 90% CIs for coef4 (I=1) and coef5 (I=0)
	****************************************************
	gen ci4_lo = coef4 - 1.645*se4
	gen ci4_hi = coef4 + 1.645*se4
	gen ci5_lo = coef5 - 1.645*se5
	gen ci5_hi = coef5 + 1.645*se5

	****************************************************
	* 3. Two coefficients per line: y offsets
	****************************************************
	local dy = 0.3
	gen y_I1 = y + `dy'   // coef4, I=1 (slightly above)
	gen y_I0 = y - `dy'   // coef5, I=0 (slightly below)

	
	****************************************************
	* 4. Optional numeric labels (one per point)
	****************************************************
	gen xlab4 = ci4_hi + 0.3
	gen xlab5 = ci5_hi + 0.3
	gen str lbl4 = string(coef4, "%4.2f")
	gen str lbl5 = string(coef5, "%4.2f")

	****************************************************
	* 5. Forest plot with transparency when signif==0
	****************************************************

	
	* p-values labels
	format %4.3f p_holm_sidak_domain4 // Nice format for the graph
	cap drop xlmi4
	gen xlmi4 = 10	
	format %4.3f p_holm_sidak_domain5 // Nice format for the graph
	cap drop xlmi5
	gen xlmi5 = 15		
	
	* To ensure we know where it should start
	sum ci4_lo
	loc min1=r(min)
	sum ci5_lo
	loc min2=r(min)
	loc mini= min(`min1',`min2')
	
	qui levelsof y, local(yticks)
	twoway ///
		(scatter y coef4 , msymbol(Oh) msize(small) mcolor(none)) ///
		/* CI: I=1 (coef4)  */ ///
		(rcap ci4_lo ci4_hi y_I1 if signif1==1 & complement4 == 0, horizontal lcolor("204 102 0") ) ///
		(rcap ci4_lo ci4_hi y_I1 if signif1==1 & (complement4 == 1 | substitute4==1), horizontal lcolor("204 102 0")) ///
		(rcap ci4_lo ci4_hi y_I1 if signif1==0, horizontal lcolor(orange%20)) ///
		/* CI: I=0 (coef5) */ ///
		(rcap ci5_lo ci5_hi y_I0 if signif0==1 & complement5 == 0, horizontal lcolor(navy)) ///
		(rcap ci5_lo ci5_hi y_I0 if signif0==1 & (complement5 == 1 | substitute5==1), horizontal lcolor(navy)) ///
		(rcap ci5_lo ci5_hi y_I0 if signif0==0, horizontal lcolor(navy%20)) ///
		/* Points: I=1 (coef4) */ ///
		(scatter y_I1 coef4 if signif1==1 & complement4 == 0, msymbol(Oh)  msize(small) mcolor("204 102 0")) ///
		(scatter y_I1 coef4 if signif1==1 & complement4 == 1, msymbol(O)  msize(small) mcolor("204 102 0")) ///
		(scatter y_I1 coef4 if signif1==1 & substitute4 == 1, msymbol(square)  msize(small) mcolor("204 102 0")) ///
		(scatter y_I1 coef4 if signif1==0, msymbol(Oh)  mcolor(orange%20)  msize(small)) ///
		/* Points: I=0 (coef5) */ ///
		(scatter y_I0 coef5 if signif0==1 & complement5 == 0, msymbol(Oh) msize(small) mcolor(navy)) ///
		(scatter y_I0 coef5 if signif0==1 & complement5 == 1, msymbol(O) msize(small) mcolor(navy)) ///
		(scatter y_I0 coef5 if signif0==1 & substitute5 == 1, msymbol(square) msize(small) mcolor(navy)) ///
		(scatter y_I0 coef5 if signif0==0, msymbol(Oh) mcolor(navy%20)  msize(small)) ///
		///
		(scatter y xlmi4 if p_holm_sidak_domain4>0.1,  msymbol(none) mlabel(p_holm_sidak_domain4)  /// // p-val mLabel text not-signif
			mlabpos(0) mlabsize(vsmall) mlabcolor(gs12) ) /// 		
		(scatter y xlmi4 if p_holm_sidak_domain4<0.1,  msymbol(none) mlabel(p_holm_sidak_domain4) /// // p-val mLabel text signif
			mlabpos(0) mlabsize(vsmall) mlabcolor("204 102 0") ) /// 
		///
		(scatter y xlmi5 if p_holm_sidak_domain5>0.1,  msymbol(none) mlabel(p_holm_sidak_domain5) /// // p-val mLabel text not-signif
			mlabpos(0) mlabsize(vsmall) mlabcolor(gs12) ) /// 		
		(scatter y xlmi5 if p_holm_sidak_domain5<0.1,  msymbol(none) mlabel(p_holm_sidak_domain5) /// // p-val mLabel text signif
			mlabpos(0) mlabsize(vsmall) mlabcolor(navy) ) /// 			
		, ///
		text(0   `mini' "Atrial Fibrillation", 	size(small) placement(e) justification(left) color(gs8) ) ///
		text(6   `mini' "Asthma", 					size(small) placement(e) justification(left) color(gs8) ) ///
		text(14  `mini' "Blood Pressure",			size(small) placement(e) justification(left) color(gs8) ) ///
		text(18  `mini' "Cancer", 					size(small) placement(e) justification(left) color(gs8) ) ///
		text(22  `mini' "Coronary Heart Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
		text(32  `mini' "Chronic Kidney Disease", 	size(small) placement(e) justification(left) color(gs8) ) ///
		text(42  `mini' "Chronic Obstructive Pulmonary Disease", size(small) placement(e) justification(left) color(gs8) ) ///
		text(50  `mini' "Cardiovascular Disease",  size(small) placement(e) justification(left) color(gs8) ) ///
		text(54  `mini' "Dementia", 				size(small) placement(e) justification(left) color(gs8) ) ///
		text(58  `mini' "Diabetes Mellitus", 		size(small) placement(e) justification(left) color(gs8) ) ///
		text(76  `mini' "Epilepsy", 				size(small) placement(e) justification(left) color(gs8) ) ///
		text(82  `mini' "Heart Failure", 			size(small) placement(e) justification(left) color(gs8) ) ///
		text(90  `mini' "Smoking", 				size(small) placement(e) justification(left) color(gs8) ) ///
		text(96  `mini' "Stroke and Transient Ischaemic Attack", size(small) placement(e) justification(left) color(gs8) ) ///
		text(108 `mini' "Thyroid Disorders", 		size(small) placement(e) justification(left) color(gs8) ) ///
		///
		text(-1.5   8.8 "MHT p-val", size(small) placement(e) justification(left) color(gs8) ) ///
		text(-0.2   1 "${NotI}" , size(tiny) placement(e) justification(left) color(gs8) ) ///
		text(-0.2  12.8 "${Intera}" , size(tiny) placement(e) justification(left) color(gs8) ) ///
		///
		yscale(reverse) ///
		ylabel(`yticks', valuelabel angle(horizontal) labsize(vvsmall)) ///
		xline(0, lpattern(dash) lcolor(gs10)) ///
		xtitle("Variation on achievement (pp.)") ///
		ytitle("") ///
		legend(size(small) colgap(10) ///
				order(	8  "${NotI} (Non conclusive)" 12 "${Intera} (Non significant)" ///
						9  "${NotI} (Complement)"     13 "${Intera} (positive)"     ///
						10 "${NotI} (Substitutes)"    14 "${Intera} (negative)"     ///
						11 "${NotI} (No bunching)"    15 "${Intera} (No bunching)" ///
						) pos(6) cols(2) region(lstyle(none) margin(l=-10) )) ///
		xsize(3) ysize(6) name(case`case', replace)
	
}


}	


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
**# 5. Results-density figures
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Paper output: results-density figures in appendix.
// Output: output/figures/ResultsDensities*.pdf.
if ${RUN_RESULTS_DENSITIES} {
	
	use "$dataDerived/QOFpracticePanel_ready.dta", clear
	* Version 1 ...................................................................
	local n : word count AF03 AF04 CKD03 CKD06
	forval i=1(1)`n'  {	// 

		local varDepo : word `i' of AF03 AF04 CKD03 CKD06
		local uppt   : word `i'  of   90   90    70    80
		
		loca scond = "L3"
		*loca varDepo = "AF03"
		*local uppt   = 90	
		
		local varDep = "`varDepo'Achievement"
		
		disp in red "`varDep' with `uppt' "


		local lname : variable label `varDep'
		if "`lname'"=="" local lname ="`varDep'"
		local lname = subinstr("`lname'","_","",.)
		local lname = subinstr("`lname'","&"," and ",.)		

		xtset prai year 
		cap drop Below
		cap drop Be
		cap drop inter
		cap drop DAch
		
		gen Be=`varDep'<(`uppt'/100) if `varDep'!=.
		replace Be=. if `varDep'>((`uppt'+ ${superCond`scond'} )/100)  // [UL+`scond',100]
		replace Be=. if `varDep'<((`uppt'- 10 )/100)                   // [  0 ,UL-10]
		gen Below=L.Be
		gen inter=Below*Af
		
		label var Below "Below: Achiev<Th in t-1"
		label var inter "Below*After"

		gen DAch=D.`varDep' if year>=2010 // Variations from before might be induced by other changes of QOF

		tw 	(kdensity DAch if year==2010 & Be==0 , lcolor(midgreen) lwidth(medthin) lpattern(dash) ) ///
			(kdensity DAch if year==2010 & Be==1 , lcolor(black)    lwidth(medthin) lpattern(dash)  ) ///
			(kdensity DAch if year==2011 & Be==0 , lcolor(midgreen) lwidth(medthin) lpattern(solid) ) ///
			(kdensity DAch if year==2011 & Be==1 , lcolor(black)    lwidth(medthin) lpattern(solid) ) ///
			if DAch>-0.2 & DAch<0.2, legend( order( 1 "2010 Below" 2 "2010 Above" 3  "2011 Below" 4 "2011 Above"  ) cols(2) ) ///
			ytitle("`lname'") name(a`varDepo', replace )
							
		disp in red "`varDepo', with upper Th=`uppt'"
	 
	}

	grc1leg aAF03 aAF04 aCKD03 aCKD06 , ycommon xcommon
	graph export "$imageFold/ResultsDensities.pdf", as(pdf) replace

	* Version 2 ...................................................................

	local n : word count AF03 AF04 CKD03 CKD06
	forval i=1(1)`n'  {	// 

		local varDepo : word `i' of AF03 AF04 CKD03 CKD06
		local uppt   : word `i'  of   90   90    70    80
		
		loca scond = "L3"
		*loca varDepo = "AF03"
		*local uppt   = 90	
		
		local varDep = "`varDepo'Achievement"
		
		disp in red "`varDep' with `uppt' "


		local lname : variable label `varDep'
		if "`lname'"=="" local lname ="`varDep'"
		local lname = subinstr("`lname'","_","",.)
		local lname = subinstr("`lname'","&"," and ",.)		

		xtset prai year 
		cap drop Below
		cap drop Be
		cap drop inter
		cap drop DAch
		
		cap drop DAch10 DAch11 DAch10x DAch11x diffo
		
		gen Be=`varDep'<(`uppt'/100) if `varDep'!=.
		replace Be=. if `varDep'>((`uppt'+ ${superCond`scond'} )/100)  // [UL+`scond',100]
		replace Be=. if `varDep'<((`uppt'- 10 )/100)                   // [  0 ,UL-10]
		gen Below=L.Be
		gen inter=Below*Af
		
		label var Below "Below: Achiev<Th in t-1"
		label var inter "Below*After"

		gen DAch=D.`varDep' if year>=2010 // Variations from before might be induced by other changes of QOF
		
		gen DAch11 = DAch if year==2011
		gen DAch10 = DAch if year==2010
		bys prai: egen DAch11x=max(DAch11)
		bys prai: egen DAch10x=max(DAch10)
		gen diffo=DAch11x-DAch10x
		
		

		tw 	(kdensity diffo if year==2010 & Be==0 , lcolor(midgreen) lwidth(medthin) lpattern(dash) ) ///
			(kdensity diffo if year==2010 & Be==1 , lcolor(black)    lwidth(medthin) lpattern(solid)   ) ///
			if diffo>-0.3 & diffo<0.3, legend( order( 1 "Below" 2 "Above"  ) cols(2) ) ///
			ytitle("`varDepo'") name(a`varDepo', replace )
							
		disp in red "`varDepo', with upper Th=`uppt'"
	 
	}

	grc1leg aAF03 aAF04 aCKD03 aCKD06 , ycommon xcommon
	graph export "$imageFold/ResultsDensities2.pdf", as(pdf) replace

	* As comparison with indicators were no impact is observed.....................
	local n : word count CHD09 CHD10 DM21 EPILEP08
	forval i=1(1)`n'  {	// 

		local varDepo : word `i' of CHD09 CHD10 DM21 EPILEP08
		local uppt   : word `i'  of   90   60    90    70
		
		loca scond = "L3"
		*loca varDepo = "CHD09"
		*local uppt   = 90	
		
		local varDep = "`varDepo'Achievement"
		
		disp in red "`varDep' with `uppt' "


		local lname : variable label `varDep'
		if "`lname'"=="" local lname ="`varDep'"
		local lname = subinstr("`lname'","_","",.)
		local lname = subinstr("`lname'","&"," and ",.)		

		xtset prai year 
		cap drop Below
		cap drop Be
		cap drop inter
		cap drop DAch
		
		cap drop DAch10 DAch11 DAch10x DAch11x diffo
		
		gen Be=`varDep'<(`uppt'/100) if `varDep'!=.
		replace Be=. if `varDep'>((`uppt'+ ${superCond`scond'} )/100)  // [UL+`scond',100]
		replace Be=. if `varDep'<((`uppt'- 10 )/100)                   // [  0 ,UL-10]
		gen Below=L.Be
		gen inter=Below*Af
		
		label var Below "Below: Achiev<Th in t-1"
		label var inter "Below*After"

		gen DAch=D.`varDep' if year>=2010 // Variations from before might be induced by other changes of QOF
		
		gen DAch11 = DAch if year==2011
		gen DAch10 = DAch if year==2010
		bys prai: egen DAch11x=max(DAch11)
		bys prai: egen DAch10x=max(DAch10)
		gen diffo=DAch11x-DAch10x
		
		

		tw 	(kdensity diffo if year==2010 & Be==0 , lcolor(midgreen) lwidth(medthin) lpattern(dash) ) ///
			(kdensity diffo if year==2010 & Be==1 , lcolor(black)    lwidth(medthin) lpattern(solid)   ) ///
			if diffo>-0.3 & diffo<0.3, legend( order( 1 "Below" 2 "Above"  ) cols(2) ) ///
			ytitle("`varDepo'") name(a`varDepo', replace )
							
		disp in red "`varDepo', with upper Th=`uppt'"
	 
	}

	grc1leg aCHD09 aCHD10 aDM21 aEPILEP08 , ycommon xcommon
	graph export "$imageFold/ResultsDensities2NoImpact.pdf", as(pdf) replace


}

cap log close

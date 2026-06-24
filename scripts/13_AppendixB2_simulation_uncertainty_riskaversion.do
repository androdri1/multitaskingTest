/* ***************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 13_optional_simulation_validation_g1.do
Language: Stata
Purpose: Analyse simulated data from the theoretical model and plot how the first-step
         bunching estimator and second-step DiD estimator behave as the shock variance changes.

Paper item: candidate source for Appendix Figure G1 / simulation-validation figure.
            This script is not part of the main empirical pipeline.

Main input:
  - data/derived/simulation_csvs/ *.csv
    These files are expected to contain the simulation grid used by the original
    MT02_simulationExercise.do file: t, sigma, delta, eta, prai, and simulated
    achievement variables such as x1simu1s and x1simu1c.

Main outputs:
  - data/derived/simulation_validation_all.dta
  - data/derived/simulation_validation_regs.dta
  - output/figures/appendix_figure_g1_step1.png
  - output/figures/appendix_figure_g1_step2.png

Run order: optional, after the simulation CSV grid has been placed in
           data/derived/simulation_csvs/.
*************************************************************************************** */

cap log close
macro drop _all
clear all
set more off
set matsize 2000

* -----------------------------------------------------------------------------
* Portable replication paths
* Root is defined from the location of this do-file, not from the current
* working directory. For scripts in scripts/, root = script_dir/.. . For scripts
* in scripts/qof_domain_builders/, root = script_dir/../.. .
* -----------------------------------------------------------------------------
local __this_file `"`c(filename)'"'
local __this_file = subinstr(`"`__this_file'"', char(92), "/", .)

if `"`__this_file'"' == "" {
    di as error "Cannot determine the running do-file. Run this file with Stata's do command."
    exit 601
}

local __slash = strrpos(`"`__this_file'"', "/")
if `__slash' > 0 {
    local __script_dir = substr(`"`__this_file'"', 1, `__slash' - 1)
}
else {
    local __script_dir "`c(pwd)'"
}

* If the script was called with a relative path, anchor it at the current pwd.
if substr(`"`__script_dir'"', 1, 1) != "/" & substr(`"`__script_dir'"', 2, 1) != ":" {
    local __script_dir "`c(pwd)'/`__script_dir'"
}
local __script_dir = subinstr(`"`__script_dir'"', char(92), "/", .)

if strpos(`"`__script_dir'"', "/qof_domain_builders") > 0 {
    local __root_candidate "`__script_dir'/../.."
}
else {
    local __root_candidate "`__script_dir'/.."
}

quietly cd "`__root_candidate'"
global mainDir     = subinstr(`"`c(pwd)'"', char(92), "/", .)
global root        "$mainDir"
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



cap mkdir "$dataDerived"
cap mkdir "$dataDerived/simulation_csvs"
cap mkdir "$tableFold"
cap mkdir "$imageFold"
cap mkdir "$logsFold"

log using "$logsFold/13_optional_simulation_validation_g1.log", replace text

do "$scripts/00_programs_and_globals.do"

global RUN_STOP_AFTER_G1 1

glo pra_controls="cont_PMS cont_other yrsexpIndi gp_1000p ONS_ruralD_*"
glo genOpts=`"  graphregion(color(white) lwidth(medium)) scheme(lean2) "'

////////////////////////////////////////////////////////////////////////////////  
if 1==1 { // Define programs needed for this file
	* ******************************************************************************
	* This program estimates the excess bunching at a given distribution
	* 1st. McCrary density discontinuity test
	* 2nd. Saez, Kleven style ....
	* ******************************************************************************
	* Use it like this: bunchingEst	, whichone("BP5") ul(70) nknots($nknots) h(2) wind($window) bw(0) b(1) doGraph(1)
	cap program drop bunchingEst
	program define bunchingEst , rclass
	syntax  [if] [in] , whichone(string) ul(real) nknots(integer) h(real) wind(real) [bw(real 0) b(real 1) graph(string)]

		noisily disp "Running: `whichone', h=`h', knots=`nknots', windows=`wind'"
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
			 *rddensity indi100, c(`ul') 
			
			
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
			// Remember to adjust for the bin size!
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
			if ("`graph'"!="no") {			
				
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

}
////////////////////////////////////////////////////////////////////////////////   
// Load all simulations from Julia
if 1==1 {
	local files : dir "$dataDerived/simulation_csvs" files "*.csv"

	clear
	set obs 1
	gen aaa=.
	tempfile filo
	save `filo'

	foreach file in `files' {
		disp "`file'"
		qui import delimited "$dataDerived/simulation_csvs/`file'", clear
		qui append using `filo'
		qui save `filo', replace
	}

	drop aaa
	drop if t==.
	*egen case=group( sigma delta) // eta	
	sort sigma delta eta
	by sigma delta eta: gen case = 1 if _n==1
	replace case = sum(case)
	

	gen case_prai = case*10000+prai
	drop if case_prai==.

	save "$dataDerived/simulation_validation_all.dta", replace
}
////////////////////////////////////////////////////////////////////////////////


use "$dataDerived/simulation_validation_all.dta", clear

cap mat drop result
levelsof case , loc(casos)
foreach case in `casos' { // For each combination, run the strategy
*foreach case in 1 { // testing
cap noisily {


*loc case=10 // Testing purposes
	use "$dataDerived/simulation_validation_all.dta", clear
	gen year = 2008+t
	gen Af=year==2011
	* Delete extre cases of x2; they generate bunching and might confuse the results....
	gen     flag=1 if x2simu1s>=1 | x2simu1s<=0
	replace flag=1 if x2simu1c>=1 | x2simu1c<=0
	bys case_prai: egen xflag=max(flag)
	drop if xflag==1
	drop flag xflag

	bys t: sum x1simu1s x2simu1s x1simu1c x2simu1c
	glo bw = "bw(0.01)"
	* ..................................................................................
	
	foreach varo of varlist x1simc1s- x2simu1c {
		rename `varo' `varo'Achievement
	}


	disp as text "Evaluando: `case',`eta',`sigma',`delta'"
	keep if case==`case'
		
	* Step 1 .........................
	loc h=10
	loc b=1
	loc w=20
	qui bunchingEst if x1simu1sAchievement>0 & x1simu1sAchievement<100 & x1simu1sAchievement!=. ///
		, whichone("x1simu1s") ul(45) nknots(5) h(`h') wind(`w') b(`b')	graph("no")
	loc bcoef1 	= e(b)[1,1]
	loc bse1	= (e(V)[1,1])^0.5
		
	qui bunchingEst if x1simu1cAchievement>0 & x1simu1cAchievement<100 & x1simu1cAchievement!=. ///
		, whichone("x1simu1c") ul(45) nknots(5) h(`h') wind(`w') b(`b') graph("no")
	loc bcoef2 	= e(b)[1,1]
	loc bse2	= (e(V)[1,1])^0.5
	
	* Step 2 .........................
	
	
	glo controles =""


	forval i=1(1)9 {
		glo superCondL`i' = `i'
		glo superTitlL`i' = "Control: UL + `i' pp., Responsive practices: UL - 10 pp."
	}

	* Removing those that failed in the first stage
	glo thresholdsBU = "45			45 "
	glo indicatorsBU = "x1simu1s	x1simu1c"


	local n : word count $indicatorsBU
	forval i=1(1)`n'  {	// 

	
		local varDepo : word `i' of $indicatorsBU
		local uppt   : word `i' of $thresholdsBU
		
		local varDep = "`varDepo'Achievement"
		
		disp "varDep: `varDep'  |  `varDepo'  | `uppt' "
		
		qui {
	
		local lname : variable label `varDep'
		if "`lname'"=="" local lname ="`varDep'"
		local lname = subinstr("`lname'","_","",.)
		local lname = subinstr("`lname'","&"," and ",.)		
	
		xtset prai year 
		cap drop Below
		cap drop Be
		cap drop inter
		cap drop DAch
		
		// Window selection retained from the archived simulation exercise; use the fixed window below for replication.
		gen Be=`varDep'<(`uppt'/100) if `varDep'!=.
		replace Be=. if `varDep'>((51 )/100)  								// [UL+`hop`i'',100]
		replace Be=. if `varDep'>((`uppt'- 5 )/100) &   `varDep'<((49 )/100)  	// [  UL-5 ,UL+`ini`i'']
		replace Be=. if `varDep'<((`uppt'- 20 )/100)   
		gen Below=L.Be
		gen inter=Below*Af
		
		label var Below "Below: Achiev<Th in t-1"
		label var inter "Below*After"

		gen DAch=D.`varDep' if year>=2010 // Variations from before might be induced by other changes of QOF
		
		reg   DAch inter Below Af $controles if inrange(year,2010,2011), cluster(prai) // 2021.04.16: Final version
		loc didcoef`i' = _b[inter]
		loc didse`i'   = _se[inter]
					
		}
	}
	qui sum eta
	loca eta= r(mean)
	qui sum sigma
	loca sigma= r(mean)	
	qui sum delta
	loca delta= r(mean)		
		
	disp "[`case',`eta',`sigma',`delta',`bcoef1',`bse1',`bcoef2',`bse2',`didcoef1',`didse1',`didcoef2',`didse2']"
	
	mat result = nullmat(result) \ [`case',`eta',`sigma',`delta',`bcoef1',`bse1',`bcoef2',`bse2',`didcoef1',`didse1',`didcoef2',`didse2']	
		
}
}
mat colname result =  case eta sigma delta bcoef1 bse1 bcoef2 bse2 didcoef1 didse1 didcoef2 didse2
mat list result



clear
svmat result, names( col )


gen bll1=bcoef1 - 1.96*bse1
gen bul1=bcoef1 + 1.96*bse1

gen bll2=bcoef2 - 1.96*bse2
gen bul2=bcoef2 + 1.96*bse2

gen didll1=didcoef1 - 1.96*didse1
gen didul1=didcoef1 + 1.96*didse1

gen didll2=didcoef2 - 1.96*didse2
gen didul2=didcoef2 + 1.96*didse2

save "$dataDerived/simulation_validation_regs.dta", replace

////////////////////////////////////////////////////////////////////////////////
// Appendix Figure G1: estimates of steps 1 and 2 with respect to the variance
// of the shocks on achievement, using the simulation exercise.
////////////////////////////////////////////////////////////////////////////////

use "$dataDerived/simulation_validation_regs.dta", clear

* Modifying sigma .............................................................
tw 	(line bcoef1 sigma ) (rarea bll1 bul1 sigma , fcolor(%30) lcolor(%30)  ) ///
	(line bcoef2 sigma ) (rarea bll2 bul2 sigma , fcolor(%30) lcolor(%30)  ) ///
	if abs(delta-1)<0.001 & abs(eta-0)<0.001 , yline(0)  ///
	legend(order(1 "Substitutes" 3 "Complements")) ytitle("Bunching estimate") xtitle({&sigma}) ///
	name(sigma_step1, replace) scheme(plotplainblind) // note("{&delta}=1")
graph export "$imageFold/appendix_figure_g1_step1.png" , replace as(png) // Appendix Figure G1, Panel A
copy "$imageFold/appendix_figure_g1_step1.png" "$imageFold/sim_step1.png", replace
	
tw 	(line didcoef1 sigma) (rarea didll1 didul1 sigma , fcolor(%30) lcolor(%30) ) ///
	(line didcoef2 sigma) (rarea didll2 didul2 sigma , fcolor(%30) lcolor(%30)   ) ///
	if abs(delta-1)<0.001 & abs(eta-0)<0.001 , yline(0)   ///
	legend(order(1 "Substitutes" 3 "Complements")) ytitle("DiD estimate") xtitle({&sigma}) ///
	 name(sigma_step2, replace) scheme(plotplainblind) // note("{&delta}=1")
graph export "$imageFold/appendix_figure_g1_step2.png" , replace as(png) // Appendix Figure G1, Panel B
copy "$imageFold/appendix_figure_g1_step2.png" "$imageFold/sim_step2.png", replace



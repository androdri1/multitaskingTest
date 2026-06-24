/****************************************************************************************
Replication package: Testing for Economies of Scope through an Established P4P Programme
Script: 00_programs_and_globals.do
Language: Stata
Purpose: Helper programs used by the empirical Stata scripts, mainly coefficient-formatting
         routines and table-printing utilities.
Inputs: none.
Outputs: Stata programs in memory; no files written.
Run order: 00. Run before the Stata scripts that use helper programs.
Notes: This version fixes a syntax typo in myCoeff2.
****************************************************************************************/

  ///////////////////////////////////
 /// 0a. Programs and globals     //
///////////////////////////////////

* The Information on this file is necesary for any of the do-files routines
* It includes relevant controls and programs for tables



* *************************************************************
* @ Generate print-friendly versions of stata coefficients
* @ For the case of binary vars, you can add "fac=100", otherwise a "fac=1" is enough
* @ it has to be run after a regression where the first var is the relevant one, and it will
* @ return $coef`number' $se`number' and $star`number'. Something lile 1.23 (0.4) ^{***}
* @ which can be used directly into texdoc. Example: myCoeff 2 100
* @ Any question: p.lesmes.11@ucl.ac.uk
cap program drop myCoeff myCoeff2
program define myCoeff, rclass
args number fac
	est store r`number'
	matrix B=e(b)
	matrix V=e(V)
	glo coef`number' : di %7.2f B[1,1]*`fac'
	glo se`number'   : di %7.2f ((V[1,1])^0.5)*`fac'
	glo sep`number'  = " ( ${se`number'} ) "
	if e(cmd)=="ivregress" | e(cmd)=="xtivreg" {
		scalar pval=2*(1-normal( abs(B[1,1]/((V[1,1])^0.5) )))
	}
	else {  /* Standard OLS */
		scalar pval=2*ttail( e(df_r) , abs(B[1,1]/((V[1,1])^0.5)) )
	}
	glo star`number' = ""
	glo starn`number' = 0
	if ((pval < 0.1) )  glo star`number' = "^{*}" 
	if ((pval < 0.1) )  glo starn`number' = 1
	if ((pval < 0.05) ) glo star`number' = "^{**}" 
	if ((pval < 0.05) ) glo starn`number' = 2	
	if ((pval < 0.01) ) glo star`number' = "^{***}" 
	if ((pval < 0.01) ) glo starn`number' = 3
end
* @ An alternative where instead of asuming that you want the first, you give it the 
* @ name of the variable. If the variable is not there, it returns blanks
* @ Example: myCoeff2 2 100 "treatment"
program define myCoeff2, rclass
args number fac vari
	cap disp _b[`vari']
	if _rc==0 {
		est store r`number'
		local coe=_b[`vari']
		local ste=_se[`vari']
		
		if e(cmd)=="probit" {
			glo coef`number' : di %7.3f `coe'*`fac'
			glo se`number'   : di %7.3f (`ste')*`fac'			
		}
		else {
			glo coef`number' : di %7.3f `coe'*`fac'
			glo se`number'   : di %7.3f (`ste')*`fac'
		}
		glo se`number' = "(${se`number'})"
		glo sep`number'  = "${se`number'}"
		if e(cmd)=="margins" | e(cmd)=="ivregress" | e(cmd)=="sem"  {
			scalar pval=2*(1-normal( abs(`coe'/`ste' )))			
		}
		else {
			scalar pval=2*ttail( e(df_r) , abs(`coe'/`ste' ))
		}
		glo star`number' = ""
		glo starn`number' = 0
		if ((pval < 0.1) )  glo star`number' = "^{*}" 
		if ((pval < 0.1) )  glo starn`number' = 1
		if ((pval < 0.05) ) glo star`number' = "^{**}" 
		if ((pval < 0.05) ) glo starn`number' = 2	
		if ((pval < 0.01) ) glo star`number' = "^{***}" 
		if ((pval < 0.01) ) glo starn`number' = 3
		
		glo pval`number'=pval
	}
	else {
		glo coef`number'=""
		glo se`number'=""
		glo sep`number'=""
		glo star`number'=""
	}
end
* *************************************************************


/////////////////////////////////////////////////////////////////////////////////////////////////
* @DESC: Print a line for a table based on matrix "percent", for the case of discrete outputs
* @ Any question: p.lesmes.11@ucl.ac.uk
* @ARGS:  title - String; title of the segment
*         list  - String; list of categories (variables) to include in the segment
* @REQUIRE:  1. a texdoc instance and a table header already in place
*            2. A set of individual titles enumerated from 1 to `list', as $tit1, $tit2, etc.
*            3. All the variables in list MUST be binary
* @EXAMPLE: printLineCateg "Pit cleaning periodicity" 5  

cap program drop printLineCateg
program define printLineCateg, rclass
args title list

	local listco: word count `list' 

	sort place wave
	mkmat `list', matrix(percent)
	matlist percent

	tex  \cmidrule(r){2-3}  \cmidrule(r){4-5}   \cmidrule(r){6-7}
	tex \multicolumn{7}{l}{\parbox[c]{$widthTBig}{\textbf{`title'}}} \\

	local cont=1
	forval j=1(1)`listco' {
		if (mod(`cont',2)==1) tex \rowcolor{Gray}
		local cont=`cont'+1	
		tex \parbox[c]{$widthTSmall}{\quad ${tit`j'}}
		forval i=1(1)6 { // Number of cols is fixed
			local vali=percent[`i',`j']
			if `vali'!=. {
				local val : di %7.2f percent[`i',`j']
				tex & `val'\%
			}
			else tex & 
		}
		tex \\
	}
	tex \addlinespace[1pt]
				
end


/////////////////////////////////////////////////////////////////////////////////////////////////
* @DESC: Exports a one-way tabulation but taking into account the "0s"
* @ Any question: p.lesmes.11@ucl.ac.uk
* @ARGS:  varDep - Variable to tab
*         cond   - Condition
*         values - A string with the potential values that it could take
*         matcell- Stores the tab in a vector
*         list  - String; list of categories (variables) to include in the segment
* @REQUIRE:  It cannot be called within a Preserve - Restore Module
* @EXAMPLE: fullTab miVar "toilet==1" "0 1 2 ." "TNBL"

cap program drop fullTab	
program define fullTab 	, rclass
args varDep cond values matcell
	preserve
	keep if `cond'
	
	gen trap=0
	foreach val in `values' {
		local new = _N + 1
		set obs `new'
		replace `varDep'=`val' in `new'
		replace trap=1 in `new'
	}
	
	qui tab `varDep' trap, mi matcell(`matcell')
	mat `matcell'=`matcell'[1...,1]
	matlist `matcell'
		
	restore
end
		
		

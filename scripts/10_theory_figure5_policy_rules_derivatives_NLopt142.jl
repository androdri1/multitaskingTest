# --------------------------------------------------------------------------------------
# Replication package: Testing for Economies of Scope through an Established P4P Programme
# Script: 10_theory_figure5_policy_rules_derivatives_NLopt142.jl
# Language: Julia 1.4.2
# Paper output: Appendix Figure B2 / label fig:sim2
# Purpose: Computes policy rules e1(a2) and derivatives for substitute and complementary tasks.
# Run order: run after the folder structure exists. From Rep_folder use:
#             From julia prompt
#             > cd(raw"C:/path/to/Rep_folder")
#             > include("scripts/10_theory_figure5_policy_rules_derivatives_NLopt142.jl")
# Output folder: output/figures
# --------------------------------------------------------------------------------------

using Random
const SCRIPT_DIR = @__DIR__
const ROOT_DIR = normpath(joinpath(SCRIPT_DIR, ".."))
const FIGURE_DIR = joinpath(ROOT_DIR, "output", "figures")
mkpath(FIGURE_DIR)
Random.seed!(20260623)

# Definitions
# Simulation setup
using Distributions   # For drwaing distributions
using NLopt           # Optimizer for the estimation
# Do not load Optim here: in Julia 1.4.2, unqualified optimize(...) can be
# captured by another optimization package if it is already loaded in the session.
# All NLopt calls below are therefore explicitly qualified as NLopt.<function>.
#using Optim
using Interpolations    
using DataFrames      
using PyPlot
#using QuadGK
using FastGaussQuadrature
using StatsBase # histogram comes from here
using LinearAlgebra

#global nodes, weights = gausshermite( 40 );
global nodesL, weightsL= gausslegendre(40);

valsA2=[1:.01:4.5;];

deltaW=[1.7,-1]; # First substitutes, then complements

c1W=[2.5,2]
c2W=[5,2]

xx = range(minimum(valsA2),stop=maximum(valsA2),length=100);

global UL1=0.5 # Upper limit
global UL2=0.99 # Upper limit

raverspar=[ 1.31 2.0;
            0.28 0.35];  # Matrix with values of Z to consider

eta=0.25;

sigma=0.01;   # Standard deviation of the task-1 shock

# Altruism marginal payoff  for task 1 (a1 underbad)
atilde1= 1.2;

# Financial marginal payoff for task 1
fixp1=0.9;  

# Altruism marginal payoff  for task 2
atilde2= 1;

# Financial marginal payoff for task 2
fixp2=0; # Not in use here!!!!



global colobndpal=["#000000", "#E69F00", "#56B4E9", "#009E73"]

# ========

function util(c,eta)
    # computes the utility function
    return ( (c+1)^(1-eta)) / (1-eta)
end


function C(x,c1,c2,delta,z)
    return (1/z).*(0.5*( c1.*(x[1].^(2))+ c2.*( x[2].^(2))  ) + delta.*x[1].*x[2]) ;       #Define costs function
end
function P00(x,p1,atilde1,p2,atilde2,c1,c2,delta,eta,z)
    return util(0                                      ,eta) -C(x,c1,c2,delta,z); ;       #Define profit if hits low TH for both tasks
end
function P01(x,p1,atilde1,p2,atilde2,c1,c2,delta,eta,z)
    return util((atilde2+p2)*x[2]                      ,eta)-C(x,c1,c2,delta,z); ;       #Define profit if hits low TH for task 1, interior sol for task 2
end
function P10(x,p1,atilde1,p2,atilde2,c1,c2,delta,eta,z)
    return util(                    (atilde1+p1)*x[1]  ,eta)-C(x,c1,c2,delta,z); ;       #Define profit if hits low TH for task 2, interior sol for task 1
end
function P11(x,p1,atilde1,p2,atilde2,c1,c2,delta,eta,z)
    return util((atilde2+p2)*x[2]  +(atilde1+p1)*x[1]  ,eta)-C(x,c1,c2,delta,z);         #Define profit in an interior solution in both tasks
end
function P21(x,p1,atilde1,p2,atilde2,c1,c2,delta,eta,z)
    return util((atilde2+p2)*x[2]  +atilde1*x[1]+p1*UL1 ,eta)-C(x,c1,c2,delta,z); ;       #Define profit if hits high TH for task 1, interior sol for task 2
end
function P12(x,p1,atilde1,p2,atilde2,c1,c2,delta,eta,z)
    return util( atilde2*x[2]+p2*UL2+(atilde1+p1)*x[1] ,eta)-C(x,c1,c2,delta,z); ;        #Define profit if hits high TH for task 2, interior sol for task 1
end
function P22(x,p1,atilde1,p2,atilde2,c1,c2,delta,eta,z)
    return  util(atilde2*x[2]+p2*UL2+atilde1*x[1]+p1*UL1 ,eta)-C(x,c1,c2,delta,z); ;       #Define profit if hits high TH for task 1, high TH for task 2
end

#PwUncert([0.3,0.6],fixp1,atilde1,fixp2,atilde2,c1,c2,delta,z,0.3,0.7,[])

# = Normal Distribution
function PwUncert(x,p1,atilde1,p2,atilde2,c1,c2,delta,z,eta,sigma,grad)
    if (x[1]>=0) & (x[1]<=1) & (x[2]>=0) & (x[2]<=1)


        function ff11(ee)
            return util((atilde2+p2)*x[2]  +(atilde1+p1)*(x[1]+ee)  ,eta)*pdf(Normal(0,sigma),ee)
        end
        function ff21(ee)
            return util((atilde2+p2)*x[2]  +atilde1*(x[1]+ee)+p1*UL1 ,eta)*pdf(Normal(0,sigma),ee)
        end
        function hh(ee)
            return util((atilde2+p2)*x[2]  +(atilde1+p1)*(x[1]+ee)   ,eta)*( (x[1]+ee) <UL1  )+
                   util((atilde2+p2)*x[2]  +atilde1*(x[1]+ee)+p1*UL1 ,eta)*( (x[1]+ee)>=UL1  )
        end


        if sigma==0
            valo= P11( [x[1],x[2]] ,p1,atilde1,p2,atilde2,c1,c2,delta,eta,z)*( x[1]<UL1  )+
                  P21( [x[1],x[2]] ,p1,atilde1,p2,atilde2,c1,c2,delta,eta,z)*( x[1]>=UL1 )
        else
            # Gauss-Kronrod .......... QuadGK
            #valo=quadgk(ff11, -1.0,UL1-x[1] ; rtol=20*eps() ,order=20 )[1]+
            #quadgk(ff21, UL1-x[1], 1.0 ; rtol=20*eps() ,order=20  )[1]-C(x,c1,c2,delta,z); 

            # Gauss-Legendre ......... 
            limite=sigma*10; # integration limit for the normal shock
            valo=   ((UL1-x[1]-(-limite))/2 ) * dot(weightsL,  ff11.( ((UL1-x[1]-(-limite))/2 ).*nodesL .+ (((-limite)+UL1-x[1])/2 ) ))+
                    ((limite -(UL1-x[1]))/2 ) * dot(weightsL,  ff21.( ((limite -(UL1-x[1]))/2 ).*nodesL .+ ((   UL1-x[1]+limite)/2 ) ))-C(x,c1,c2,delta,z);
            # Gauss-Hermite ......... FastGaussQuadrature
            #valo=(1/sqrt(pi)) * dot(weights,hh.( sqrt(2).*sigma.*nodes )) -C(x,c1,c2,delta,z);
        end

        return valo;

    else
        return -1000
    end
end

# NLopt derivative-free optimizer. This block is Julia 1.4.2 compatible.
# The NLopt namespace is explicit to avoid conflicts with Optim.optimize in shared sessions.
myOptimAlg=Symbol("LN_SBPLX")
#myOptimAlg=Symbol("LN_BOBYQA")
#myOptimAlg=Symbol("LN_COBYLA")

optwUncert = NLopt.Opt(myOptimAlg, 2)
NLopt.lower_bounds!(optwUncert, [0.0,0.0])
NLopt.upper_bounds!(optwUncert, [1.0,1.0])
#NLopt.xtol_rel!(optwUncert,1e-16)
#NLopt.ftol_rel!(optwUncert,1e-16)
#
      
# =======================================================================
# Policy rules
# =======================================================================
   # delta>0: This is the so-called effort-substitution problem
    #          Rising effort in one task increases the cost of the other
    # delta<0: economies of scope, both tasks are "complements"

# Pre-allocate Policy rules
yy1=zeros(Float64,2,length(xx),length(raverspar));
yy2=zeros(Float64,2,length(xx),length(raverspar));

yyU1=zeros(Float64,2,length(xx),length(raverspar));
yyU2=zeros(Float64,2,length(xx),length(raverspar));

# Pre-allocate Policy rules derivatives
dyy1=zeros(Float64,2,length(xx),length(raverspar));
dyy2=zeros(Float64,2,length(xx),length(raverspar));

dyyU1=zeros(Float64,2,length(xx),length(raverspar));
dyyU2=zeros(Float64,2,length(xx),length(raverspar));

# For the graph caption
caption=Array{Any}(undef,2);



for case = 1:2 # Substitues & Complements

    global delta=deltaW[case];        #  delta<sqrt(c1*c2) if you want an interior solution
    global c1=c1W[case];
    global c2=c2W[case];    
    caption[case]=latexstring("Specific Parameters: \$\\delta=",delta,"\$,  \$\\eta=",eta,"\$, \$c_1=",c1,"\$, \$c_2=",c2,"\$ ")

    for r=1:size(raverspar)[2]
        println("We are running delta=",delta," and z=",raverspar[case,r]) 
        
        z=raverspar[case,r];

        # Simulate results in order to get x[1]* for different a2s
        valsx1star=zeros(length(valsA2));
        valsx2star=zeros(length(valsA2));
        for c1i=1:length(valsA2)
            
            NLopt.min_objective!(optwUncert, (xEst,grad::Vector) -> -PwUncert(xEst,fixp1,atilde1,fixp2,valsA2[c1i],c1,c2,delta,z,eta,0,[]) )
            (val, xst, ret) = NLopt.optimize(optwUncert, [UL1, UL2])
            valsx1star[c1i]=xst[1];
            valsx2star[c1i]=xst[2];
            #=

                    f(xEst)=-PwUncert(xEst,fixp1,atilde1,fixp2,valsA2[c1i],c1,c2,delta,z,eta,0,[])

                    lower = [0.,0.]
                    upper = [1.,1.]
                    initial_x = [UL1,UL2]
                    inner_optimizer = GradientDescent()
                    res = optimize(f,lower, upper, initial_x, Fminbox(inner_optimizer))
                    #res = optimize(f, initial_x, NelderMead() ) #Fminbox(inner_optimizer))
                    
                    valsx1star[c1i]=Optim.minimizer(res)[1];
                    valsx2star[c1i]=Optim.minimizer(res)[2];   
            =#         
        end    

        # Join the dots to make it slighlty nicer
        intp1=interpolate((valsA2,), valsx1star, Gridded(Linear()) );
        intp2=interpolate((valsA2,), valsx2star, Gridded(Linear()) );
        yy1[case,:,r] = intp1(xx);
        yy2[case,:,r] = intp2(xx);   

        for i=1:length(xx)
            dyy1[case,i,r] = Interpolations.gradient(intp1,xx[i])[1]
            dyy2[case,i,r] = Interpolations.gradient(intp2,xx[i])[1]
        end
        
        # &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
        # Numeric version with uncertainty and risk aversion  

      
        # Simulate results in order to get x[1]* for different a2s
        valsx1star2=zeros(1,length(valsA2));
        valsx2star2=zeros(1,length(valsA2));
        for c1i=1:length(valsA2)
            
            NLopt.min_objective!(optwUncert, (xEst,grad::Vector) -> -PwUncert(xEst,fixp1,atilde1,fixp2,valsA2[c1i],c1,c2,delta,z,eta,sigma,[]) )
            (val, xst, ret) = NLopt.optimize(optwUncert, [valsx1star[c1i], valsx2star[c1i]])
            valsx1star2[c1i]=xst[1];
            valsx2star2[c1i]=xst[2];
            #=
                    f(xEst)=-PwUncert(xEst,fixp1,atilde1,fixp2,valsA2[c1i],c1,c2,delta,z,eta,sigma,[])

                    lower = [0.,0.]
                    upper = [1.,1.]
                    initial_x = [valsx1star[c1i],valsx2star[c1i]]
                    inner_optimizer = GradientDescent()
                    res = optimize(f,lower, upper, initial_x, Fminbox(inner_optimizer))
                    #res = optimize(f, initial_x, NelderMead() ) #Fminbox(inner_optimizer))
                    valsx1star2[c1i]=Optim.minimizer(res)[1];
                    valsx2star2[c1i]=Optim.minimizer(res)[2];       
            =#     
        end    

        # Join the dots to make it slighlty nicer
        intp1=interpolate((valsA2,), dropdims(valsx1star2,dims=1), Gridded(Linear()) );
        intp2=interpolate((valsA2,), dropdims(valsx2star2,dims=1), Gridded(Linear()) );
        yyU1[case,:,r] = intp1(xx);
        yyU2[case,:,r] = intp2(xx);   

        for i=1:length(xx)
            dyyU1[case,i,r] = Interpolations.gradient(intp1,xx[i])[1]
            dyyU2[case,i,r] = Interpolations.gradient(intp2,xx[i])[1]
        end        
    end
end

# ===========================================================================
# Generate a nice graphic
# ===========================================================================


    close()
    fig1 = figure("pyplot_subplot_mixed",figsize=(10,8),facecolor="white") # Create a new blank figure
    subplots_adjust(hspace=0.0, wspace = 0.3)


    # ===========================================================================
    # Graph results of the "policy rules" ****** 

    ax1=subplot(221) # For substitutes

        #plot(xx,yy1[1,:,1],label=string("No uncertainty"),lw=3,color=colobndpal[1])  
        #for r=1:size(raverspar)[2]
            #plot(xx,yyU1[1,:,r],label=latexstring("z=",raverspar[1,r]),lw=3,color=colobndpal[r+1]) 
            plot(xx,yyU1[1,:,1],label=latexstring("z=",raverspar[1,1]),lw=3,color=colobndpal[1]) 
            plot(xx,yyU1[1,:,2],label=latexstring("z=",raverspar[1,2]),lw=3,color=colobndpal[2],"r--") 
        #end
        plot(xx,yyU1[1,:,1]*0 .+ UL1,lw=2,"r--")              
        vlines(3.1, 0, 1)

        tick_params(axis="both", which="major", labelsize=11)
        xlabel(L"$a_2$", fontsize=15)
        ylabel(L"$e_1$", fontsize=15, rotation="horizontal")
        title("Substitute Tasks", fontsize=15)
        grid("on")
        yscale("linear")
        xlim([minimum(valsA2), maximum(valsA2)])           
        ylim([0.2, 0.7])          
        legend(loc=1, shadow=true) #, bbox_to_anchor=(1.05, 1), borderaxespad=0.     

        yticks( [0.2,0.3,0.4,0.5,0.6,0.7] )
        ax1.yaxis.set_ticklabels(["0.2","0.3","0.4","UL=0.5","0.6","0.7"])

    ax2=subplot(222) # For Complements

        #plot(xx,yy1[2,:,1],label=string("No uncertainty"),lw=3,color=colobndpal[1])  
        #for r=1:size(raverspar)[2]
            #plot(xx,yyU1[2,:,r],label=latexstring("z=",raverspar[2,r]),lw=3,color=colobndpal[r+1])
            plot(xx,yyU1[2,:,1],label=latexstring("z=",raverspar[2,1]),lw=3,color=colobndpal[1])
            plot(xx,yyU1[2,:,2],label=latexstring("z=",raverspar[2,2]),lw=3,color=colobndpal[2],"r--")
        #end
        plot(xx,yyU1[2,:,1]*0 .+ UL1,lw=2,"r--")              
        vlines(2.5, 0, 1)

        tick_params(axis="both", which="major", labelsize=11)
        xlabel(L"$a_2$", fontsize=15)
        ylabel(L"$e_1$", fontsize=15, rotation="horizontal")
        title("Complementary Tasks", fontsize=15)
        grid("on")
        yscale("linear")
        xlim([minimum(valsA2), maximum(valsA2)])           
        ylim([0.2, 0.7])       
        legend(loc=2, shadow=true) #, bbox_to_anchor=(1.05, 1), borderaxespad=0.    

        yticks( [0.2,0.3,0.4,0.5,0.6,0.7] )
        ax2.yaxis.set_ticklabels(["0.2","0.3","0.4","UL=0.5","0.6","0.7"])

    # =============================
    # Derivatives

    subplot(223, adjustable="box", aspect=1.3) # For substitutes

        #plot(xx,10 .*dyy1[1,:,1],label=string("No uncertainty"),lw=3,color=colobndpal[1])  
        #for r=1:size(raverspar)[2]
            #plot(xx,10 .*dyyU1[1,:,r],label=latexstring("z=",raverspar[1,r]),lw=3,color=colobndpal[r+1])
            plot(xx,10 .*dyyU1[1,:,1],label=latexstring("z=",raverspar[1,1]),lw=3,color=colobndpal[1])
            plot(xx,10 .*dyyU1[1,:,2],label=latexstring("z=",raverspar[1,2]),lw=3,color=colobndpal[2],"r--")
        #end
        plot(xx,10 .*dyyU1[1,:,1]*0,lw=2,"r--")   
        vlines(3.1, -1.1, 1.1 )

        tick_params(axis="both", which="major", labelsize=11)
        xlabel(latexstring("\$ a_2 \$ \n \$\\delta=",deltaW[1],"\$, \$c_1=",c1W[1],"\$, \$c_2=",c2W[1],"\$"), fontsize=15)
        ylabel(L"$\frac{de_1}{da_2} \times 10$", fontsize=12, rotation=90)
        grid("on")
        yscale("linear")
        xlim([minimum(valsA2), maximum(valsA2)])           
        ylim([-0.6, 0.6]) 
        text(0,-2.5,caption[1] , fontsize=14)  

    subplot(224, adjustable="box", aspect=1.3) # For Complements

        #plot(xx,10 .*dyy1[2,:,1],label=string("No uncertainty"),lw=3,color=colobndpal[1])  
        #for r=1:size(raverspar)[2]
            #plot(xx,10 .*dyyU1[2,:,r],label=latexstring("z=",raverspar[2,r]),lw=3,color=colobndpal[r+1])
            plot(xx,10 .*dyyU1[2,:,1],label=latexstring("z=",raverspar[2,1]),lw=3,color=colobndpal[1])
            plot(xx,10 .*dyyU1[2,:,2],label=latexstring("z=",raverspar[2,2]),lw=3,color=colobndpal[2],"r--")
        #end
        plot(xx,10 .*dyyU1[2,:,1]*0,lw=2,"r--") 
        vlines(2.5, -1.1, 1.1 )

        tick_params(axis="both", which="major", labelsize=11)
        xlabel(latexstring("\$ a_2 \$ \n \$\\delta=",deltaW[2],"\$, \$c_1=",c1W[2],"\$, \$c_2=",c2W[2],"\$"), fontsize=15)
        ylabel(L"$\frac{de_1}{da_2} \times 10$", fontsize=12, rotation=90)
        grid("on")
        yscale("linear")
        xlim([minimum(valsA2), maximum(valsA2)])           
        ylim([-0.6, 0.6]) 
        text(0,-2.5,caption[2] , fontsize=14)


alow1=fixp1+atilde1

suptitle(latexstring("Common Parameters: \$ a^R_1=",atilde1,"\$, \$ a^L_1=",alow1,",\$ \$\\sigma=",sigma,"\$, \$\\eta=",eta,"\$"), fontsize=15)

savefig(joinpath(FIGURE_DIR, "figure05_policy_rules_derivatives.pdf"), dpi=150)
savefig(joinpath(FIGURE_DIR, "de1da2_uncertainty.pdf"), dpi=150)  # imported by appendix.tex
# "\$, \$c_1=",c1,"\$, \$c_2=",c2,

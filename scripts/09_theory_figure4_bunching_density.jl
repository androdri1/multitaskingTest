# --------------------------------------------------------------------------------------
# Replication package: Testing for Economies of Scope through an Established P4P Programme
# Script: 09_theory_figure4_bunching_density.jl
# Language: Julia 1.4.2
# Paper output: main text Figure 4 / label fig:sim1
# Purpose: Simulates the density of e1 under uncertainty and risk aversion.
# Run order: run after the folder structure exists. From Rep_folder use:
#             From julia prompt
#             > cd(raw"C:/path/to/Rep_folder")
#             > include("scripts/09_theory_figure4_bunching_density.jl")
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
# NLopt is not used in this script; Optim.jl is used below.
using Optim
using Interpolations    
using DataFrames      
using PyPlot
#using QuadGK
using FastGaussQuadrature
using StatsBase # histogram comes from here
using LinearAlgebra

#global nodes, weights = gausshermite( 40 );
global nodesL, weightsL= gausslegendre(40);

valsA2=[1:.2:4.5;];
valsZ=[0.1:.05:4.5;]; # For the bunching graph

deltaW=[1,-1]; # First substitutes, then complements
zW=[1.05,0.3];       # For the A2
c1W=[2,2]
c2W=[7,2]

xx = range(minimum(valsA2),stop=maximum(valsA2),length=100);

global UL1=0.5 # Upper limit
global UL2=0.99 # Upper limit

# Additional eta values can be added for sensitivity exercises.
gridEta=[0.65]

sigma=0.05;   # Standard deviation of the task-1 shock

# Altruism marginal payoff  for task 1
atilde1= 1;

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

#=
#myOptimAlg=Symbol("LN_SBPLX")
myOptimAlg=Symbol("LN_BOBYQA")
#myOptimAlg=Symbol("LN_COBYLA")

optwUncert = Opt(myOptimAlg, 2)
lower_bounds!(optwUncert, [0,0])
upper_bounds!(optwUncert, [1,1])
#xtol_rel!(optwUncert,1e-16)
#ftol_rel!(optwUncert,1e-16)
=#

# =======================================================================================
# e1(z)
# =======================================================================================

# Pre-allocate Policy rules
yy1=zeros(Float64,2,length(xx),length(gridEta));
yy2=zeros(Float64,2,length(xx),length(gridEta));

yyU1=zeros(Float64,2,length(xx),length(gridEta));
yyU2=zeros(Float64,2,length(xx),length(gridEta));

valZmaxG=maximum(valsZ) # This is for the graphs only !
xx = range(minimum(valsZ),stop=valZmaxG,length=100);


# For the graph caption
caption=Array{Any}(undef,2);


for case = 1:2 # Substitues & Complements

    global delta=deltaW[case];        #  delta<sqrt(c1*c2) if you want an interior solution
    global z=zW[case];
    global c1=c1W[case];
    global c2=c2W[case];        
    caption[case]=latexstring("Specific Parameters: \$\\delta=",delta,"\$,  \$z=",z,"\$, \$c_1=",c1,"\$, \$c_2=",c2,"\$ ")


    for r=1:length(gridEta)
        println("We are running delta=",delta," and eta=",gridEta[r])
        
        eta=gridEta[r];

        # Simulate results in order to get x[1]* for different a2s
        valsx1star=zeros(length(valsZ));
        valsx2star=zeros(length(valsZ));
        for c1i=1:length(valsZ)
            #=
            min_objective!(optwUncert, (xEst,grad::Vector) -> -PwUncert(xEst,fixp1,atilde1,fixp2,atilde2,c1,c2,delta,valsZ[c1i],eta,0,[]) )
            (val, xst, ret)=optimize(optwUncert,[UL1,UL2])
            valsx1star[c1i]=xst[1];
            valsx2star[c1i]=xst[2];
            =#

            f(xEst)=-PwUncert(xEst,fixp1,atilde1,fixp2,atilde2,c1,c2,delta,valsZ[c1i],eta,0,[])

            lower = [0.,0.]
            upper = [1.,1.]
            initial_x = [UL1,UL2]
            inner_optimizer = GradientDescent()
            res = optimize(f,lower, upper, initial_x, Fminbox(inner_optimizer))
            #res = optimize(f, initial_x, NelderMead() ) #Fminbox(inner_optimizer))
            
            valsx1star[c1i]=Optim.minimizer(res)[1];
            valsx2star[c1i]=Optim.minimizer(res)[2];            
        end    

        # Join the dots to make it slighlty nicer
        intp1=interpolate((valsZ,), valsx1star, Gridded(Linear()) );
        intp2=interpolate((valsZ,), valsx2star, Gridded(Linear()) );
        yy1[case,:,r] = intp1(xx);
        yy2[case,:,r] = intp2(xx);   
        
        # &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
        # Numeric version with uncertainty and risk aversion  

      
        # Simulate results in order to get x[1]* for different a2s
        valsx1star2=zeros(Float64,1,length(valsZ));
        valsx2star2=zeros(Float64,1,length(valsZ));
        for c1i=1:length(valsZ)
            #=
            min_objective!(optwUncert, (xEst,grad::Vector) -> -PwUncert(xEst,fixp1,atilde1,fixp2,atilde2,c1,c2,delta,valsZ[c1i],eta,sigma,[]) )
            (val, xst, ret)=optimize(optwUncert,[valsx1star[c1i],valsx2star[c1i]])
            valsx1star2[c1i]=xst[1];
            valsx2star2[c1i]=xst[2];
            =#

            f(xEst)=-PwUncert(xEst,fixp1,atilde1,fixp2,atilde2,c1,c2,delta,valsZ[c1i],eta,sigma,[])

            lower = [0.,0.]
            upper = [1.,1.]
            initial_x = [valsx1star[c1i],valsx2star[c1i]]
            inner_optimizer = GradientDescent()
            res = optimize(f,lower, upper, initial_x, Fminbox(inner_optimizer))
            #res = optimize(f, initial_x, NelderMead() ) #Fminbox(inner_optimizer))
            valsx1star2[c1i]=Optim.minimizer(res)[1];
            valsx2star2[c1i]=Optim.minimizer(res)[2];
        end    

        # Join the dots to make it slighlty nicer
        intp1=interpolate((valsZ,), dropdims(valsx1star2,dims=1), Gridded(Linear()) );
        intp2=interpolate((valsZ,), dropdims(valsx2star2,dims=1), Gridded(Linear()) );
        yyU1[case,:,r] = intp1(xx);
        yyU2[case,:,r] = intp2(xx);   
        
    end
end

# ===========================================================================
# Generate a nice graphic
# ===========================================================================
for case = 1:2 # Substitues & Complements

    global delta=deltaW[case];        #  delta<sqrt(c1*c2) if you want an interior solution
    global z=zW[case];
    global c1=c1W[case];
    global c2=c2W[case]; 

    close()
    fig2 = figure("pyplot_subplot_mixed",figsize=(10,8),facecolor="white") # Create a new blank figure
    subplots_adjust(hspace=0.0)


    # ===========================================================================
    # Graph results of the "policy rules" ****** 

    ax1=subplot(121) # Create the 1st axis of a 2x2 arrax of axes

        plot(xx,yy1[case,:,1],label=string("No uncertainty"),lw=3,color=colobndpal[1])  
        for r=1:length(gridEta)
            plot(xx,yyU1[case,:,r],label=latexstring("\\eta=",gridEta[r]),lw=3,color=colobndpal[r+1])
        end
        plot(xx,yyU1[case,:,1]*0 .+ UL1,lw=2,"r--" )              
        
        tick_params(axis="both", which="major", labelsize=11)
        xlabel(L"$z$", fontsize=12)
        ylabel(L"$e_1$", fontsize=12)
        title(L"$e_1(z)$", fontsize=12)
        grid("on")
        yscale("linear")
        #xlim([minimum(valsZ), maximum(valsZ)])           
        xlim([minimum(valsZ), 3.5])           
        ylim([minimum(yyU1[case,:,1]), maximum(yyU1[case,:,1])])          
        #fig2[:legend]=legend(loc=4, shadow=true) #, bbox_to_anchor=(1.05, 1), borderaxespad=0.        
        legend(loc=4, shadow=false) #, bbox_to_anchor=(1.05, 1), borderaxespad=0. 
        yticks( [0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9] )
        ax1.yaxis.set_ticklabels(["0.2","0.3","0.4","UL=0.5","0.6","0.7","0.8","0.9"])

    # ===========================================================================
    # Let's simulate some guys, and see how the distribution behaves

    ax2=subplot(122) # Create a plot and make it a polar plot, 2nd axis of 2x2 axis grid


        S=10000

        maxz=(c1*c2-delta^2)/( (atilde1+fixp1)*c2-delta*(fixp2+atilde2)) # To ensure a nice uniform distribution on x1 from 0 to 1

        x1Sim = Array{Float64}(undef,S);
        x2Sim = Array{Float64}(undef,S);
        #zSim=rand(Uniform(0.1,maxz) ,S);
        zSim=rand(Uniform(minimum(valsZ),maximum(valsZ)) ,S);
        #zSim=rand(Beta(4, 2) ,S).*3;

        # No uncertainty
            intpX1=interpolate( (xx,) , yy1[case,:,1] , Gridded(Linear()) );
            intpX2=interpolate( (xx,) , yy1[case,:,1] , Gridded(Linear()) );
            for s=1:S
                x1Sim[s]=intpX1(zSim[s]);
                x2Sim[s]=intpX2(zSim[s]);
            end

			x1SimX=x1Sim[x1Sim.<=.98] # Take out the one hundred
			x2SimX=x2Sim[x1Sim.<=.98]
            #x1SimX=x1Sim   # If you want to see the full domain instead

            xhist=fit(Histogram, x1SimX, nbins=100)

            nbinsc=length(xhist.edges[1])
            xauc=sum(xhist.weights)
            xvec=vec([z::Float64 for z in xhist.edges[1]]) #Los cortes, se toma el elemento [1] para acceder al vector
            xdf=DataFrame(xmin=vec(xvec[1:(nbinsc-1)]),xmax=vec(xvec[2:nbinsc]),count=xhist.weights)
            xdf[!,:dens]=xdf[!,:count]/xauc;

            xnu=xdf[!,:xmin][1:(nbinsc-1)] 
            ynu=xdf[!,:dens][1:(nbinsc-1)] 

            plot(ynu*1.1,ynu*0 .+ UL1,lw=1,"r--") # Reference line at UL
            barh(xnu,ynu,0.02,align="center",color=colobndpal[1],alpha=0.4 ,label=string("No uncertainty") )


        # With uncertainty    
        for r=1:length(gridEta)
            local intpX1=interpolate( (xx,) , yyU1[case,:,r] , Gridded(Linear()) );
            local intpX2=interpolate( (xx,) , yyU2[case,:,r] , Gridded(Linear()) );

            for s=1:S
                x1Sim[s]=intpX1(zSim[s]);
                x2Sim[s]=intpX2(zSim[s]);
            end

			x1SimX=x1Sim[x1Sim.<=.98] # Take out the one hundred
			x2SimX=x2Sim[x1Sim.<=.98]
            #x1SimX=x1Sim  # If you want to see the full domain instead

            local xhist=fit(Histogram, x1SimX, nbins=50)
            local nbinsc=length(xhist.edges[1])
            local xauc=sum(xhist.weights)
            local xvec=vec([z::Float64 for z in xhist.edges[1]]) #Los cortes, se toma el elemento [1] para acceder al vector
            local xdf=DataFrame(xmin=vec(xvec[1:(nbinsc-1)]),xmax=vec(xvec[2:nbinsc]),count=xhist.weights)
            xdf[!,:dens]=xdf[!,:count]/xauc;

            local x=xdf[!,:xmin][1:(nbinsc-1)]  
            local y=xdf[!,:dens][1:(nbinsc-1)]  

            barh(x,y,0.02,align="center",color=colobndpal[r+1],alpha=0.4 ,label=latexstring("\\eta=",gridEta[r]) )
        end

        grid("on")
        tick_params(axis="both", which="major", labelsize=11)
        xlabel("Density", fontsize=12)
        ylabel(L"$e_1$", fontsize=12)
        title(L"Histogram of $e_1$", fontsize=12)
        xlim(0,0.2)  # Top of the no-uncertainty accumulation is approximately 0.17
        ylim([minimum(yyU1[case,:,1]), maximum(yyU1[case,:,1])])          

        legend(loc=4, shadow=false) #, bbox_to_anchor=(1.05, 1), borderaxespad=0. 
        yticks( [0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9] )


    # ===========================================================================

    alow1=fixp1+atilde1

    # Save a transparent replication filename plus the legacy filename imported by mainRevision.tex.
    canonical_name = case == 1 ? "figure04_bunching_substitutes.pdf" : "figure04_bunching_complements.pdf"
    savefig(joinpath(FIGURE_DIR, canonical_name), dpi=150)
    if case == 1
        savefig(joinpath(FIGURE_DIR, "Bunching1_uncertainty.pdf"), dpi=150)  # imported by mainRevision.tex
    end
end

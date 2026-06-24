# --------------------------------------------------------------------------------------
# Replication package: Testing for Economies of Scope through an Established P4P Programme
# Script: 12_AppendixB2_simulation_inputs_NLopt142.jl
# Language: Julia 1.4.2
# Paper output: inputs for MT02_simulationExercise.do / simulation appendix
# Purpose: Generates individual-level theory simulations used by the Stata simulation exercise.
#
# Run order: run after the folder structure exists. From Rep_folder use:
#             From Julia prompt
#             > cd(raw"C:/path/to/Rep_folder")
#             > include("scripts/12_AppendixB2_simulation_inputs_NLopt142.jl")
# Output folder: data/derived/simulation_csvs
# Output files: simulations<eta-index><sigma-index><delta-index>.csv
# --------------------------------------------------------------------------------------

using Random
const SCRIPT_DIR = @__DIR__
const ROOT_DIR = normpath(joinpath(SCRIPT_DIR, ".."))
const SIMUL_DIR = joinpath(ROOT_DIR, "data", "derived", "simulation_csvs")
mkpath(SIMUL_DIR)
Random.seed!(20260624)

using Distributions
using NLopt
# Do not load Optim here. In Julia 1.4.2, unqualified optimize(...) can be
# captured by another optimization package if it is already loaded in the session.
# All NLopt calls below are therefore explicitly qualified as NLopt.<function>.
using Interpolations
using DataFrames
using CSV
using FastGaussQuadrature
using StatsBase
using LinearAlgebra

# ======================================================================
# Parameters
# ======================================================================

const GRID_ETA   = collect(0.0:0.1:0.1)
const GRID_SIGMA = collect(0.01:0.01:0.10)
const GRID_DELTA = [1.0]

const VALS_A2 = collect(1.0:0.3:1.3)      # a2 regimes: high in t=1,2; low in t=3
const VALS_Z  = collect(0.1:0.2:4.98)     # z grid for policy rules and simulations
const Z_GRID_FINE = collect(range(minimum(VALS_Z), stop=maximum(VALS_Z), length=100))

const C1_BY_CASE = [2.0, 8.0]
const C2_BY_CASE = [2.0, 8.0]

const UL1 = 0.5
const UL2 = 0.99

const ATILDE1 = 1.2
const FIXP1 = 1.0
const FIXP2 = 0.0

const N_PEOPLE = 10_000
const N_PERIODS = 3
const NOISE_HALF_WIDTH = 0.01

const GL_NODES_WEIGHTS = gausslegendre(40)
const NODES_L = GL_NODES_WEIGHTS[1]
const WEIGHTS_L = GL_NODES_WEIGHTS[2]
const OPTIM_ALG = Symbol("LN_SBPLX")

# ======================================================================
# Model primitives
# ======================================================================

function util(c, eta)
    return ((c + 1)^(1 - eta)) / (1 - eta)
end

function cost_function(x, c1, c2, delta, z)
    return (1 / z) * (0.5 * (c1 * x[1]^2 + c2 * x[2]^2) + delta * x[1] * x[2])
end

function P11(x, p1, atilde1, p2, atilde2, c1, c2, delta, eta, z)
    return util((atilde2 + p2) * x[2] + (atilde1 + p1) * x[1], eta) -
           cost_function(x, c1, c2, delta, z)
end

function P21(x, p1, atilde1, p2, atilde2, c1, c2, delta, eta, z)
    return util((atilde2 + p2) * x[2] + atilde1 * x[1] + p1 * UL1, eta) -
           cost_function(x, c1, c2, delta, z)
end

function PwUncert(x, p1, atilde1, p2, atilde2, c1, c2, delta, z, eta, sigma)
    if (x[1] < 0.0) || (x[1] > 1.0) || (x[2] < 0.0) || (x[2] > 1.0)
        return -1000.0
    end

    if sigma == 0.0
        return P11(x, p1, atilde1, p2, atilde2, c1, c2, delta, eta, z) * (x[1] < UL1) +
               P21(x, p1, atilde1, p2, atilde2, c1, c2, delta, eta, z) * (x[1] >= UL1)
    end

    function ff11(ee)
        return util((atilde2 + p2) * x[2] + (atilde1 + p1) * (x[1] + ee), eta) *
               pdf(Normal(0, sigma), ee)
    end

    function ff21(ee)
        return util((atilde2 + p2) * x[2] + atilde1 * (x[1] + ee) + p1 * UL1, eta) *
               pdf(Normal(0, sigma), ee)
    end

    # Gauss-Legendre restricted to shocks in [-10 sigma, 10 sigma], preserving
    # the numerical approximation used in the original simulation script.
    limit = sigma * 10
    part1 = ((UL1 - x[1] - (-limit)) / 2) *
            dot(WEIGHTS_L,
                ff11.(((UL1 - x[1] - (-limit)) / 2) .* NODES_L .+ (((-limit) + UL1 - x[1]) / 2)))
    part2 = ((limit - (UL1 - x[1])) / 2) *
            dot(WEIGHTS_L,
                ff21.(((limit - (UL1 - x[1])) / 2) .* NODES_L .+ ((UL1 - x[1] + limit) / 2)))

    return part1 + part2 - cost_function(x, c1, c2, delta, z)
end

function solve_effort(atilde2, c1, c2, delta, z, eta, sigma, initial_x)
    opt = NLopt.Opt(OPTIM_ALG, 2)
    NLopt.lower_bounds!(opt, [0.0, 0.0])
    NLopt.upper_bounds!(opt, [1.0, 1.0])
    NLopt.min_objective!(opt, (x_est, grad) -> -PwUncert(x_est, FIXP1, ATILDE1, FIXP2,
                                                         atilde2, c1, c2, delta, z, eta, sigma))
    (val, xst, ret) = NLopt.optimize(opt, initial_x)
    return xst, val, ret
end

function compute_policy_rules(eta, sigma, delta_abs)
    yy1  = zeros(Float64, 2, length(Z_GRID_FINE), length(VALS_A2))
    yy2  = zeros(Float64, 2, length(Z_GRID_FINE), length(VALS_A2))
    yyU1 = zeros(Float64, 2, length(Z_GRID_FINE), length(VALS_A2))
    yyU2 = zeros(Float64, 2, length(Z_GRID_FINE), length(VALS_A2))

    for a2_index in 1:length(VALS_A2)
        atilde2 = VALS_A2[a2_index]

        for case in 1:2
            delta = ((-1)^(case + 1)) * delta_abs
            c1 = C1_BY_CASE[case]
            c2 = C2_BY_CASE[case]

            println("Policy rules: case=", case,
                    ", delta=", delta,
                    ", eta=", eta,
                    ", sigma=", sigma,
                    ", a2=", atilde2)

            valsx1star = zeros(Float64, length(VALS_Z))
            valsx2star = zeros(Float64, length(VALS_Z))

            for zi in 1:length(VALS_Z)
                xst, _, _ = solve_effort(atilde2, c1, c2, delta, VALS_Z[zi], eta, 0.0, [UL1, UL2])
                valsx1star[zi] = xst[1]
                valsx2star[zi] = xst[2]
            end

            intp1 = interpolate((VALS_Z,), valsx1star, Gridded(Linear()))
            intp2 = interpolate((VALS_Z,), valsx2star, Gridded(Linear()))
            yy1[case, :, a2_index] = intp1(Z_GRID_FINE)
            yy2[case, :, a2_index] = intp2(Z_GRID_FINE)

            valsx1star2 = zeros(Float64, length(VALS_Z))
            valsx2star2 = zeros(Float64, length(VALS_Z))

            for zi in 1:length(VALS_Z)
                xst, _, _ = solve_effort(atilde2, c1, c2, delta, VALS_Z[zi], eta, sigma,
                                         [valsx1star[zi], valsx2star[zi]])
                # Repeat once, as in the original simulation script, to stabilize the local search.
                xst, _, _ = solve_effort(atilde2, c1, c2, delta, VALS_Z[zi], eta, sigma, xst)
                valsx1star2[zi] = xst[1]
                valsx2star2[zi] = xst[2]
            end

            intp1u = interpolate((VALS_Z,), valsx1star2, Gridded(Linear()))
            intp2u = interpolate((VALS_Z,), valsx2star2, Gridded(Linear()))
            yyU1[case, :, a2_index] = intp1u(Z_GRID_FINE)
            yyU2[case, :, a2_index] = intp2u(Z_GRID_FINE)
        end
    end

    return yy1, yy2, yyU1, yyU2
end

function simulate_panel(yy1, yy2, yyU1, yyU2; S=N_PEOPLE, T=N_PERIODS)
    x1SimC1 = Array{Float64}(undef, S, T, 2)
    x2SimC1 = Array{Float64}(undef, S, T, 2)
    x1SimU1 = Array{Float64}(undef, S, T, 2)
    x2SimU1 = Array{Float64}(undef, S, T, 2)

    x1Sim = Array{Float64}(undef, S)
    x2Sim = Array{Float64}(undef, S)
    zSim = rand(Uniform(minimum(VALS_Z), maximum(VALS_Z)), S)

    for t in 1:T
        # In t=1 and t=2, a2 is high; in t=3, a2 falls.
        a2_scenario = (t == 3) ? 1 : 2

        aggregate_shock = 0.0
        noise1 = rand(Uniform(-NOISE_HALF_WIDTH, NOISE_HALF_WIDTH), S) .+ aggregate_shock
        noise2 = rand(Uniform(-NOISE_HALF_WIDTH, NOISE_HALF_WIDTH), S) .+ aggregate_shock

        for case in 1:2
            intpX1 = interpolate((Z_GRID_FINE,), yy1[case, :, a2_scenario], Gridded(Linear()))
            intpX2 = interpolate((Z_GRID_FINE,), yy2[case, :, a2_scenario], Gridded(Linear()))
            for s in 1:S
                x1Sim[s] = intpX1(zSim[s])
                x2Sim[s] = intpX2(zSim[s])
            end
            x1SimC1[:, t, case] = x1Sim
            x2SimC1[:, t, case] = x2Sim

            intpX1u = interpolate((Z_GRID_FINE,), yyU1[case, :, a2_scenario], Gridded(Linear()))
            intpX2u = interpolate((Z_GRID_FINE,), yyU2[case, :, a2_scenario], Gridded(Linear()))
            for s in 1:S
                x1Sim[s] = intpX1u(zSim[s]) + noise1[s]
                x2Sim[s] = intpX2u(zSim[s]) + noise2[s]
            end
            x1SimU1[:, t, case] = x1Sim
            x2SimU1[:, t, case] = x2Sim
        end
    end

    return DataFrame(
        x1SimC1s = [x1SimC1[:, 1, 1]; x1SimC1[:, 2, 1]; x1SimC1[:, 3, 1]],
        x2SimC1s = [x2SimC1[:, 1, 1]; x2SimC1[:, 2, 1]; x2SimC1[:, 3, 1]],
        x1SimU1s = [x1SimU1[:, 1, 1]; x1SimU1[:, 2, 1]; x1SimU1[:, 3, 1]],
        x2SimU1s = [x2SimU1[:, 1, 1]; x2SimU1[:, 2, 1]; x2SimU1[:, 3, 1]],
        x1SimC1c = [x1SimC1[:, 1, 2]; x1SimC1[:, 2, 2]; x1SimC1[:, 3, 2]],
        x2SimC1c = [x2SimC1[:, 1, 2]; x2SimC1[:, 2, 2]; x2SimC1[:, 3, 2]],
        x1SimU1c = [x1SimU1[:, 1, 2]; x1SimU1[:, 2, 2]; x1SimU1[:, 3, 2]],
        x2SimU1c = [x2SimU1[:, 1, 2]; x2SimU1[:, 2, 2]; x2SimU1[:, 3, 2]],
        z         = [zSim; zSim; zSim],
        t         = [fill(1, S); fill(2, S); fill(3, S)],
        prai      = [collect(1:S); collect(1:S); collect(1:S)]
    )
end

# ======================================================================
# Main routine
# ======================================================================

for verEta in 1:length(GRID_ETA)
    for verSigma in 1:length(GRID_SIGMA)
        for verDelta in 1:length(GRID_DELTA)
            eta = GRID_ETA[verEta]
            sigma = GRID_SIGMA[verSigma]
            delta_abs = GRID_DELTA[verDelta]

            yy1, yy2, yyU1, yyU2 = compute_policy_rules(eta, sigma, delta_abs)
            df = simulate_panel(yy1, yy2, yyU1, yyU2)

            n = nrow(df)
            df[!, :eta] = fill(eta, n)
            df[!, :sigma] = fill(sigma, n)
            df[!, :delta] = fill(delta_abs, n)

            output_file = joinpath(SIMUL_DIR, string("simulations", verEta, verSigma, verDelta, ".csv"))
            CSV.write(output_file, df)
            println("Saved ", output_file)
        end
    end
end

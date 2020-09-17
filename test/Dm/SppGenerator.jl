import Random

struct VariableIndex
    value::Int64
end

struct ConstraintIndex
    value::Int64
end

const CI = ConstraintIndex
const VI = VariableIndex

function chooseNbVar(L::Vector{Float64})
    x::Float64 = rand()

    if x < L[1]
        return 2
    elseif x+L[1] < L[2]
        return 3
    else
        return 4
    end
end

# Idée comme structure de donnée : comme données en entrée !

function generate(nbrVar::Int64, nbrConst::Int64)
    c::Dict{VI, Int64} = Dict( VI(ind) => Random.rand(1:28) for ind in 1:nbrVar)
    # Mbis::Array{Int64, 2} = zeros(Int, nbrConst, nbrVar)
    # Mtris::Dict{VI, Dict{VI, Int64}} = Dict(VI(var) => Dict(VI(varBis) => 0 for varBis = 1:nbrVar) for var = 1:nbrVar)

    M::Dict{CI, Vector{VI}} = Dict()

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # La complexité de ca !
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    # listOccur::Dict{VI, Dict{VI, Int64}} = Dict(VI(var) => Dict(VI(varBis) => 0 for varBis = 1:nbrVar) for var = 1:nbrVar)

    listOccur::Dict{VI, Dict{VI, Int64}} = Dict()
    listLiaison::Dict{VI, Vector{VI}} = Dict()

    occurVar::Dict{VI, Int64} = Dict(VI(var) => 0 for var = 1:nbrVar)

    listProba::Vector{Float64} = [0.75, 0.20, 0.05]

    for ind in 1:nbrConst
        varConst::Int64 = chooseNbVar(listProba)
        ListTirage = []
        for _ in 1:varConst
            var = rand(1:nbrVar)
            while var in ListTirage
                var = rand(1:nbrVar)
            end
            push!(ListTirage, var)
            # Mbis[ind, var] = 1
        end
        # println(ListTirage)
        for var1 in VI.(ListTirage)
            occurVar[var1] += 1
            for var2 in VI.(ListTirage)
                if var1 != var2
                    if !haskey(listOccur, var1)
                        push!(listOccur, var1 => Dict())
                        push!(listLiaison, var1 => [var1])
                    end
                    if !haskey(listOccur[var1], var2)
                        push!(listOccur[var1], var2 => 0)
                        push!(listLiaison[var1], var2)
                    end
                    listOccur[var1][var2] += 1

                end
            end
        end

        push!(M, CI(ind) => VI.(ListTirage))
    end
    return c, M, listOccur, listLiaison, occurVar
    # for indVar = 1:nbrVar
    #     for indConst = 1:nbrConst
    #         if Mbis[indConst, indVar] == 1
    #             for indVarBis = 1:nbrVar
    #                 if Mbis[indConst, indVarBis] == 1 && indVar != indVarBis
    #                     Mtris[VI(indVar)][VI(indVarBis)]+=1
    #                 end
    #             end
    #         end
    #     end
    # end
    # return c, M, Mbis
end

function loadSPP(fname)
    f= open(fname)
    nbConst, nbVar = parse.(Int, split(readline(f)))
    c = parse.(Int, split(readline(f)))
    c = Dict(VI(ind) => c[ind] for ind=1:nbVar)

    # listOccur::Dict{VI, Dict{VI, Int64}} = Dict(var1 => Dict(var1 => 0 for var2 in VI.(1:nbVar)) for var1 in VI.(1:nbVar))
    listOccur::Dict{VI, Dict{VI, Int64}} = Dict()
    listLiaison::Dict{VI, Vector{VI}} = Dict()

    occurVar::Dict{VI, Int64} = Dict(VI(var) => 0 for var = 1:nbVar)
    M::Dict{CI, Vector{VI}} = Dict()

    for ind = 1:nbConst
        readline(f)

        ListTirage = parse.(Int, split(readline(f)))

        # println(ListTirage)
        for var1 in VI.(ListTirage)
            occurVar[var1] += 1
            for var2 in VI.(ListTirage)
                if var1 != var2
                    if !haskey(listOccur, var1)
                        push!(listOccur, var1 => Dict())
                        push!(listLiaison, var1 => [var1])
                    end
                    if !haskey(listOccur[var1], var2)
                        push!(listOccur[var1], var2 => 0)
                        push!(listLiaison[var1], var2)
                    end
                    listOccur[var1][var2] += 1

                end
            end
        end

        push!(M, CI(ind) => VI.(ListTirage))
    end
    return c, M, listOccur, listLiaison, occurVar
end

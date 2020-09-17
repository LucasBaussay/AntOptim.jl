include("SppGenerator.jl")
#
# function profFunction(var::Int64, c::Vector{Int64}, M::Array{Int64, 2})
#     return c[var]/sum(M[:,var])
# end

# function findVariable(c::Vector{Int64}, M::Array{Int64, 2}, nbVar::Int64)
#     varMax = 1
#     maxProf = profFunction(varMax, c, M)
#     for var = 2:nbVar
#         prof = profFunction(var, c, M)
#         if prof > maxProf
#             varMax = var
#             maxProf = prof
#         end
#     end
#     varMax = maxProf == 0 ? -1 : varMax
#     return varMax
# end

# function max(dict::Dict{Any, Int64})
#     valMax = -Inf
#     varMax = -1
#     for pair in dict
#         if pair.second > valMax
#             varMax = pair.first
#             valMax = pair.second
#         end
#     end
#     return (indMax, valMax)
# end

function profFunction(var::VI, c::Dict{VI, Int64}, occur::Dict{VI, Int64})
    return (haskey(c, var) && haskey(occur, var) ? c[var]/occur[var] : -Inf)
end

function findVariable(c::Dict{VI, Int64}, occurVar::Dict{VI, Int64}, variables::Vector{VI})
    varMax = VI(-1)
    valMax = typemin(Float64)
    for var in variables

        val = profFunction(var, c, occurVar)
        if val > valMax
            varMax = var
            valMax = val
        end
    end
    return varMax
end

function z(x::Dict{VI, Int64}, c::Dict{VI, Int64})
    val::Int64 = 0
    for (x_i, b) in x
        val += b*c[x_i]
    end
    return val
end

function heuristic(c::Dict{VI, Int64}, M::Dict{CI, Vector{VI}}, listOccur::Dict{VI, Dict{VI, Int64}}, listLiaison::Dict{VI, Vector{VI}}, occurVar::Dict{VI, Int64})
    nbVar = length(c)
    nbConst = length(M)
    x0::Dict{VI, Int64} = Dict(var => 0 for var=VI.(1:nbVar))
    # relationList::Vector{Vector{Int64}} = Vector{Vector{Int64}}(undef, nbrVar)
    variables = VI.(1:nbVar)
    while variables != []

        x_i = findVariable(c, occurVar, variables)
        filterList::Vector{VI} = haskey(listLiaison, x_i) ? listLiaison[x_i] : [x_i]
        filter!(x -> !(x in filterList), variables)
        x0[x_i] = 1
        # Reduire OccurVar

        for variable in variables
            if haskey(listOccur, variable)
                for pair in listOccur[variable]
                    # println(occurVar[variable])
                    # println(listOccur[variable])
                    # println(listOccur[variable][supprVar])
                    if pair.first in filterList
                        occurVar[variable] -= pair.second
                    end
                end
            end
        end

    end
    x = zeros(nbVar)
    for pair in x0
        x[pair.first.value] = pair.second
    end
    return x, z(x0, c)
end

function heuristic(nbVar::Int64, nbConst::Int64)
    c, M, listOccur, listLiaison, occurVar = generate(nbVar, nbConst)
    return heuristic(c, M, listOccur, listLiaison, occurVar)
end

function heuristic(fname::String)
    c, M, listOccur, listLiaison, occurVar = loadSPP(fname)
    return heuristic(c, M, listOccur, listLiaison, occurVar)
end

    # Faux ! Ecrit ton heuristique sur papier avant de la coder !
function main(fname::String)
    heuristic("Data/test.txt")
    return @time heuristic(fname)
end

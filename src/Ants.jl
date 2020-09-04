module VrpAnt

import Base.empty, Random.rand

# include("Way.jl")
# include("Solution.jl")
# include("Model.jl")
# include("Ant.jl")


# true if it has to stop, otherwise return false
function stopCondition!(model::Model, antList::Vector{Ant}, ind::Int64, stillSame::Int64, NCmax::Int64, stillSameMax::Int64)
    if ind > NCmax
        model.solution.state = NCEnding()
        return true
    elseif ind == 0
        return false
    else
        if stillSame >= stillSameMax
            model.solution.state = NoChangeEnding()
            return true
        elseif reduce( & , [ant.lengthMade ≈ antList[1].lengthMade for ant in antList])
            model.solution.state = AntEnding()
            return true
        else
            return false
        end
    end
end


function updateSolution!(model::Model, stillSame::Int64, antList::Vector{Ant})
    bestAnt::Ant = searchBestAnt(antList)

    if bestAnt.lengthMade < model.solution.length
        model.solution.path = bestAnt.way
        model.solution.length = bestAnt.lengthMade
        return 0
    else
        return stillSame+1
    end
end


function optimize(map::Map; m::Union{Nothing, Int64} = nothing, p::Float64 = 0.5, α::Real = 3, β::Real = 1, Q::Real = 100, NCmax::Int64 = 5000, stillSameMax::Int64 = 50, pheroInit::Float64 = 1.)
    model::Model = Model(map, pheroInit)
    m == nothing ? _optimize!(model, length(map.cities), p, α, β, Q, NCmax, stillSameMax) : _optimize!(model, m, p, α, β, Q, NCmax, stillSameMax)
    return model
end

function optimize!(model::Model; m::Union{Nothing, Int64} = nothing, p::Float64 = 0.5, α::Real = 3, β::Real = 1, Q::Real = 100, NCmax::Int64 = 5000, stillSameMax::Int64 = 50, pheroInit::Float64 = 1.)
    m == nothing ? _optimize!(model, length(map.cities), p, α, β, Q, NCmax, stillSameMax) : _optimize!(model, m, p, α, β, Q, NCmax, stillSameMax)
    return model
end

#Change about the model !!!!!!!!!

function _optimize!(model::Model, m::Int64, p::Float64, α::Real, β::Real, Q::Real, NCmax::Int64, stillSameMax::Int64)
    antList::Vector{Ant} = [Ant(model.map.cities) for loop = 1:m]
    ind::Int64 = 0
    stillSame::Int64 = 0

    while !stopCondition!(model, antList, ind, NCmax, stillSame, stillSameMax)

        if ind != 0
            sort!(antList, by = ant -> ant.lengthMade)

            for ant in antList[1:Int(ceil(0.1*m))]
                wayBack!(model, ant, Q)
            end
        end
        updatePhero!(model, p)
        for ant in antList
            round!(ant, model, α, β)
        end

        ind+=1
        stillSame = updateSolution!(model, stillSame, antList)
    end

    return model
end

export optimize!, Map, display, optimize, Model

end  # module

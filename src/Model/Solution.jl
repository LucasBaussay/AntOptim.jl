abstract type SolutionState end

struct AntEnding <: SolutionState end

struct NCEnding <: SolutionState end

struct InProgress <: SolutionState end

struct NoChangeEnding <: SolutionState end

mutable struct Solution

    path::Vector{City}
    length::Real

    usedTime::Float64
    usedSpace::Float64

    state:: SolutionState

end # struct

function Solution()
    return Solution(Vector{City}(), Inf, 0., 0., InProgress())
end

#Taille des chemins proportionnels aux Phéromones

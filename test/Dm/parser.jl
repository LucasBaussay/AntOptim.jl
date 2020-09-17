struct Problem
    C::Vector{Int64}
    A::Union{Vector{Vector{Int64}}, Array{Int64, 2}}
end

struct Solution
    x::BitArray
    z::Int64
end

function loadSPP(fname)
    f=open(fname)
    # lecture du nbre de contraintes (m) et de variables (n)
    m, n = parse.(Int, split(readline(f)) )
    # lecture des n coefficients de la fonction economique et cree le vecteur d'entiers c
    C = parse.(Int, split(readline(f)) )
    # lecture des m contraintes et reconstruction de la matrice binaire A
    #A=Vector{Vector{Int64}}(undef, m )
    A = Array{Int64, 2}(undef, m, n)
    for i=1:m
        # lecture du nombre d'elements non nuls sur la contrainte i (non utilise)
        nbVarConst = parse(Int, readline(f))
        A[i] = Vector{Int64}(undef, nbVarConst)
        # lecture des indices des elements non nuls sur la contrainte i
        line = parse.(Int, split(readline(f)))
        # for ind in 1:nbVarConst
        #     A[i][ind] = line[ind]
        # end
        for var in line
            A[i, var] = 1
        end
    end
    close(f)
    return Problem(C, A)
end

function calculUtil(var::Int64, problem::Problem)
    prof::Int64 = problem.C[var]
    nbOccur::Int64 = sum(problem.A[:, var])
    return prof/(nbOccur)^0.5
end


function findVariable(variables::Vector{Int64}, problem::Problem)::Int64
    var0 = -1
    utilMax = -Inf
    for var in variables
        util = calculUtil(var, problem)
        if util > utilMax
            var0 = var
            utilMax = util
        end
    end
    return var0
end

function gloutonBasique(fname)
    problem = loadSPP(fname)
    nbVar::Int64 = length(problem.C)

    variables::Vector{Int64} = 1:nbVar

    x::BitArray = BitArray(undef, nbVar)
    z::Int64 = 0

    nbVariableLibre = length(variables)
    while nbVariableLibre != 0
        x_i = findVariable(variables, problem)
        x[x_i] = 1
        filterList = 

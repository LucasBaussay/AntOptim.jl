struct Problem
    C::Vector{Int64} # Vecteur des pofits de chaque variables
    A::Union{Vector{Vector{Int64}}, Array{Int64, 2}} # Matrice creuse/Liste d'adgacence des contraintes

    #Donées annexes

	nbVar::Int64
	nbConst::Int64
	equalWeights::Bool

    listOccur::Array{Int64, 2}
    occurVar :: Vector{Int64} # Nombre de variable que chaque variable penalise
    occurConst::Vector{Int64} #Nombre de fois qu'une variable apparait  dans une contraintes
end

function Problem(fname::String = "Data/test.txt")::Problem

	    f=open(fname)

	    # lecture du nbre de contraintes (m) et de variables (n)
	    m, n = parse.(Int, split(readline(f)) )

	    # lecture des n coefficients de la fonction economique et cree le vecteur d'entiers c
	    C = parse.(Int, split(readline(f)) )

		# Savoir si tout les profits sont égaux ou non
		equalWeights::Bool = true
		for var = 1:n
			equalWeights = equalWeights && (C[var] == C[1])
		end

	    # lecture des m contraintes et reconstruction de la matrice binaire A
	    A = zeros(Int64, m, n)

		# Matrice décrivant la corrélation entre les variables
	    listOccur = zeros(Int64, n, n)

		# Liste du nombre de variable correlée à une variable
	    occurVar = zeros(Int64, n)

		# Liste du nombre de contraintes où apparaissent une variable
	    occurConst = zeros(Int64, n)


	    for i=1:m
	        # lecture du nombre d'elements non nuls sur la contrainte i (non utilise)
	        nbVarConst = parse.(Int, split(readline(f)))

	        # lecture des indices des elements non nuls sur la contrainte i
	        line = parse.(Int, split(readline(f)))

	        for var in line
	            A[i, var] = 1
	            occurConst[var] += 1
	            for var2 in line
	                listOccur[var, var2] = 1
	                occurVar[var] += 1
	            end
	        end
	    end
	    close(f)

	    return Problem(C, A, n, m, equalWeights, listOccur, occurVar, occurConst)
end

struct Solution
    x::Vector{Int64}
    z::Int64

	# Données annexes

	var1::Vector{Int64} # Indice des variables misent à 1
	var0::Vector{Int64} # Indice des variables misent à 0

	nbVarLibre::Int64
	estLibre::BitArray
end

function Solution(x::Vector{Int64}, z:: Int64, estLibre::BitArray)::Solution
	nbVar::Int64 = length(x)

	num1 = sum(x)
	var1 = Vector{Int64}(undef, num1)
	var0 = Vector{Int64}(undef, nbVar-num1)

	num0 = 0
	num1 = 0
	for ind = 1:length(x)
		if x[ind] == 0
			num0 += 1
			var0[num0] = ind
		else
			num1 += 1
			var1[num1] = ind
		end
	end

	nbVarLibre::Int64 = 0
	for ind = 1:nbVar
		if estLibre[ind] == 1
			nbVarLibre += 1
		end
	end
	return Solution(x, z, var1, var0, nbVarLibre, estLibre)
end

import Base.copy

function Base.copy(sol::Solution)::Solution
	return Solution(
		copy(x),
		z,
		copy(var1),
		copy(var0),
		nbVarLibre,
		copy(estLibre)
	)
end

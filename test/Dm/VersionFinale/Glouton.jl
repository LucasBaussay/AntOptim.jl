function calculUtil(var::Int64, x::Vector{Int64}, prob::Problem)
	return prob.C[var]^3 / (prob.occurConst[var])
end

function findVariable(x::Vector{Int64}, prob::Problem)::Int64
	varMax::Int64 = -1
	utilMax::Float64 = -Inf

	for var = 1:prob.nbVar
		if x[var] == -1
			util = calculUtil(var, x, prob)
			if util > utilMax
				varMax = var
				utilMax = util
			end
		end
	end
	return varMax
end

function glouton(prob::Problem)::Solution

	estLibre::BitArray = trues(prob.nbVar)

	x::Vector{Int64} = Vector{Int64}(undef, prob.nbVar)
	for ind = 1:prob.nbVar
		x[ind] = -1
	end

	z::Int64 = 0

	nbVarLibre::Int64 = prob.nbVar
	while nbVarLibre > 0
		varAdd = findVariable(x, prob)

		x[varAdd] = 1
		estLibre[varAdd] = false
		nbVarLibre -= 1

		z += prob.C[varAdd]

		for varBloque = 1:prob.nbVar
			if prob.listOccur[varAdd, varBloque] == 1 && x[varBloque] == -1
				x[varBloque] = 0
				estLibre[varBloque] = false
				nbVarLibre -= 1
			end
		end
	end
	return Solution(x, z, estLibre)

end

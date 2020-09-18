struct Problem
    C::Vector{Int64} # Vecteur des pofits de chaque variables
    A::Union{Vector{Vector{Int64}}, Array{Int64, 2}} # Matrice creuse/Liste d'adgacence des contraintes

    #Donées annexes

    listOccur::Array{Int64, 2}
    occurVar :: Vector{Int64} # Nombre de variable que chaque variable penalise
    occurConst::Vector{Int64} #Nombre de fois qu'une variable apparait  dans une contraintes
end

struct Solution
    x::Vector{Int64}
    z::Int64

	# Données annexes

	var1::Vector{Int64} # Indice des variables misent à 1
	var0::Vector{Int64} # Indice des variables misent à 0
end

function Solution(x::Vector{Int64}, z::Int64)
	num1 = sum(x)
	var1 = Vector{Int64}(undef, num1)
	var0 = Vector{Int64}(undef, length(x)-num1)

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
	return Solution(x, z, var1, var0)
end

function loadSPP(fname)
    f=open(fname)
    # lecture du nbre de contraintes (m) et de variables (n)
    m, n = parse.(Int, split(readline(f)) )
    # lecture des n coefficients de la fonction economique et cree le vecteur d'entiers c
    C = parse.(Int, split(readline(f)) )
    # lecture des m contraintes et reconstruction de la matrice binaire A
    #A=Vector{Vector{Int64}}(undef, m )
    # A = Array{Int64, 2}(undef, m, n)
    A = zeros(Int64, m, n)
    listOccur = zeros(Int64, n, n)
    occurVar = zeros(Int64, n)
    occurConst = zeros(Int64, n)

    for i=1:m
        # lecture du nombre d'elements non nuls sur la contrainte i (non utilise)
        nbVarConst = parse.(Int, split(readline(f)))
        # A[i] = Vector{Int64}(undef, nbVarConst[1])
        # lecture des indices des elements non nuls sur la contrainte i
        line = parse.(Int, split(readline(f)))
        # for ind in 1:nbVarConst
        #     A[i][ind] = line[ind]
        # end
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
    return Problem(C, A, listOccur, occurVar, occurConst)
end

function calculUtil(var::Int64, problem::Problem, x::Vector{Int64})
	util = undef
	if x[var] != -1
		util = -Inf
	else
		prof::Int64 = problem.C[var]
		nbOccur::Int64 = problem.occurConst[var]
		util = prof/(nbOccur)^0.5
	end
	return util
end


function findVariable(x::Vector{Int64}, problem::Problem)::Int64
    var0 = -1
    utilMax = -Inf
    for var = 1:length(x)
        util = calculUtil(var, problem, x)
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

    x::Vector{Int64} = zeros(Int64, nbVar)
    for ind = 1:nbVar
    	x[ind] = -1
    end
    z::Int64 = 0

	nbVariablesLibre = nbVar

    while nbVariablesLibre > 0
        x_i = findVariable(x, problem)
        x[x_i] = 1
        nbVariablesLibre -= 1
        z += problem.C[x_i]
        filterList = []
        for ind = 1:nbVar
            if problem.listOccur[x_i, ind] == 1 && x[ind] == -1
                x[ind] = 0
                nbVariablesLibre -= 1
            end
        end
    end
    return Solution(x, z)
end

function getfname(target)
    # target : string := chemin + nom du repertoire ou se trouve les instances

    # positionne le currentdirectory dans le repertoire cible
    cd(joinpath(homedir(),target))

    # recupere tous les fichiers se trouvant dans le repertoire data
    allfiles = readdir()

    # vecteur booleen qui marque les noms de fichiers valides
    flag = trues(size(allfiles))

    k=1
    for f in allfiles
        # traite chaque fichier du repertoire
        if f[1] == "."
            # fichier cache => supprimer
            flag[k] = false
        end
        k = k+1
    end

    # extrait les noms valides et retourne le vecteur correspondant
    finstances = allfiles[flag]
    return finstances
end

function main()
    gloutonBasique("Data/test.txt")
    fnames = getfname("/home/lucas/Bureau/Dm/Data")
	for fname in fnames
		print("File : "*fname*" -> ")
		sol = gloutonBasique(fname)
		println(sol.z)
	end
end


function exchangeK1(x::Vector{Int64}, z::Int64, var0::Vector{Int64}, var1::Vector{Int64}, prob::Problem, k::Int64)
	#A chaque appel de cette fonction p = 1
	varPossible = Vector{Int64}(undef, length(x))
	indPossible = 1

	permut::Vector{Tuple{Int64, Int64, Int64}} = Vector(undef, length(var0) * length(var1)*(length(var1)-1))
	indPermut = 1

	for ind0 in var0
		indPossible = 1
		for var = 1:length(x)
			if prob.listOccur[ind0,var] == 1
				varPossible[indPossible] = var
				indPossible += 1
			end
		end
		for ind = 1:indPossible
			for indBis = 1:indPossible
				if prob.listOccur[ind, indBis] == 0
					permut[indPermut] = [ind, indBis, ind0]
				end
			end
		end
	end
	return permut
end

function amelioration(sol::Solution, prob::Problem)
	chgt::Bool = true
	chgt21::Bool = true
	chgt11::Bool = true
	chgt10::Bool = true
	x, z, var0, var1 = sol.x, sol.z, sol.var0, sol.var1
	nbchgt21 = 0
	nbchgt11 = 0
	nbchgt10 = 0

	while chgt
		chgt = false
		# nbchgt21 = 0
		while chgt21
			chgt21 = true
			newX, newZ = exchangeKp(x, z, var0, var1, prob, 2,1)
			if z!=newZ
				x = newX
				z = newZ
			else
				chgt21 = false
			end
			# nbchgt21+=1
		end
		nbchgt11 = 0
		while chgt11
			chgt11 = true
			newX, newZ = exchangeKp(x, z, var0, var1, prob, 1, 1)
			if z!=newZ
				x = newX
				z = newZ
			else
				chgt11 = false
			end
			nbchgt11 +=1
		end
		nbchgt10 = 0
		while chgt10
			chgt10 = true
			newX, newZ = exchangeKp(x, z, var0, var1, prob, 1, 0)
			if z!=newZ
				x = newX
				z = newZ
			else
				chgt10 = false
			end
			nbchgt10 += 1
		end

		if nbchgt11 + nbchgt10 == 2
			chgt = false
		end
	end
	return Solution(x, z)
end

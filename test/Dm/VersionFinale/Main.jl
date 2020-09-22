include("DataStruct.jl")
include("Glouton.jl")
include("Exchange.jl")
include("Amelioration.jl")

function main()
	pbInit::Problem = Problem("Data/test.txt")
	solInit::Solution = glouton(pbInit)
	solInit = amelioration(solInit, pbInit)

	fnames = getfname("Data")

	for fname in fnames
		prob::Problem = Problem("Data/"*fname)

		# println("File : "*fname*" -> ")
		# print("			| Time : ")
		sol = glouton(prob)
		# println("		| z = "*string(sol.z))
		# print( "		| Time : ")
		newSol = amelioration(sol, prob)
		# println("		| z = "*string(newSol.z))
		println("Neeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeew")

	end
end

function getfname(target::String = "Data")
    # target : string := chemin + nom du repertoire ou se trouve les instances

    # recupere tous les fichiers se trouvant dans le repertoire data
    allfiles = readdir(target)

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

function evalZ(sol, prob)
	z = 0
	for ind = 1:length(sol.x)
		z+=sol.x[ind] * prob.C[ind]
	end
	return z
end

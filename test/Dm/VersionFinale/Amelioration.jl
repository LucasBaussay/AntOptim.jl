function amelioration(sol::Solution, prob::Problem)::Solution
    chgt::Bool = true

    chgt21::Bool = true
	chgt12::Bool = true
    chgt11::Bool = true
    chgt01::Bool = true

	nbChgt::Int64 = 0

	nbChgt21::Int64 = 0
	nbChgt12::Int64 = 0
	nbChgt11::Int64 = 0
	nbChgt01::Int64 = 0

    #while chgt

		chgt = false
		nbChgt += 1

		nbChgt21 = 0
		nbChgt12 = 0
		nbChgt11 = 0
		nbChgt01 = 0

		@time while chgt21
			sol, chgt21 = exchange21(sol, prob)
			nbChgt21 += 1
		end
		# println("nbChgt21 -> ", nbChgt21)
        @time while chgt12
			sol, chgt12 = exchange12(sol, prob)
			nbChgt12 += 1
			if chgt12
				chgt = true
			end
		end
		# println("nbChgt12 -> ", nbChgt12)
		@time if !prob.equalWeights
			while chgt11
				sol, chgt11 = exchange11(sol, prob)
				nbChgt11 += 1
				if chgt11
					chgt = true
				end
			end
		end
		# println("nbChgt11 -> ", nbChgt11)
		@time if sol.nbVarLibre != 0
			while chgt01
				sol, chgt01 = exchange01(sol, prob)
				nbChgt01 += 1
				if chgt01
					chgt = true
				end
			end
		end
		# println("nbChgt01 -> ", nbChgt01)
	# end
	return sol
end

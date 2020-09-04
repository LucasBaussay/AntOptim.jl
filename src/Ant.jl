# Attention changement de patrmaetre a vérifier sur tout les appels

mutable struct Ant

	way::Vector{City}
	lengthMade::Float64
	notWay::Vector{City}

end

function Ant(cities::Vector{City})

	ant = Ant(Vector{City}(), 0., cities[:])

	city = rand(cities)

	push!(ant.way, city)
	filter!(notCity -> notCity != city, ant.notWay)

	return ant

end


# Find how to empty ant.way
function empty!(ant::Ant, cities::Vector{City})

	firstCity::City = ant.way[1]
	ant.way = Vector{City}()
	push!(ant.way, firstCity)

	ant.lengthMade = 0.
	ant.notWay = filter(city -> city != firstCity, cities)

	return ant

end

function addCity!(ant::Ant, city::City, way::Way)

	push!(ant.way, city)
	ant.lengthMade += way.length
	filter!(notCity -> notCity != city, ant.notWay)

end

function calcTotal(city::City, nextCities::Vector{City}, model::Model, α::Real, β::Real)

	total::Float64 = 0.

	for nextCity in nextCities
		way = model.ways[city.index][nextCity.index]

		total += way.pheromone^α * way.length^(-β)
	end

	return total

end

function calcProba(ant::Ant, way::Way, total::Float64, α::Real, β::Real)
	return way.pheromone^α * way.length^(-β) / total
end

# TODO : Make that code clearer WITH SOME SUB FUNCTIONS
# Find why the sum(listProba) is not equal to 1. but sometimes 0.04 and other time 4.98
# This is a complete mess xD

function chooseCity(model::Model, ant::Ant, α::Real, β::Real)

	city::City = ant.way[length(ant.way)]
	# dictProba::Dict{City, Float64} = Dict{City, Float64}()

	ways::Dict{CityIndex, Way} = model.ways[city.index]
	total::Float64 = calcTotal(city, ant.notWay, model, α, β)

	listProba = Vector{Float64}()
	sumProba = 0.

	indCity = 1

	for potentialCity in ant.notWay

		way = model.ways[city.index][potentialCity.index]
		proba = calcProba(ant, way, total, α, β)

		push!(listProba, proba)
	end

	rand = Random.rand()*sum(listProba)

	maxProba::Float64 = listProba[1]
	nextCity = ant.notWay[1]
	nextWay = model.ways[city.index][nextCity.index]

	# while rand > sumProba && indCity < length(ant.notWay)
	# 	sumProba += listProba[indCity]
	# 	indCity += 1
	# end
	for ind = 2:length(listProba)
		if listProba[ind]>maxProba
			nextCity = ant.notWay[ind]
			nextWay = model.ways[city.index][nextCity.index]
			maxProba = listProba[ind]
		end
	end

	return nextCity, nextWay
end

# TODO : Find how tu use the macro correctly

function round!(ant::Ant, model::Model, α::Real, β::Real)
	empty!(ant, model.map.cities)
	nbVille = length(model.map.cities)
	for ind = 1:nbVille-1
		nextCity, nextWay = chooseCity(model, ant, α, β)
		addCity!(ant, nextCity, nextWay)

	end
	firstCity = ant.way[1]
	lastCity = ant.way[length(ant.way)]

	way = model.ways[lastCity.index][firstCity.index]

	addCity!(ant, firstCity, way)
	return ant

end

function wayBack!(model::Model, ant::Ant, Q::Real)

	for idTown = 1:length(ant.way)-1
		city = ant.way[idTown]
		nextCity = ant.way[idTown+1]

		way = model.ways[city.index][nextCity.index]

		way.pheromone += Q/ant.lengthMade
	end
	# firstCity = ant.way[1]
	# lastCity = ant.way[length(ant.way)]
	#
	# if firstCity.index < lastCity.index
	# 	way = map.ways[firstCity][lastCity]
	# else
	# 	way = map.ways[lastCity][firstCity]
	# end
	#
	# way.pheromone += Q/ant.lengthMade

end

function searchBestAnt(antList::Vector{Ant})
	bestAnt::Ant = antList[1]
	for ant in antList
		if ant.lengthMade < bestAnt.lengthMade
			bestAnt = ant
		end
	end
	return bestAnt
end

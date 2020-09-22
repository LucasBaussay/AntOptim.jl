function condition12(varDel::Int64, varAdd1::Int64, varAdd2::Int64, sol::Solution, prob::Problem)::Bool

    test1 = true
    test2 = true

    for var = 1:prob.nbVar
        if !(prob.listOccur[varAdd1, var] == 0 || sol.x[var] == 0 ||  var == varDel)
            test1 = false
        end
        if !(prob.listOccur[varAdd2, var] == 0 || sol.x[var] == 0 || var == varDel)
            test2 = false
        end
    end

    return test1 && test2 && prob.listOccur[varAdd1, varAdd2] == 0
end

function condition21(varDel1::Int64, varDel2::Int64, varAdd::Int64, sol::Solution, prob::Problem)

    test = true

    for var = 1:prob.nbVar

        if !(prob.listOccur[varAdd, var] == 0 || sol.x[var] == 0 || var == varDel1 || var == varDel2)
            test = false
        end

    end

    return test
end

function condition11(varDel::Int64, varAdd::Int64, sol::Solution, prob::Problem)::Bool

    test = true

    for var = 1:prob.nbVar
        if !(prob.listOccur[varAdd, var] == 0 || sol.x[var] == 0 || var == varDel)
            test = false
        end
    end

    return test
end

function condition01(varAdd::Int64, sol::Solution, prob::Problem)::Bool
    return sol.estLibre[varAdd]
end

function exchange12(sol::Solution, prob::Problem)

    varsMax::Tuple{Int64, Int64, Int64} = (-1, -1, -1)
    zMax = sol.z
    xMax = copy(sol.x)
    estLibreMax = copy(sol.estLibre)

    change::Bool = false

    for varDel in sol.var1

        for varAdd1 in sol.var0
            for varAdd2 in sol.var0
                if condition12(varDel, varAdd1, varAdd2, sol, prob)
                    if sol.z + prob.C[varAdd1] + prob.C[varAdd2] - prob.C[varDel] > zMax

                        zMax = sol.z + prob.C[varAdd1] + prob.C[varAdd2] - prob.C[varDel]
                        varsMax = (varDel, varAdd1, varAdd2)
                        change = true

                        varDel, varAdd1, varAdd2 = varsMax

                        xMax[varDel] = 0
                        xMax[varAdd1] = 1
                        xMax[varAdd2] = 1
                        for var in sol.var0
                            if sol.estLibre[var]
                                estLibreMax[var] = !(prob.listOccur[var, varAdd1] == 1 || prob.listOccur[var, varAdd2] == 1)
                            else
                                if prob.listOccur[var, varDel] == 1
                                    estLibreMax[var] = !(prob.listOccur[var, varAdd1] == 1 || prob.listOccur[var, varAdd2] == 1)
                                end
                            end
                        end
                        estLibreMax[varAdd1] = false
                        estLibreMax[varAdd2] = false
                        estLibreMax[varDel] = !(prob.listOccur[varDel, varAdd1] == 1 || prob.listOccur[varDel, varAdd2] == 1)

                        return Solution(xMax, zMax, estLibreMax), change

                    end
                end
            end
        end
    end
    return sol, false
    # if change
    #     println(varsMax)
    #     varDel, varAdd1, varAdd2 = varsMax
    #
    #     xMax[varDel] = 0
    #     xMax[varAdd1] = 1
    #     xMax[varAdd2] = 1
    #     for var in sol.var0
    #         if sol.estLibre[var]
    #             estLibreMax[var] = !(prob.listOccur[var, varAdd1] == 1 || prob.listOccur[var, varAdd2] == 1)
    #         else
    #             if prob.listOccur[var, varDel] == 1
    #                 estLibreMax[var] = !(prob.listOccur[var, varAdd1] == 1 || prob.listOccur[var, varAdd2] == 1)
    #             end
    #         end
    #     end
    #     estLibreMax[varAdd1] = false
    #     estLibreMax[varAdd2] = false
    #     estLibreMax[varDel] = !(prob.listOccur[varDel, varAdd1] == 1 || prob.listOccur[varDel, varAdd2] == 1)
    # end
    # return Solution(xMax, zMax, estLibreMax), change
end

function exchange21(sol::Solution, prob::Problem)
    varsMax::Tuple{Int64, Int64, Int64} = (-1, -1, -1) # (varDel1, varDel2, varAdd)
    zMax = sol.z
    xMax = copy(sol.x)
    estLibreMax = copy(sol.estLibre)

    change::Bool = false

    for indVarDel1 = 1:length(sol.var1)
        varDel1 = sol.var1[indVarDel1]
        for indVarDel2 = indVarDel1:length(sol.var1)
            varDel2 = sol.var1[indVarDel2]

            for indVarAdd = 1:length(sol.var0)
                varAdd = sol.var0[indVarAdd]
                if condition21(varDel1, varDel2, varAdd, sol, prob)
                    if sol.z + prob.C[varAdd] - prob.C[varDel1] - prob.C[varDel2] > zMax

                        zMax = sol.z + prob.C[varAdd] - prob.C[varDel1] - prob.C[varDel2]
                        varsMax = (varDel1, varDel2, varAdd)
                        change = true

                        xMax[varDel1] = 0
                        xMax[varDel2] = 0
                        xMax[varAdd] = 1
                        for var in sol.var0
                            if sol.estLibre[var]
                                estLibreMax[var] = !(prob.listOccur[var, varAdd] == 1 )
                            else
                                if prob.listOccur[var, varDel1] == 1 || prob.listOccur[var, varDel2] == 1
                                    estLibreMax[var] = !(prob.listOccur[var, varAdd] == 1 )
                                end
                            end
                        end
                        estLibreMax[varAdd] = false
                        estLibreMax[varDel1] = !(prob.listOccur[varDel1, varAdd] == 1 )
                        estLibreMax[varDel2] = !(prob.listOccur[varDel2, varAdd] == 1 )


                        return Solution(xMax, zMax, estLibreMax), change

                    end
                end
            end
        end
    end
    return sol, false
    # if change
    #     varDel1, varDel2, varAdd = varsMax
    #
    #     xMax[varDel1] = 0
    #     xMax[varDel2] = 0
    #     xMax[varAdd] = 1
    #     for var in sol.var0
    #         if sol.estLibre[var]
    #             estLibreMax[var] = !(prob.listOccur[var, varAdd] == 1 )
    #         else
    #             if prob.listOccur[var, varDel1] == 1 || prob.listOccur[var, varDel2] == 1
    #                 estLibreMax[var] = !(prob.listOccur[var, varAdd] == 1 )
    #             end
    #         end
    #     end
    #     estLibreMax[varAdd] = false
    #     estLibreMax[varDel1] = !(prob.listOccur[varDel1, varAdd] == 1 )
    #     estLibreMax[varDel2] = !(prob.listOccur[varDel2, varAdd] == 1 )
    # end
    # return Solution(xMax, zMax, estLibreMax), change
end

function exchange11(sol::Solution, prob::Problem)
    varsMax::Tuple{Int64, Int64} = (-1, -1)
    zMax = sol.z
    xMax = copy(sol.x)
    estLibreMax = copy(sol.estLibre)

    change::Bool = false

    for varDel in sol.var1

        for varAdd in sol.var0
            if condition11(varDel, varAdd, sol, prob)
                if sol.z + prob.C[varAdd] - prob.C[varDel] > zMax

                    zMax = sol.z + prob.C[varAdd] - prob.C[varDel]
                    varsMax = (varDel, varAdd)
                    change = true

                    xMax[varDel] = 0
                    xMax[varAdd] = 1
                    for var in sol.var0
                        if sol.estLibre[var]
                            estLibreMax[var] = !(prob.listOccur[var, varAdd] == 1)
                        else
                            if prob.listOccur[var, varDel] == 1
                                estLibreMax[var] = !(prob.listOccur[var, varAdd] == 1)
                            end
                        end
                    end
                    estLibreMax[varAdd] = false
                    estLibreMax[varDel] = !(prob.listOccur[varDel, varAdd] == 1)

                    return Solution(xMax, zMax, estLibreMax), change
                end
            end
        end
    end
    return sol, false
    # if change
    #     varDel, varAdd = varsMax
    #
    #     xMax[varDel] = 0
    #     xMax[varAdd] = 1
    #     for var in sol.var0
    #         if sol.estLibre[var]
    #             estLibreMax[var] = !(prob.listOccur[var, varAdd] == 1)
    #         else
    #             if prob.listOccur[var, varDel] == 1
    #                 estLibreMax[var] = !(prob.listOccur[var, varAdd] == 1)
    #             end
    #         end
    #     end
    #     estLibreMax[varAdd] = false
    #     estLibreMax[varDel] = !(prob.listOccur[varDel, varAdd] == 1)
    # end
    # return Solution(xMax, zMax, estLibreMax), change
end

function exchange01(sol::Solution, prob::Problem)

    varMax::Int64 = -1
    zMax = sol.z
    xMax = copy(sol.x)
    estLibreMax = copy(sol.estLibre)

    change::Bool = false


    for varAdd in sol.var0
        if condition01(varAdd, sol, prob)
            if sol.z + prob.C[varAdd] > zMax

                zMax = sol.z + prob.C[varAdd]
                varMax = varAdd
                change = true


                xMax[varAdd] = 1
                for var in sol.var0
                    if sol.estLibre[var]
                        estLibreMax[var] = (prob.listOccur[var, varAdd] == 0)
                    end
                end

                estLibreMax[varAdd] = false
                return Solution(xMax, zMax, estLibreMax), change
            end
        end
    end
    return sol, false

    # if change
    #     varAdd = varMax
    #
    #     xMax[varAdd] = 1
    #     for var in sol.var0
    #         if sol.estLibre[var]
    #             estLibreMax[var] = (prob.listOccur[var, varAdd] == 0)
    #         end
    #     end
    #
    #     estLibreMax[varAdd] = false
    # end
    # return Solution(xMax, zMax, estLibreMax), change
end

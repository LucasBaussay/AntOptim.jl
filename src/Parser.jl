function parser(m::JuMP.Model)
    variable_list = JuMP.all_variables(m)
    @assert all(v -> JuMP.has_lower_bound(v) && JuMP.has_upper_bound(v), variable_list) "All variables must be bounded"

    for var in variable_list
        lower_bound = JuMP.lower_bound(var)
        upper_bound = JuMP.upper_bound(var)

        scale = upper_bound - lower_bound

        num_created_city::Int64 = Int(ceil(log2(scale)))
end

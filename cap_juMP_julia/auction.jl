module CAP
    using DataStructures, StatsBase, JuMP, HiGHS

    function gen_items(m::Int64)::Vector{String}
        #function generating a vector of m items 
        M = sort(["i_"*string(e) for e in 1:m])
        return M
    end

    function powerset(x::Vector{String})::Vector{Vector{String}}
        #function returning the powerset of a given vector of strings
        result = Vector{String}[[]]
        for elem in x, j in eachindex(result)
            push!(result, [result[j] ; elem])
        end
        popfirst!(result)
        return result
    end
    
    function ps_random_valuation(M::Vector{String}, n_bidders::Int64, subset::Bool=false)::Vector{Dict{Vector, Int64}}

        #function that given a ground set of items, returns n dictionary with a valuation :
        #  1) for each set in powerset(set)
        #    or
        #  2) for m^2 where m=|set|

        #HP: ∀ j in bidders V_j(set) = |set| + random(1:2*|set|)  
        
        valuations = []
        for b in 1:n_bidders
            val = Dict{ Vector{String} , Float64}()
            pwrset = powerset(M)
            if subset==true && size(M)[1]>4
                pwrset = sample(pwrset, size(M)[1]^2, replace=false)
            end
            for set in pwrset
               val[set]= size(set)[1] + rand(1:size(set)[1])
            end
            append!(valuations, [val])   
        end
        return valuations
    
    end

    function winner(valuations::Vector{Dict{Vector, Int64}})::Dict{Vector, Int64}
        #given a vector of valuation, return a single dictionary of with the best bid for each bundle
        if size(valuations)[1]==1
            return valuations[1]
        end
        S = Dict{Vector{String} , Float64}()
        S = DefaultDict(0, S) 
        for v in valuations
            for set in keys(v)
                if v[set] > S[set]
                    S[set] = v[set]
                end  
            end
        end
        return S
    end


    function auction(m::Int64, n::Int64, subset::Bool=false)

        #given a number m of items and n bidders, returns:
        # 1) Ground set M with |M|=m
        # 2) Vector with n valuations from n random sample of [powerset(M)].
        #   perc=0 => 0 sample=∅        perc=0 => sample=[powerset(M)]
        # 3) Best bid for each subset in each valuation

        M = gen_items(m)
        if subset==false
            valuations = ps_random_valuation(M, n)
        else 
            valuations = ps_random_valuation(M, n, true)
        end
        w = winner(valuations)   
        a = 2^m -1 
        b = size(collect(keys(w)))[1]

        println("Total non-empty sets: $a \nNumber of valuations for the ILP:  $b\n")

        return M, valuations, w 
    end

    function cap_solver(M::Vector{String}, S::Dict{Vector, Int64}, optmizer, display::Bool=false)

        ### Solving ILP using JuMP 
        ### HiGHS It uses parallelized 'Dual revised simplex method'

        #model construction
        l = collect(keys(S))
        model = Model(optmizer) 
        if display==false
            set_silent(model)
        end
        @variable(model, x[l] >= 0, Bin)
        @objective(
            model,
            Max,
            sum(S[s] * x[s] for s in l),
        );
        
        for e in M
            V = [s for s in l if e in s]
            intake = @expression(
                model,
                sum(x[subset] for subset in V),
            )
            @constraint(model, intake <= 1)
        end

        #solving  model
        optimize!(model) 

        #model summary
        if display==true
            solution_summary(model)
            println("\nAssigned bundles:\n")
        end

        #checking duplicate in assigned items
        items = [ ]
        for set in l
            if value(x[set]) > 0.9
                if display==true
                    println(set, " = ", round(value(x[set])))
                end
                append!(items, set)
            end
        end

        items=sort(items)
        @assert(items==unique(items))

        model = Nothing

    end
    
   


end
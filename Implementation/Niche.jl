#=====================================================================
# Abstract Niche interface: The structures that populate an Inform.
# In general, a Niche contains a profile of Affordances of
# varying constitution and representation. A Niche might
# represent an individual organism employing a collection of
# Affordances, or a population of individuals, each possessing
# individual Affordances. The important point is that the Niche is
# the enacting interface between Affordances and an Inform.
=====================================================================#
@doc raw"""
	```Niche```

Interface for all Niches
"""
abstract type Niche end

#---------------------------------------------------------------------
@doc raw"""
	```size( niche)```

Size of a Niche is (length,number) of Affordances
"""
function size( niche::Niche)
	(missing,missing)
end

#---------------------------------------------------------------------
@doc raw"""
	```mutate!( niche)```

Mutate the Affordances of this Niche.
"""
function mutate!( niche::Niche)
	missing
end

#---------------------------------------------------------------------
@doc raw"""
    ```recombine!( niche, growth)```

Recombine member Affordances of the Niche based on normalised
growth rates based on evaluations from an external Inform.
"""
function recombine!( niche::Niche, growth::Vector{Float64})
	missing
end

#---------------------------------------------------------------------
@doc raw"""
    ```express( niche)```

Express the Niche's Affordances as a Construction.
"""
function express( niche::Niche)
	missing
end

#---------------------------------------------------------------------
@doc raw"""
    ```show( io, niche)```

Display current status of Niche.
"""
function Base.show( io::IO, pheno::Niche)
	println( missing)
end

#---------------------------------------------------------------------
@doc raw"""
    ```growth!( niche, response)```

Calculate the growth rate associated with each element of a Response
Vector returned by an Enform. growth is a Vector of normalised
frequqencies suitable for roulette-wheel selection.
"""
function growth!( niche::Niche, response::Response)
	missing
end
#=====================================================================
# Abstract Niche interface: The structures that populate an Enform.
# In general, a Niche contains a profile of Affordances of
# varying constitution and representation. A Niche might
# represent an individual organism employing a collection of
# Affordances, or a population of individuals, each possessing
# individual Affordances. The important point is that the Niche is
# the enacting interface between Affordances and an Inform.
# A Niche is the home of all selection/downward stabilisation in a
# rheolectic system.
=====================================================================#
@doc """
	```Niche```

Interface for all Niches
"""
abstract type Niche end

#---------------------------------------------------------------------
@doc """
	```size( niche)```

Size of a Niche is (length,number) of Affordances
"""
function size( niche::Niche)
	(missing,missing)
end

#---------------------------------------------------------------------
@doc """
	```mutate!( niche)```

Mutate the Affordances of this Niche.
"""
function mutate!( niche::Niche)
	missing
end

#---------------------------------------------------------------------
@doc """
    ```recombine!( niche)```

Recombine member Affordances of the Niche based on its current
stabilisation rates determined by evaluations from an external Enform.
"""
function recombine!( niche::Niche)
	missing
end

#---------------------------------------------------------------------
@doc """
    ```explore( niche) -> construction```

Explore the Niche's Affordances as a Construction.
"""
function explore( niche::Niche)
	missing
end

#---------------------------------------------------------------------
@doc """
    ```show( io, niche)```

Display current status of Niche.
"""
function Base.show( io::IO, pheno::Niche)
	println( missing)
end

#---------------------------------------------------------------------
@doc """
    ```stabilise!( niche, response)```

Based on the given Responses from an Enform, calculate the niche's
new stability as a Vector of Float64 frequqencies suitable for
roulette-wheel selection.
"""
function stabilise!( niche::Niche, response)
	missing
end
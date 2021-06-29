module Rheolecsis
#=====================================================================
# Module Rheolecsis:
# The basic definition of a Rheolectic Simulations (RS) that is:
# stabilising, enactive, exploratory and niche-constructing.
=====================================================================#
include("Implementation/Enform.jl")
include("Implementation/Affordance.jl")
include("Implementation/Niche.jl")

using Random:seed!

export Rheolecsim, Enform, Niche, Affordance, Construction, Response
export size, mutate!, recombine!, enact!, construct!, stabilise!
export embed!, testing!

#====================================================================#
@doc raw"""
    ```Rheolecsim```
Abstract interface for all RheolecticSimulations.
"""
abstract type Rheolecsim end

#---------------------------------------------------------------------
@doc raw"""
    ```enact!( niche, enform, nSteps)```

Return the Rheolecsim's niche.
"""
function niche( rs::Rheolecsim)
	missing
end

#---------------------------------------------------------------------
@doc raw"""
    ```enact!( niche, enform, nSteps)```

Return the Rheolecsim's enform.
"""
function enform( rs::Rheolecsim)
	missing
end

#---------------------------------------------------------------------
@doc raw"""
    ```enact!( rs, nSteps)```

Enact the RS's niche through nSteps, using mutation and recombination
according to interaction with the enforming context.
"""
function enact!( rs::Rheolecsim, nSteps::Int)
	# Now run the RS:
	for _ ∈ 1:nSteps
		# Recombine affordances based on niche's current stability:
		recombine!( niche(rs))

		# Mutate niche (if required):
		mutate!( niche(rs))

		# Re-embed the new niche configuration within its enform:
		embed!( niche(rs), enform(rs))
	end
end

#---------------------------------------------------------------------
@doc raw"""
    ```embed!( niche, enform)```

Embed a niche within an enform, thereby setting up the initial
niche-enform configuration, then recording the enform responses and
their associated stabilities.
"""
function embed!( niche::Niche, enform::Enform)
	construction = explore(niche)			# Niche's exploration defines
	response =								# ... its constructions, and
		construct!(enform,construction)		# ... enform responses then
	stabilise!(niche,response)				# ... define its new stability.
end

#---------------------------------------------------------------------
@doc raw"""
    ```testing!(testing)````

Seed the RS's random generator for testing purposes.
"""
function testing!(testing::Bool=true)
	if testing							# Make rng ...
		seed!(5)						# ... determinate ...
	else
		seed!()							# ... or non-determinate
	end
end

end		# ... of module Rheolecsis
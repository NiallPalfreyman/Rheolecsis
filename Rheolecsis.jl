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
export size, arity, mutate!, recombine!, enact!, construct!
export embed!, determinate!, stabilise!, explore

#====================================================================#
@doc """
    ```Rheolecsim```
Abstract interface for all RheolecticSimulations.
"""
abstract type Rheolecsim end

#---------------------------------------------------------------------
@doc """
    ```enact!( niche, enform, nSteps)```

Return the Rheolecsim's niche.
"""
function niche( rs::Rheolecsim)
	missing
end

#---------------------------------------------------------------------
@doc """
    ```enact!( niche, enform, nSteps)```

Return the Rheolecsim's enform.
"""
function enform( rs::Rheolecsim)
	missing
end

#---------------------------------------------------------------------
@doc """
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
@doc """
    ```embed!( niche, enform)```

Embed a niche within an enform to set up the initial niche-enform
configuration, recording the enform responses and the niche's
associated stabilities.
"""
function embed!( niche::Niche, enform::Enform)
	exploration = explore(niche)		# Niche's exploration ...
	response =							# defines its constructions ...
		construct!(enform,exploration)	# and the enform's responses ...
	stabilise!(niche,response)			# then define the new stability.
end

#---------------------------------------------------------------------
@doc """
    ```determinate!(determinate!)````

Seed the RS's random generator for testing purposes.
"""
function determinate!(determinate!::Bool=true)
	if determinate!							# Make rng ...
		seed!(5)						# ... determinate ...
	else
		seed!()							# ... or non-determinate
	end
end

end		# ... of module Rheolecsis
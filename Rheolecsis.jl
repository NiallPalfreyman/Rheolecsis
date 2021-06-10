module Rheolecsis
#=====================================================================
# Module Rheolecsis:
# The basic definition of a Rheolectic Algorithm (RA) that is:
# stabilising, enactive, exploratory and niche-constructing.
=====================================================================#
include("Implementation/Enform.jl")
include("Implementation/Affordance.jl")
include("Implementation/Niche.jl")

export Enform, Niche, Affordance, Construction, Response
export size, mutate!, recombine!, enact!, recombine, construct!
export express

#====================================================================#
@doc raw"""
    ```enact!( niche, enform, nSteps)```

Enact the niche through nSteps, using mutation and recombination
according to interaction with the enforming context.
"""
function enact!( niche::Niche, enform::Enform, nSteps::Int=1)
	for _ ∈ 1:nSteps
		# Create niche's expression profile ...
		profile = express(niche)

		# ... which determines constructions of enform ...
		response = construct!( enform, profile)

		# ... which define niche's stabilities ...
		growth = growth!( niche, response)

		# ... which then define selection pressure on recombination:
		recombine!( niche, growth)

		# Mutate niche (if required)
		mutate!( niche)
	end
end

end		# ... of module Rheolecsis
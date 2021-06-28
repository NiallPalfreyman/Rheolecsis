#=====================================================================
# StringNiche: Niches that display their Affordances as a Vector of
# indices to an alphabet of symbols.
# NOTE: Affordance values run from 0:n-1, whereas Niche
# constructions run from 1:n, since they address characters in strings.
# Therefore, whenever we convert, we must add or subtract 1!
=====================================================================#
stringnicheunittest = false					# Set unit test environment
if stringnicheunittest
	#------------------------- Unit Testing --------------------------
	include("../Rheolecsis.jl")
	include("../Casinos.jl")
	using .Rheolecsis, .Casinos, Random
	using Statistics: mean, std
	include("StringEnform.jl")

	function unittest()
		println("\n============ Unit test StringNiche: ===============")
		println("Create a StringNiche with 5 Affordances of 15 data:")
		niche = StringNiche(5,15)
		display(niche)
		println("... and express them:  $(interpret.(express(niche)))")
		mutate!( niche)
		println("Mutate and re-express: $(interpret.(express(niche)))")
		recombine!( niche, Float64.(1:6))
		println()
		println("Now recombine them:    $(interpret.(express(niche)))")
	end
end

#====================================================================#
@doc raw"""
	```CASINO```

Casino for all mutations and recombinations
"""
const CASINO = Casinos.Casino()

#---------------------------------------------------------------------
@doc raw"""
	```StringNiche```

A very simple Niche that displays Affordances as a Vector of indices
to an alphabet of symbols. Intended only for tutorial purposes.
"""
mutable struct StringNiche <: Rheolecsis.Niche
	affordances::Vector{Affordance}		# A profile of Affordances
	mu::Float64							# Affordance mutation rate
	response::Response					# Current Enform response
	bestresponse::Int					# Index of best response
end

#---------------------------------------------------------------------
@doc raw"""
	```StringNiche( nafford, ndata)```

Construct a StringNiche with nafford Affordances, each containing
ndata data. Estimate mutation rate at 2 per generation.
"""
function StringNiche( nafford::Int, ndata::Int)
	if rem(nafford,2) != 0
		# Ensure nafford is even for our algorithm:
		nafford += 1
	end

	StringNiche(
		[Affordance( ndata, length(ALPHABET)) for _ in 1:nafford],
		2 / (nafford*ndata),
		zeros(nafford) / nafford,
		1
	)
end

#---------------------------------------------------------------------
@doc raw"""
	```StringNiche( prescribe, nafford)```

Construct a StringNiche according to a predefined prescription.
"""
function StringNiche( prescribe, nafford::Int)
	if rem(nafford,2) != 0
		# Ensure nafford is even for our algorithm:
		nafford += 1
	end

	StringNiche(
		[Affordance( prescribe, length(ALPHABET)) for _ in 1:nafford],
		2 / (nafford*length(prescribe)),
		zeros(nafford) / nafford,
		1
	)
end

#---------------------------------------------------------------------
@doc raw"""
	```size( niche)```

Size of a StringNiche is (naffordances,ndata)
"""
function size( niche::StringNiche)
	(length(niche.affordances), length(niche.affordances[1].data))
end

#---------------------------------------------------------------------
@doc raw"""
	```mutate!( niche)```

Mutate all Affordances in this Niche with probability niche.mu.
"""
function Rheolecsis.mutate!( niche::StringNiche)
	if niche.mu <= 0
		return niche
	end
	
	# Find loci to mutate:
	loci = draw( CASINO, size(niche)..., niche.mu)
	
	# Now mutate them:
	for i ∈ 1:length(niche.affordances)
		Rheolecsis.mutate!( niche.affordances[i], loci[i,:])
	end

	niche
end

#---------------------------------------------------------------------
@doc raw"""
    ```recombine!( niche, growth)```

Recombine members of the StringNiche affordances based on normalised
growth rates pre-calculated out of responses from an Enform.
"""
function Rheolecsis.recombine!( niche::StringNiche, growth::Vector{Float64})
	roulette = cumsum( growth)/sum(growth)	# Roulette wheel containing
	nafford, _ = size(niche)				# nchromo repro-biased slots
	# Uniformly distributed ball throws:
	throws = rem.( rand() .+ (1:nafford)./nafford, 1)

	# Choose reproducing couples by throwing ball onto roulette wheel:
	parents = zeros(Integer,nafford)
	for parent in 1:nafford
		for slot in 1:nafford
			if throws[parent] <= roulette[slot]
				parents[parent] = slot
				break
			end
		end
	end
	Random.shuffle!(parents)		# Shuffle the order of parents

	# First half of parents are Mummies; second half are Daddies:
	nMatings = nafford ÷ 2
	mummy = @view niche.affordances[parents[1:nMatings]]
	daddy = @view niche.affordances[parents[nMatings+1:end]]

	# Create next generation:
	progeny = Vector{Affordance}(undef,nafford)
	for m in 1:nMatings
		progeny[m], progeny[m+nMatings] =
				Rheolecsis.recombine( mummy[m], daddy[m])
	end

	# ... and finally replace the old fogeys:
	niche.affordances = progeny
	niche
end

#---------------------------------------------------------------------
@doc raw"""
    ```stabilise!( niche, response) -> stability```

Interpret the response from an Enform construction/expression as
a set of stability conditions on the niche, converting them into a
vector of normalised scores suitable for roulette-wheel selection on
the niche's Affordances.

**Note:** This implementation assumes we wish to *minimise* the response!
"""
function Rheolecsis.stabilise!( niche::StringNiche, response::Response)
	# Normalise the responses into frequencies:
	sigma = std(response);						# Standard deviation
	if sigma != 0
		# Chop off all responses worse than 1 standard deviation
		# above niche average:
		stability = 1 .+ (mean(response) .- response) ./ sigma
		stability[stability .<= 0] .= 0
	else
		# Singular case: all evaluations were equal to mean:
		stability = ones(length(response))
	end
	
	# Normalise the growth rates into frequencies:
	stability /= sum(stability)

	# Record the most recent responses
	niche.response = response
	_, niche.bestresponse = findmax(stability)

	stability
end

#---------------------------------------------------------------------
@doc raw"""
    express( affordance)

Express a single Affordance as a Construction
"""
function express( niche::StringNiche, aff::Affordance)
	# Note: Add 1 to convert Affordance to Construction:
	aff.data .+ 1
end

#---------------------------------------------------------------------
@doc raw"""
    express( niche)

Express the StringNiche's Affordances as a Construction
"""
function Rheolecsis.express( niche::StringNiche)
	map( niche.affordances) do aff
		express( niche, aff)
	end
end
#=====================================================================
# BinaryNiche: Niches that display their Affordances as a Vector of
# indices to an alphabet of symbols.
=====================================================================#
binarynicheunittest = false					# Set unit test environment
if binarynicheunittest
	#------------------------- Unit Testing --------------------------
	include("../Rheolecsis.jl")
	include("../Casinos.jl")
	using .Rheolecsis, .Casinos, Random
	using Statistics: mean, std
	include("BinaryEnform.jl")

	function unittest()
		println("\n============ Unit test BinaryNiche: ===============")
		println("Create a BinaryNiche with 5 Affordances of 15 data:")
		niche = BinaryNiche(5,15)
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
	```BinaryNiche```

A very simple Niche that displays Affordances as a Vector of indices
to an alphabet of symbols. Intended only for tutorial purposes.
"""
mutable struct BinaryNiche <: Rheolecsis.Niche
	affordances::Vector{Affordance}		# A profile of Affordances
	mu::Float64							# Affordance mutation rate
	response::Response					# Current Enform response
	bestresponse::Int					# Index of best response
end

#---------------------------------------------------------------------
@doc raw"""
	```BinaryNiche( nafford, ndata)```

Construct a BinaryNiche with nafford Affordances, each containing
ndata data. Estimate mutation rate at 2 per generation.
"""
function BinaryNiche( nafford::Int, ndata::Int)
	if rem(nafford,2) != 0
		# Ensure nafford is even for our algorithm:
		nafford += 1
	end

	BinaryNiche(
		[Affordance( ndata, length(ALPHABET)) for _ in 1:nafford],
		2 / (nafford*ndata),
		zeros(nafford) / nafford,
		1
	)
end

#---------------------------------------------------------------------
@doc raw"""
	```size( niche)```

Size of a BinaryNiche is (naffordances,ndata)
"""
function size( niche::BinaryNiche)
	(length(niche.affordances), length(niche.affordances[1].data))
end

#---------------------------------------------------------------------
@doc raw"""
	```mutate!( niche)```

Mutate all Affordances in this Niche with probability niche.mu.
"""
function Rheolecsis.mutate!( niche::BinaryNiche)
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

Recombine members of the BinaryNiche affordances based on normalised
growth rates pre-calculated out of responses from an Enform.
"""
function Rheolecsis.recombine!( niche::BinaryNiche, growth::Vector{Float64})
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
				recombine( mummy[m], daddy[m])
	end

	# ... and finally replace the old fogeys:
	niche.affordances = progeny
	niche
end

#---------------------------------------------------------------------
@doc raw"""
    ```growth!( niche, response) -> stabilities```

Interpret the response from an Enform construction/expression as
a set of stability conditions on the niche, converting them into a
vector of normalised scores suitable for roulette-wheel selection on
the niche's Affordances.

**Note:** This implementation assumes we wish to *minimise* the response!
"""
function Rheolecsis.growth!( niche::BinaryNiche, response::Response)
	# Normalise the responses into frequencies:
	sigma = std(response);						# Standard deviation
	if sigma != 0
		# Chop off all responses worse than 1 standard deviation
		# above niche average:
		growth = 1 .+ (mean(response) .- response) ./ sigma
		growth[growth .<= 0] .= 0
	else
		# Singular case: all evaluations were equal to mean:
		growth = ones(length(response))
	end
	
	# Normalise the growth rates into frequencies:
	growth /= sum(growth)

	# Record the most recent responses
	niche.response = response
	_, niche.bestresponse = findmax(growth)

	growth
end

#---------------------------------------------------------------------
@doc raw"""
    express( niche)

Express the BinaryNiche's Affordances as a Construction
"""
function Rheolecsis.express( niche::BinaryNiche)
	map( niche.affordances) do affordance
		affordance.data
	end
end

#---------------------------------------------------------------------
@doc raw"""
    show( niche)

Display current status of BinaryNiche.
"""
function Base.show( io::IO, niche::BinaryNiche)
	println( io, "\"",
		interpret(niche.affordances[niche.bestresponse].data),
		"\" : ", niche.response[niche.bestresponse]
	)
end
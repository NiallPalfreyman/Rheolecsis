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
		println("... and explore them:  $(interpret.(explore(niche)))")
		mutate!( niche)
		println("Mutate and re-explore: $(interpret.(explore(niche)))")
		recombine!( niche, Float64.(1:6))
		println()
		println("Now recombine them:    $(interpret.(explore(niche)))")
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
	temperature::Float64				# Sigma-scaling factor
	response::Response					# Current response values
	stability::Vector{Float64}			# Corresponding stability values
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
		1,							# temperature
		ones(nafford)/nafford,		# response
		ones(nafford)/nafford		# stability
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
		1,							# temperature
		ones(nafford)/nafford,		# response
		ones(nafford)/nafford		# stability
)
end

#---------------------------------------------------------------------
@doc """
	```temperature!( niche, temp)```

Set the temperature of the StringNiche. All responses worse than
```temperature``` standard deviations from the mean get removed from
the population.
"""
function temperature!( niche::StringNiche, temp::Float64)
	niche.temperature = max(min(temp,5),0.1)
end

#---------------------------------------------------------------------
@doc """
	```mu!( niche, mu)```

Set the mutation rate of the StringNiche. ```mu``` is the probability
that any given Affordance datum is mutated at any given instant.
"""
function mu!( niche::StringNiche, mu::Float64)
	niche.mu = max(min(mu,1),0)
end

#---------------------------------------------------------------------
@doc """
	```size( niche)```

Size of a StringNiche is (naffordances,ndata)
"""
function size( niche::StringNiche)
	(length(niche.affordances), length(niche.affordances[1].data))
end

#---------------------------------------------------------------------
@doc """
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
@doc """
    ```recombine!( niche, growth)```

Recombine members of the StringNiche affordances based on normalised
growth rates pre-calculated out of responses from an Enform.
"""
function Rheolecsis.recombine!( niche::StringNiche)
	# Set up a roulette wheel of stability-biased slots:
	roulette = cumsum( niche.stability)/sum(niche.stability)
	# Set up nafford (rigidly) uniformly distributed ball throws:
	nafford = size(niche)[1]
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
	shuffle!(parents)		# Shuffle the order of parents

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

Interpret the response from an Enform construction/exploration as
a set of stability conditions on the niche, converting them into a
vector of normalised scores suitable for roulette-wheel selection on
the niche's Affordances.

**Note:** This implementation assumes we wish to *minimise* the response!
"""
function Rheolecsis.stabilise!( niche::StringNiche, response::Response)
	# Record the niche's current response:
	niche.response = response
	# Normalise the responses into frequencies:
	sigma = std(response)						# Standard deviation
	if sigma == 0
		# Singular case: all responses were equal to mean:
		stability = ones(length(response))
	else
		# Exorcise all responses worse than 1/temperature standard
		# deviations above niche average:
		stability = 1 .+ (mean(response) .- response) ./
						(sigma*niche.temperature)
		stability[stability .<= 0] .= 0
	end
	
	# Normalise the stability rates into frequencies:
	niche.stability = stability / sum(stability)
end

#---------------------------------------------------------------------
@doc """
    ```stablest( niche) -> stablestaffordance, stability```

Return the staAffordance with best response, together with that response.
"""
function stablest( niche::StringNiche)
	_,stablest = findmax(niche.stability)
	(
		niche.affordances[stablest],
		niche.response[stablest]
	)
end

#---------------------------------------------------------------------
@doc """
    explore( affordance)

Explore a single Affordance as a Construction
"""
function explore( niche::StringNiche, aff::Affordance)
	# Note: Add 1 to convert Affordance to Construction:
	aff.data .+ 1
end

#---------------------------------------------------------------------
@doc """
    explore( niche)

Explore the StringNiche's Affordances as a Construction
"""
function Rheolecsis.explore( niche::StringNiche)
	map( niche.affordances) do aff
		explore( niche, aff)
	end
end
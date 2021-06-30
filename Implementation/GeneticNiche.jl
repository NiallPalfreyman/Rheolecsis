#=====================================================================
# GeneticNiche: Niches that recombine, mutate and display their
# Affordances directly as traits.
=====================================================================#
geneticnicheunittest = false					# Set unit test environment
if geneticnicheunittest
	#------------------------- Unit Testing --------------------------
	include("../Rheolecsis.jl")
	include("../Casinos.jl")
	include("../Objectives.jl")
	include("../Decoders.jl")
	using .Rheolecsis, .Casinos, .Objectives, .Decoders, Random
	include("BinaryEnform.jl")
	using Statistics: mean, std

	function unittest()
		println("\n============ Unit test GeneticNiche: ===============")
		println("GeneticNiche with 5 Affordances of 15 ternary data:")
		niche = GeneticNiche(5,15,3)
		display(niche.affordances)
		mutate!( niche)
		println("Mutated:")
		display(niche.affordances)
		recombine!( niche)
		println()
		println("... and then recombined:")
		display(niche.affordances)
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
	```GeneticNiche```

A GeneticNiche with nafford Affordances, each containing ndata data
with given arity.
"""
mutable struct GeneticNiche <: Niche
	affordances::Vector{Affordance}		# Affordance profile
	explarity::Int						# Exploratory arity
	mu::Float64							# Affordance mutation rate
	temperature::Float64				# Sigma-scaling factor
	response::Response					# Current response values
	stability::Vector{Float64}			# Corresponding stability values

	function GeneticNiche( nafford::Int, ndata::Int;
		explarity::Int=2, curiosity::Int=0
	)
		if rem(nafford,2) != 0
			# nafford must be even for our recombination algorithm:
			nafford += 1
		end
		new(
			[Affordance( ndata, explarity+curiosity) for _ ∈ 1:nafford],
			explarity,					# explarity
			2/(nafford*ndata),			# mu (2 per generation)
			1,							# temperature
			ones(nafford)/nafford,		# response
			ones(nafford)/nafford		# stability
		)
	end
end

#---------------------------------------------------------------------
@doc """
	```temperature!( niche, temp)```

Set the temperature of the GeneticNiche. All responses worse than
```temperature``` standard deviations from the mean get removed from
the population.
"""
function temperature!( niche::GeneticNiche, temp::Float64)
	niche.temperature = max(min(temp,5),0.1)
end

#---------------------------------------------------------------------
@doc """
	```mu!( niche, mu)```

Set the mutation rate of the GeneticNiche. ```mu``` is the probability
that any given Affordance datum is mutated at any given instant.
"""
function mu!( niche::GeneticNiche, mu::Float64)
	niche.mu = max(min(mu,1),0)
end

#---------------------------------------------------------------------
@doc """
	```size( niche)```

Size of a GeneticNiche is (naffordances,ndata)
"""
function size( niche::GeneticNiche)
	(length(niche.affordances), length(niche.affordances[1].data))
end

#---------------------------------------------------------------------
@doc """
	```mutate!( niche)```

Mutate all Affordances in this Niche with probability niche.mu.
"""
function Rheolecsis.mutate!( niche::GeneticNiche)
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
    ```recombine!( niche, select)```

Recombine members of the GeneticNiche affordances based on selection
constraints determined by responses from an Enform.
"""
function Rheolecsis.recombine!( niche::GeneticNiche)
	# Set up a roulette wheel of stability-biased slots:
	roulette = cumsum( niche.stability)/sum(niche.stability)
	# Set up nafford (rigidly) uniformly distributed ball throws:
	nafford = size(niche)[1]
	throws = rem.( rand() .+ (1:nafford)./nafford, 1)

	# Throw ball onto roulette wheel to select recombinant Affordance pairs:
	parents = zeros(Integer,nafford)
	for parent in 1:nafford
		for slot in 1:nafford
			if throws[parent] <= roulette[slot]
				parents[parent] = slot
				break
			end
		end
	end
	shuffle!(parents)				# Shuffle the order of parents

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
@doc """
    ```stabilise!( niche, response) -> stability```

Interpret the response from an Enform construction/exploration as
a set of stability conditions on the niche, converting them into a
vector of normalised scores suitable for roulette-wheel selection on
the niche's Affordances.

**Note:** This implementation assumes we wish to *minimise* the response!
"""
function Rheolecsis.stabilise!( niche::GeneticNiche, response::Response)
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
function stablest( niche::GeneticNiche)
	_,stablest = findmax(niche.stability)
	(
		niche.affordances[stablest],
		niche.response[stablest]
	)
end

#---------------------------------------------------------------------
@doc """
    explore( affordance)

Implement a single Affordance as an Exploration
"""
function explore( niche::GeneticNiche, aff::Affordance)
	# Convert Affordance to Exploration:
	exploration = copy(aff.data)
	curiosity = (exploration .≥ niche.explarity)
	exploration[curiosity] = rand(0:niche.explarity-1,sum(curiosity))

	exploration
end

#---------------------------------------------------------------------
@doc """
    ```explore( niche)```

Implement the GeneticNiche's Affordances as an Exploration
"""
function Rheolecsis.explore( niche::GeneticNiche)
	nafford = size(niche)[1]
	exploration = [similar(niche.affordances[1].data) for _ ∈ 1:nafford]
	
	for i ∈ 1:nafford
		# Convert Affordances to Explorations:
		exploration[i][:] = niche.affordances[i].data[:]
		curiosity = (exploration[i] .≥ niche.explarity)
		exploration[i][curiosity] = rand(0:niche.explarity-1,sum(curiosity))
	end

	exploration
end
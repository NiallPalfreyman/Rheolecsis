geneticrssunittest = true					# Set up unit testing

module GeneticRSs
#=====================================================================
# Genetic RSs.
=====================================================================#
using Base: Unsigned
include("Rheolecsis.jl")
include("Casinos.jl")
include("Objectives.jl")
include("Decoders.jl")

using .Rheolecsis, .Casinos, .Objectives, .Decoders
using Statistics: mean, std
using Random: shuffle!

include("Implementation/BinaryEnform.jl")
include("Implementation/GeneticNiche.jl")

export GeneticRS, Objective, enact!, temperature!, mu!, determinate!
export nohint, mepi, niche, enform, status

#====================================================================#
@doc """
    ```GeneticRS```
Genetic optimising RS.
"""
struct GeneticRS <: Rheolecsim
	enform::BinaryEnform				# The informing environment
	niche::GeneticNiche					# The self-asserting enclave

	"Construct a new GeneticRS instance"
	function GeneticRS( obj::Objective, accuracy::Int, nafford::Int;
		explarity::Int=2, curiosity::Int=0
	)
		enform = BinaryEnform( obj, accuracy, explarity, curiosity)
		niche = GeneticNiche( nafford, accuracy*obj.dimension,
								explarity, curiosity
		)
		embed!( niche, enform)
		new(enform,niche)
	end
end

#---------------------------------------------------------------------
@doc """
    ```niche( rs)````

Return GeneticRS's niche.
"""
function Rheolecsis.niche( rs::GeneticRS)
	rs.niche
end

#---------------------------------------------------------------------
@doc """
    ```enform( rs)````

Return GeneticRS's enform.
"""
function Rheolecsis.enform( rs::GeneticRS)
	rs.enform
end

#---------------------------------------------------------------------
@doc """
    ```temperature!( rs)````

Set the GeneticRS's Niche's temperature
"""
function temperature!( rs::GeneticRS, temp::Float64)
	temperature!( rs.niche, temp)
end

#---------------------------------------------------------------------
@doc """
    ```status( rs)````

	Return current status (data, interpretation, evaluation) of stablest
	Affordance in rs.niche.
"""
function status( rs::GeneticRS)
	data = explore( rs.niche, stablest( rs.niche)[1])
	interpretation = interpret( rs.enform, data)
	(data, interpretation, evaluate( rs.enform, interpretation))
end

#---------------------------------------------------------------------
@doc """
    ```show( rs)````

Display current status of stablest Affordance in rs.niche.
"""
function Base.show( io::IO, rs::GeneticRS)
	data, interpretation = status( rs)
	println( io, "\"", data, "\" : ", interpretation)
end

end		# ... of module GeneticRSs

#========================= Unit testing =============================#
if geneticrssunittest
	using .GeneticRSs

	function unittest( apparatus=1, complexity=20, duration=100.0)
		nsuccess = [0,0]				# Count successful searches
		ntrials = [0,0]					# Number of trials
		ngenerations = [0,0]			# Number of generations performed
		maxgens = 30					# Max number of generations/trial
		comptime = [0.0,0.0]			# Track computation time
		running = [true,true]			# Are trials still running?
		curiosity = 100					# General curiosity level

		# Set up apparatus and force compilation before benchmarking:
		testbed = GeneticRS( Objective(6), complexity, 20, curiosity=1)
		enact!( testbed)

		println("\n============ Unit test GeneticRSs: ===============")
		while any(running)
			# Choose new benchmark apparatus:
			if apparatus == 1					# De Jong (1975)
				testbed = [GeneticRS( Objective(6), complexity, 20),
					GeneticRS( Objective(6), complexity, 20, curiosity=curiosity)
				]
				threshold = -15.0
			elseif apparatus == 2				# Hinton & Nowlan (1987)
				testbed = [GeneticRS( Objective(nohint, complexity, [[0,1]]), 1, 20),
					GeneticRS( Objective(nohint, complexity, [[0,1]]), 1, 20, curiosity=curiosity)
				]
				threshold = 0.1
			else								# Watson (2007)
				testbed = [GeneticRS( Objective(mepi, complexity, [[0,1]]), 1, 20),
					GeneticRS( Objective(mepi, complexity, [[0,1]]), 1, 20, curiosity=curiosity)
				]
				threshold = complexity + 1
			end

			# Perform trials, reporting number of generations taken to achieve
			# threshold criterion genetically:
			for rs ∈ 1:2
				# Conduct RS trial with and without curiosity:
				ngenerations[rs] = 0
				while ngenerations[rs] < maxgens && status(testbed[rs])[3] > threshold
					# Run testbed simulation to threshold:
					comptime[rs] += @elapsed enact!( testbed[rs], (rs==1 ? curiosity : 1))
					ngenerations[rs] += 1
					if comptime[rs] > 10
						running[rs] = false
					end
				end
			end
		end

		println( "Results over $(maximum(comptime,dims=1)) seconds using $(complexity) bits ...")
		println()

		for rs ∈ 1:2
			# Trial 1: curiosity 0; trial 2: curiosity = 100
			println( "Success $(rs==1 ? "without" : "with") curiosity:",
				lpad(nsuccess[rs],2), "/", ngenerations[rs], "; time = ", comptime[rs])
			println( "Final state: ", testbed[rs])
		end
	end

end
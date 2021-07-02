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
export nohint, mepi, niche, enform, stablest

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
    ```show( rs)````

Display current status of best Affordance in GeneticNiche.
"""
function Base.show( io::IO, rs::GeneticRS)
	aff, resp = stablest( rs.niche)
	interpretation = interpret( rs.enform, explore( rs.niche, aff))

	println( io, "\"", interpretation, "\" : ", resp)
end

end		# ... of module GeneticRSs

#========================= Unit testing =============================#
if geneticrssunittest
	using .GeneticRSs

	function unittest( apparatus=3, complexity=20, duration=100.0)
		nsuccess = fill(0,2)					# Count successful searches
		ntrials = fill(0,2)						# Count number of trials
		comptime = fill(0.0,2)					# Track computation time
		running = fill(true,2)					# Are trials still running?
		curiosity = 100							# General curiosity level
		ngenerations = 300						# Number of enact gens

		# Set up apparatus and force compilation before benchmarking:
		# De Jong (1975):
		rsbench = GeneticRS( Objective(6), complexity, 20, curiosity=1)
		# Hinton & Nowlan (1987):
		rsbench = GeneticRS( Objective(nohint, complexity, [[0,1]]), 1, 20, curiosity=1)
		# Watson (2007):
		rsbench = GeneticRS( Objective(mepi, complexity, [[0,1]]), 1, 20, curiosity=1)
		enact!( rsbench, 2)

		println("\n============ Unit test GeneticRSs: ===============")
		while any(running)
			# Choose new benchmark apparatus:
			if apparatus == 1					# De Jong (1975)
				rsbench = [GeneticRS( Objective(6), complexity, 20),
					GeneticRS( Objective(6), complexity, 20, curiosity=curiosity)
				]
				threshold = -18.0
			elseif apparatus == 2				# Hinton & Nowlan (1987)
				rsbench = [GeneticRS( Objective(nohint, complexity, [[0,1]]), 1, 20),
					GeneticRS( Objective(nohint, complexity, [[0,1]]), 1, 20, curiosity=curiosity)
				]
				threshold = 0.1
			else								# Watson (2007)
				rsbench = [GeneticRS( Objective(mepi, complexity, [[0,1]]), 1, 20),
				GeneticRS( Objective(mepi, complexity, [[0,1]]), 1, 20, curiosity=curiosity)
			]
				threshold = complexity + 1
			end

			# Perform current trials:
			for trial ∈ 1:2
				# Trial 1: curiosity 0; trial 2: curiosity = 100
				if running[trial]
					if comptime[trial] < duration
						ntrials[trial] += 1
						comptime[trial] += @elapsed enact!( rsbench[trial],
										ngenerations * (trial==1 ? curiosity : 1))
						if stablest(rsbench[trial].niche)[2] <= threshold
							# Record trial result:
							nsuccess[trial] += 1
						end
					else
						running[trial] = false
					end
				end
			end
		end

		println( "Results over $(duration) seconds using $(complexity) bits ...")
		println()

		for trial ∈ 1:2
			# Trial 1: curiosity 0; trial 2: curiosity = 100
			println( "Success $(trial==1 ? "without" : "with") curiosity:",
				lpad(nsuccess[trial],2), "/", ntrials[trial], "; time = ", comptime[trial])
			println( "Final state: ", rsbench[trial])
		end
	end

end
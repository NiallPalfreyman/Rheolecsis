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
	enform::BinaryEnform
	niche::GeneticNiche

	"Construct a new GeneticRS instance"
	function GeneticRS( obj::Objective, accuracy::Int, nafford::Int;
		explarity::Int=2, curiosity::Int=0
	)
		enform = BinaryEnform( obj, accuracy, explarity)
		niche = GeneticNiche( nafford, accuracy*obj.dimension,
			explarity=explarity, curiosity=curiosity
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

	function unittest( complexity::Int=13, ngens::Int=100)
		# Initialise counters and force compilation:
		nsuccess0 = 0
		nsuccess1 = 0
		timing0 = 0.0
		timing1 = 0.0
		running0 = true
		running1 = true
		enact!( GeneticRS( Objective(nohint, complexity, [[0,1]]), 1, 20, curiosity=1), 5)

		println("\n============ Unit test GeneticRSs: ===============")
		while running0 || running1
			# Hinton & Nowlan 1987, without and with curiosity:
#			rs0 = GeneticRS( Objective(nohint, complexity, [[0,1]]), 1, 20)
#			rs1 = GeneticRS( Objective(nohint, complexity, [[0,1]]), 1, 20, curiosity=1)
			# De Jong (1989):
#			rs0 = GeneticRS( Objective(6), 15, 20)
#			rs1 = GeneticRS( Objective(6), 15, 20, curiosity=1)
			# Watson (2007) - complexity 128:
			rs0 = GeneticRS( Objective(mepi, complexity, [[0,1]]), 1, 20)
			rs1 = GeneticRS( Objective(mepi, complexity, [[0,1]]), 1, 20, curiosity=1)

			if running0 && timing0 < 1
				timing0 += @elapsed enact!(rs0,100*ngens)
			else
				running0 = false
			end
			if running1 && timing1 < 1
				timing1 += @elapsed enact!(rs1,ngens)
			else
				running1 = false
			end

			if running0 && stablest(rs0.niche)[2] <= complexity+1
				nsuccess0 += 1
			end
			if running1 && stablest(rs1.niche)[2] <= complexity+1
				nsuccess1 += 1
			end
		end

		println( "Results over 500 seconds using $(complexity) bits ...")
		println( "Success without curiosity:", lpad(nsuccess0,4), "%; time = ", timing0)
		println( "Success with curiosity:   ", lpad(nsuccess1,4), "%; time = ", timing1)
	end
end
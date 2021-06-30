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

#---------------------------------------------------------------------
@doc """
    ```embed!( niche, enform)```

Reimplementation of the Rheolecsis embed! method to allow for multiple
explorations by one niche.
"""
function Rheolecsis.embed!( niche::GeneticNiche, enform::BinaryEnform)
	exploration = Rheolecsis.explore(niche)		# Niche's exploration ...
	response =							# defines its constructions ...
		construct!(enform,exploration)	# and the enform's responses ...
	stabilise!(niche,response)			# then define the new stability.
end

end		# ... of module GeneticRSs

#========================= Unit testing =============================#
if geneticrssunittest
	using .GeneticRSs

	function unittest( complexity::Int=13, nruns::Int=100)
		println("\n============ Unit test GeneticRSs: ===============")
		# De Jong (1989):
#		rs = GeneticRS( Objective(6), 15, 20)	# De Jong 6
		# Watson (2007) - complexity 128:
#		rs = GeneticRS( Objective(mepi, complexity, [[0,1]]), 1, 20)

		nsuccess0 = 0
		nsuccess1 = 0
		for _ ∈ 1:nruns
			# Hinton & Nowlan 1987, without and with curiosity:
			rs0 = GeneticRS( Objective(nohint, complexity, [[0,1]]), 1, 20)
			rs1 = GeneticRS( Objective(nohint, complexity, [[0,1]]), 1, 20, curiosity=1)

			enact!(rs0,1000)
			enact!(rs1,1000)

			if stablest(rs0.niche)[2] == 0.0
				nsuccess0 += 1
			end
			if stablest(rs1.niche)[2] == 0.0
				nsuccess1 += 1
			end
		end

		println( "Results after $(nruns) generations using $(complexity) bits ...")
		println( "Success without curiosity:  ", nsuccess0)
		println( "Success with curiosity:     ", nsuccess1)
	end
end
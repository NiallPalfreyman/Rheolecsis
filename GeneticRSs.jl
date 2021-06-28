geneticrssunittest = true					# Set up unit testing

module GeneticRSs
#=====================================================================
# Genetic RSs.
=====================================================================#
include("Rheolecsis.jl")
include("Casinos.jl")
include("Objectives.jl")
include("Decoders.jl")

using .Rheolecsis, .Casinos, .Objectives, .Decoders
using Statistics: mean, std
using Random: shuffle!

include("Implementation/BinaryEnform.jl")
include("Implementation/GeneticNiche.jl")

export GeneticRS, Objective, enact!, temperature!, mu!, testing!

#====================================================================#
@doc """
    ```GeneticRS```
Genetic optimising RS.
"""
struct GeneticRS <: Rheolecsim
	enform::BinaryEnform
	niche::GeneticNiche

	"Construct a new GeneticRS instance"
	function GeneticRS( obj::Objective, accuracy::Int, nafford::Int)
		enform = BinaryEnform( obj, accuracy)
		niche = GeneticNiche( nafford, accuracy*obj.dimension)
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
	interpretation = interpret( rs.enform, express( rs.niche, aff))

	println( io, "\"", interpretation, "\" : ", resp)
end

end		# ... of module GeneticRSs

#========================= Unit testing =============================#
if geneticrssunittest
	using .GeneticRSs

	function unittest()
		testing!()									# Make rng determinate
		println("\n============ Unit test GeneticRSs: ===============")
		rs = GeneticRS( Objective(6), 15, 16)		# De Jong 6
#		rs = GeneticRS( Objective(14), 1, 16)		# Hinton & Nowlan 1987
#		rs = GeneticRS( Objective(15), 1, 16)		# Watson 2007

		temperature!( rs, 2.0)
		println( "Initially ", rs)
		
		n = 1000
		enact!( rs, n)
		println( "After $(n) generation(s) ...")
		println( rs)
	end
end
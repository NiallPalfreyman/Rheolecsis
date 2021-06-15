binaryrasunittest = true					# Set up unit testing

module BinaryRAs
#=====================================================================
# String RAs.
=====================================================================#
include("Rheolecsis.jl")
include("Casinos.jl")

using .Rheolecsis, .Casinos, Random
using Statistics: mean, std

include("Implementation/BinaryEnform.jl")
include("Implementation/BinaryNiche.jl")

export BinaryRA, enact!, express

#====================================================================#
@doc raw"""
    ```BinaryRA```
Sting-based RA.
"""
struct BinaryRA
	enform::BinaryEnform
	niche::BinaryNiche

	"Construct a new GAv instance"
	function BinaryRA( target::String)
		len = length( target)
		enform = BinaryEnform( target)
		niche = BinaryNiche( 1+len÷2, len)
		new( enform, niche)
	end
end

#---------------------------------------------------------------------
@doc raw"""
    ```enact!( ra, steps)````

Enact this RA through a sequence of steps
"""
function enact!( ra::BinaryRA, steps::Int)
	Rheolecsis.enact!( ra.niche, ra.enform, steps)
end

#---------------------------------------------------------------------
@doc raw"""
    ```show( niche)````

Display current status of best Affordance in StringNiche.
"""
function Base.show( io::IO, ra::BinaryRA)
	Base.show( io, ra.niche)
end

end		# ... of module BinaryRAs

#========================= Unit testing =============================#
if binaryrasunittest
	using .BinaryRAs
	function unittest()
		println("\n============ Unit test BinaryRAs: ===============")
		ra = BinaryRA("RA's are great fun, aren't they?! :-)")
		println( "Initially ...")
		println( ra);
		
		ntoshow = 40			# Number of steps to display
		nhidden = 50			# Number hidden steps between displays
		for i = 1:ntoshow
			enact!( ra, nhidden)
			println( "After $(nhidden*i) iterations ...")
			println( ra)
			println( "Press Enter to continue ...")
			readline()
		end
	end
end
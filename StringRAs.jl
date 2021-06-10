stringrasunittest = true					# Set up unit testing

module StringRAs
#=====================================================================
# String RAs.
=====================================================================#
include("Rheolecsis.jl")
include("Casinos.jl")

using .Rheolecsis, .Casinos, Random
using Statistics: mean, std

include("Implementation/StringEnform.jl")
include("Implementation/StringNiche.jl")

export StringRA, enact!, express

#====================================================================#
@doc raw"""
    ```StringRA```
Sting-based RA.
"""
struct StringRA
	enform::StringEnform
	niche::StringNiche

	"Construct a new GAv instance"
	function StringRA( target::String)
		len = length( target)
		enform = StringEnform( target)
		niche = StringNiche( 1+len÷2, len)
		new( enform, niche)
	end
end

#---------------------------------------------------------------------
@doc raw"""
    ```enact!( ra, steps)````

Enact this RA through a sequence of steps
"""
function enact!( ra::StringRA, steps::Int)
	Rheolecsis.enact!( ra.niche, ra.enform, steps)
end

#---------------------------------------------------------------------
@doc raw"""
    ```show( niche)````

Display current status of best Affordance in StringNiche.
"""
function Base.show( io::IO, ra::StringRA)
	Base.show( io, ra.niche)
end

end		# ... of module StringRAs

#========================= Unit testing =============================#
if stringrasunittest
	using .StringRAs
	function unittest()
		println("\n============ Unit test StringRAs: ===============")
		ra = StringRA("RA's are great fun, aren't they?! :-)")
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
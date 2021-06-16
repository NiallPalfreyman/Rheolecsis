stringrssunittest = true					# Set up unit testing

module StringRSs
#=====================================================================
# String RSs.
=====================================================================#
include("Rheolecsis.jl")
include("Casinos.jl")

using .Rheolecsis, .Casinos, Random
using Statistics: mean, std

include("Implementation/StringEnform.jl")
include("Implementation/StringNiche.jl")

export StringRS, enact!, express

#====================================================================#
@doc raw"""
    ```StringRS```
String-based RS.
"""
struct StringRS
	enform::StringEnform
	niche::StringNiche

	"Construct a new StringRS instance"
	function StringRS( target::String)
		len = length( target)
		enform = StringEnform( target)
		niche = StringNiche( 1+len÷2, len)
		new( enform, niche)
	end
end

#---------------------------------------------------------------------
@doc raw"""
    ```enact!( rs, steps)````

Enact this RS through a sequence of steps
"""
function enact!( rs::StringRS, steps::Int)
	Rheolecsis.enact!( rs.niche, rs.enform, steps)
end

#---------------------------------------------------------------------
@doc raw"""
    ```show( niche)````

Display current status of best Affordance in StringNiche.
"""
function Base.show( io::IO, rs::StringRS)
	Base.show( io, rs.niche)
end

end		# ... of module StringRAs

#========================= Unit testing =============================#
if stringrssunittest
	using .StringRSs
	function unittest()
		println("\n============ Unit test StringRSs: ===============")
		rs = StringRS("RS's are great fun, aren't they?! :-)")
		println( "Initially ...")
		println( rs);
		
		ntoshow = 40			# Number of steps to display
		nhidden = 50			# Number hidden steps between displays
		for i = 1:ntoshow
			enact!( rs, nhidden)
			println( "After $(nhidden*i) iterations ...")
			println( rs)
			println( "Press Enter to continue ...")
			readline()
		end
	end
end
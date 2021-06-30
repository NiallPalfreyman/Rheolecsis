stringrssunittest = true					# Set up unit testing

module StringRSs
#=====================================================================
# String RSs.
=====================================================================#
include("Rheolecsis.jl")
include("Casinos.jl")

using .Rheolecsis, .Casinos
using Statistics: mean, std
using Random: shuffle!

include("Implementation/StringEnform.jl")
include("Implementation/StringNiche.jl")

export StringRS, enact!, temperature!, mu!, determinate!

#====================================================================#
@doc """
    ```StringRS```
String-based RS.
"""
struct StringRS <: Rheolecsim
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
@doc """
    ```niche( rs)````

Return StringRS's niche.
"""
function Rheolecsis.niche( rs::StringRS)
	rs.niche
end

#---------------------------------------------------------------------
@doc """
    ```enform( rs)````

Return StringRS's enform.
"""
function Rheolecsis.enform( rs::StringRS)
	rs.enform
end

#---------------------------------------------------------------------
@doc """
    ```temperature!( rs)````

Set the StringRS's Niche's temperature
"""
function temperature!( rs::StringRS, temp::Float64)
	temperature!( rs.niche, temp)
end

#---------------------------------------------------------------------
@doc """
    ```show( rs)````

Display current status of best Affordance in StringNiche.
"""
function Base.show( io::IO, rs::StringRS)
	aff, resp = stablest( rs.niche)
	interpretation = interpret( rs.enform, explore( rs.niche, aff))

	println( io, "\"", interpretation, "\" : ", resp)
end

end		# ... of module StringRAs

#========================= Unit testing =============================#
if stringrssunittest
	using .StringRSs
	function unittest()
		determinate!()
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
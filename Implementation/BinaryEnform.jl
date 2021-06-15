#=====================================================================
# BinaryEnform: A very simple Enform in which strings are evaluated by
# comparison with a single target string.
=====================================================================#
binaryenformunittest = false				# Set unit test environment
if binaryenformunittest
	#------------------------- Unit Testing --------------------------
	include("../Rheolecsis.jl")
	using .Rheolecsis

	function unittest()
		strings = [
			"To be, or not to be - that is the question!",
			"To be, or not to be - what is the question?",
			"To not be - that is the question!",
			"To be, or not to be - that is such rubbish!",
			"Niall Palfreyman read the string yesterday."
		]
	
		println("\n=======================================================")
		println("Create a BinaryEnform and evaluate a few strings:")
		enform = BinaryEnform(strings[1])
		evaluation = construct!( enform, encode.(strings))
	
		for i ∈ 1:length(strings)
			println( "String \"", strings[i], "\" has evaulation: ",
				evaluation[i], ".")
		end
	end
end

#====================================================================#
@doc raw"""
	```ALPHABET```

Complete set of symbols available for building BinaryEnform targets.
"""
ALPHABET = "?" *							# Default symbol
	String('A':'Z') * String('a':'z') *
	String('0':'9') * " !(),.*;:-'_"

#---------------------------------------------------------------------
@doc raw"""
	```BinaryEnform```

A very simple Enform, intended only for tutorial purposes. It evaluates
a Niche by comparing its Affordances to a prespecified target string.
"""
struct BinaryEnform <: Enform
	target::Vector{Int}		        	# Indices to Chars in alphabet
	alphabet							# Common alphabet of symbols

	function BinaryEnform( targ::String = "")
    	new( encode( targ), ALPHABET)
	end
end

#---------------------------------------------------------------------
@doc raw"""
	```construct!( senform, profile)``` -> ```response```

In BinaryEnform, profiles do not change the senform, but are instead
evaluated by the senform according to their Hamming-deviation from a
target string.
"""
function Rheolecsis.construct!( senform::BinaryEnform, profile::Construction)
	map( profile) do expr
		comprlen = length(expr)			# Length for comparison
		deltalen =						# Difference in length
			abs(length(senform.target) - comprlen)
		response = 0

		if deltalen > 0
			# Penalise differences in length:
			response = length(ALPHABET) * deltalen ÷ 2
			comprlen = min(length(senform.target),comprlen)
		end

		# Evaluate both wraparound differences:
		barediff = senform.target[1:comprlen] - expr[1:comprlen]
		wrapdiff = mod.( barediff .+ length(ALPHABET), length(ALPHABET))
		barediff = abs.( barediff)
		response += sum(min.(barediff,wrapdiff))

		Float64(response)
	end
end

#---------------------------------------------------------------------
@doc raw"""
	```interpret( senform, profile)```

Interpret the given expression profile as a string.
"""
function interpret( senform::BinaryEnform, profile::Construction)
	interpret.( profile)
end

#---------------------------------------------------------------------
@doc raw"""
	```interpret( expression)```

Interpret the specific expression as a string.
"""
function interpret( expression::Vector{Int})
	ALPHABET[expression]
end

#=====================================================================
# Unexported implementation methods
=====================================================================#
@doc raw"""
	```encode( string)```

Convert string to a Vector of indices in ALPHABET.
"""
function encode( string::String)
	map(collect(string)) do ch
		ff = findfirst(isequal(ch), ALPHABET)
		(ff === nothing) ? 1 : ff
	end
end
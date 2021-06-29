#=====================================================================
# StringEnform: A very simple Enform in which strings are evaluated by
# comparison with a single target string.
=====================================================================#
stringenformunittest = false				# Set unit test environment
if stringenformunittest
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
		println("Create a StringEnform and evaluate a few strings:")
		enform = StringEnform(strings[1])
		evaluation = construct!( enform, encode.(strings))
	
		for i ∈ 1:length(strings)
			println( "String \"", strings[i], "\" has evaulation: ",
				evaluation[i], ".")
		end
	end
end

#====================================================================#
@doc """
	```ALPHABET```

Complete set of symbols available for building StringEnform targets.
"""
ALPHABET = "?" *							# Default symbol
	String('A':'Z') * String('a':'z') *
	String('0':'9') * " !(),.*;:-'_"

#---------------------------------------------------------------------
@doc raw"""
	```StringEnform```

A very simple Enform, intended only for tutorial purposes. It evaluates
a Niche by comparing its Affordances to a prespecified target string.
"""
struct StringEnform <: Enform
	target::Vector{Int}		        	# Indices to Chars in alphabet
	alphabet							# Common alphabet of symbols

	function StringEnform( targ::String = "")
    	new( encodeInternal( targ), ALPHABET)
	end
end

#---------------------------------------------------------------------
@doc """
	```construct!( senform, profile)``` -> ```response```

In StringEnform, profiles do not change the senform, but are instead
evaluated by the senform according to their Hamming-deviation from a
target string.
"""
function Rheolecsis.construct!( senform::StringEnform, profile::Construction)
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
@doc """
	```encode( senform, strings)```

Encode a Vector of strings into Vectors of indices in ALPHABET.
"""
function encode( senform::StringEnform, strings::Vector{String})
	encodeInternal.( strings)
end

#---------------------------------------------------------------------
@doc """
	```encode( senform, string)```

Encode a single string as a Vector of indices in ALPHABET.
"""
function encode( senform::StringEnform, string::String)
	encodeInternal( string)
end

#---------------------------------------------------------------------
@doc """
	```interpret( senform, profile)```

Interpret the given exploration profile as a string.
"""
function interpret( senform::StringEnform, profile::Construction)
	interpretInternal.( profile)
end

#---------------------------------------------------------------------
@doc """
	```interpret( senform, profile)```

Interpret the given exploration profile as a string.
"""
function interpret( senform::StringEnform, profile::Vector{Int})
	interpretInternal( profile)
end

#=====================================================================
# Unexported implementation methods
=====================================================================#
@doc """
	```encodeInternal( string)```

(Internal implementation) Convert string to a Vector of indices in
ALPHABET.
"""
function encodeInternal( string::String)
	map(collect(string)) do ch
		ff = findfirst(isequal(ch), ALPHABET)
		(ff === nothing) ? 1 : ff
	end
end

#---------------------------------------------------------------------
@doc """
	```interpretInternal( exploration)```

(Internal implementation) Interpret the specific exploration as a string.
"""
function interpretInternal( exploration::Vector{Int})
	ALPHABET[exploration]
end

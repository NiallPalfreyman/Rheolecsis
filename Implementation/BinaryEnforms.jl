#=====================================================================
# BinaryEnform: A simple Enform that evaluates expressions according
# to their minimisation of an Objective function.
=====================================================================#
binaryenformunittest = false				# Set unit test environment
if binaryenformunittest
	#------------------------- Unit Testing --------------------------
	include("../Rheolecsis.jl")
	include("../Objectives.jl")
	include("../Decoders.jl")
	using .Rheolecsis, .Objectives, .Decoders

	function unittest()
		println("\n=======================================================")
		println("Evaluate these data using a 1-dimensional BinaryEnform:")

		benform = BinaryEnform( Objective(1), 20)
		data = collect(-3.2:1:5)
		println(data)
		println()

		eprofile = exprprofile( benform, data)
		evaluation = construct!( benform, eprofile)
	
		for i ∈ 1:length(eprofile)
			println(
				"Data value ", lpad(eprofile[i],4), " has evaulation: ",
				round(evaluation[i],sigdigits=6), "."
			)
		end
	end
end

#====================================================================#
@doc """
	```BinaryEnform```

A simple Enform that evaluates a according to its ability to
minimise an Objective function.
"""
struct BinaryEnform <: Enform
	objective::Objective	# Objective function for evaluating profiles
	decoder::Decoder		# Binary decoder

	function BinaryEnform( obj::Objective, accuracy::Int=15)
		new( obj, Decoder(obj.domain,accuracy))
	end
end

#---------------------------------------------------------------------
@doc """
	```construct!( benform, exprprofile)``` -> ```response```

The expression profile does not change benform, but instead benform
simply evaluates exprprofile with no side-effects according to its
ability to minimise the benform's Objective function.
"""
function Rheolecsis.construct!( benform::BinaryEnform, eprofile::Vector{Vector{Int}})
	# First interpret the expression profile ...
	cprofile = interpret( benform, eprofile)

	# ... then perform any constructions ...
	# (None)

	# ... and finally record the response:
	benform.objective.( cprofile)
end

#---------------------------------------------------------------------
@doc """
	```exprprofile( benform, data)```

Encode the list of data values as an expression profile.
"""
function exprprofile( benform::BinaryEnform, data::Vector{Float64})
	encode( benform.decoder, data)
end

#---------------------------------------------------------------------
@doc """
	```interpret( benform, eprofile)```

Interpret the given expression profile as a construction profile.
"""
function interpret( benform::BinaryEnform, eprofile::Vector{Vector{Int}})
	benform.decoder.( eprofile)
end

#---------------------------------------------------------------------
@doc """
	```interpret( benform, expression)```

Interpret the expression as an individual construction.
"""
function interpret( benform::BinaryEnform, expression::Vector{Int})
	benform.decoder( expression)
end
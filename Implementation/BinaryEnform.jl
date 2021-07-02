#=====================================================================
# BinaryEnform: A simple Enform that evaluates explorations according
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

A non-interacting Enform that evaluates a according to its ability to
minimise an Objective function.
"""
struct BinaryEnform <: Enform
	objective::Objective	# Objective function for evaluating profiles
	decoder::Decoder		# Binary decoder
	arity::Int				# Arity of constructions and decoder
	curiosity::Int			# Max number of niche explorations

	function BinaryEnform( obj::Objective, accuracy::Int=15,
									arity::Int=2, curiosity::Int=0)
		new( obj, Decoder(obj.domain,accuracy,arity), arity, curiosity)
	end
end

#---------------------------------------------------------------------
@doc """
	```construct!( benform, exprprofile)``` -> ```response```

The exploration profile does not change benform, but instead benform
simply evaluates exprprofile with no side-effects according to its
ability to minimise the benform's Objective function.
"""
function Rheolecsis.construct!( enform::BinaryEnform, exploration::Construction{Int})
	indeterminacy = map(exploration) do x
		# Locate all exploration indeterminacies:
		x .>= enform.arity
	end

	if any(any.(indeterminacy))
		# Interpret indeterminate constructions:
		len = length(exploration)
		objectives = fill(Inf,len)
		nindet = sum.(indeterminacy)
		for i in 1:len
			# Convert Explorations to Constructions:
			expl = rand(0:enform.arity-1,(nindet[i],enform.curiosity))
			for j in 1:enform.curiosity
				# Perform an individual exploration:
				exploration[i][indeterminacy[i]] = expl[:,j]
				objeval = enform.objective( interpret( enform, exploration[i]))
				if objeval < objectives[i]
					objectives[i] = objeval
				end
			end
		end
		objectives
	else
		# Imterpret constructions deterministically:
		enform.objective.( interpret( enform, exploration))
	end
end

#---------------------------------------------------------------------
@doc """
	```exprprofile( benform, data)```

Encode the list of data values as an exploration profile.
"""
function exprprofile( benform::BinaryEnform, data::Vector{Float64})
	encode( benform.decoder, data)
end

#---------------------------------------------------------------------
@doc """
	```interpret( benform, eprofile)```

Interpret the given exploration profile as a construction profile.
"""
function interpret( benform::BinaryEnform, eprofile::Construction{Int})
	benform.decoder.( eprofile)
end

#---------------------------------------------------------------------
@doc """
	```interpret( benform, exploration)```

Interpret the exploration as an individual construction.
"""
function interpret( benform::BinaryEnform, exploration::Vector{Int})
	benform.decoder( exploration)
end
#=====================================================================
# Abstract Affordance interface: General-purpose Affordances for RA's.
# Affordance is the home of all random structural variation in a
# rheolectic system.
=====================================================================#
affordanceunittest = false					# Set unit test environment
if affordanceunittest
	#------------------------- Unit Testing --------------------------
	function unittest()
		println("\n============ Unit test Affordance: ===============")
		println("Create a 7-data Affordance of 5-ary symbols:")
		mummy = Affordance(7,5)
		display( mummy)
		println("\n... which we then mutate at the 2nd, 3rd and 5th loci:")
		mutate!( mummy, BitVector([0,1,1,0,1,0,0]))
		display( mummy)
	
		println("Now create a second Affordance of the same size:")
		daddy = Affordance(7,5)
		display( daddy)
		println("\n... and recombine them:")
		sally, billy = recombine(mummy,daddy)
		display( sally)
		display( billy)
	end
end

#====================================================================#
@doc raw"""
    ```Affordance```

General-purpose Affordance: a Vector of symbols from an Int alphabet.
"""
struct Affordance
	arity::Int					# Range (arity) of affordance symbols
	data::Vector{Int}			# The Affordance data
	stability::Float64			# Stability of this Affordance

	function Affordance( len, arity)
		new( arity, rand(0:arity-1,len), 1.0)
	end

	function Affordance( prescribe::Vector{Int}, arity)
		new( arity, prescribe, 1.0)
	end

	function Affordance( arity, data, stability)
		new( arity, data, stability)
	end
end

#---------------------------------------------------------------------
@doc raw"""
    ```size( affordance)``` -> ```(length,arity)```

Return length and arity of the Affordance
"""
function size( aff::Affordance)
	(length(aff.data),aff.arity)
end

#---------------------------------------------------------------------
@doc raw"""
    ```arity( affordance)```

Return arity of the Affordance
"""
function arity( aff::Affordance)
	aff.arity
end

#---------------------------------------------------------------------
@doc raw"""
    ```mutate!( affordance, loci)```

Mutate the Affordance at the given loci.
"""
function mutate!( aff::Affordance, loci::BitVector)
	# Mutate loci and wrap symbols around the alphabet range:
	aff.data[loci] =
		mod.( aff.data[loci] + rand([-1,1],sum(loci)), aff.arity)

	aff
end

#---------------------------------------------------------------------
@doc raw"""
    ```recombine( mummy, daddy, xPt)```

Recombine mummy and daddy Affordances at random crossover locus, and
return the two resulting progeny.
"""
function recombine( mummy::Affordance, daddy::Affordance)
	xPt = rand(1:length(mummy.data)-1)		# Crossover point
	sally = deepcopy.(mummy.data)			# mummy-based progeny
	billy = deepcopy.(daddy.data)			# daddy-based progeny

	sally[xPt+1:end] = daddy.data[xPt+1:end]
	billy[xPt+1:end] = mummy.data[xPt+1:end]

	(
		Affordance(mummy.arity,sally,mummy.stability),
		Affordance(daddy.arity,billy,daddy.stability)
	)
end
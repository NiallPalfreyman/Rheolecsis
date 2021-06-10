#=====================================================================
# Abstract Affordance interface: General-purpose Affordances for RA's.
=====================================================================#
affordanceunittest = true					# Set unit test environment
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
	alphabet::UnitRange			# Range (arity) of affordance symbols
	data::Vector{Int}			# The Affordance data
	stability::Float64			# Stability of this Affordance

	function Affordance( len, arity)
		new( 1:arity, rand(1:arity,len), 1.0)
	end

	function Affordance( alphabet, data, stability)
		new( alphabet, data, stability)
	end
end

#---------------------------------------------------------------------
@doc raw"""
    ```size( affordance)``` -> ```(length,arity)```

Return length and arity of the Affordance
"""
function size( affordance::Affordance)
	(length(affordance.data),length(affordance.alphabet))
end

#---------------------------------------------------------------------
@doc raw"""
    ```mutate!( affordance, loci)```

Mutate the Affordance at the given loci.
"""
function mutate!( affordance::Affordance, loci::BitVector)
	# Mutate loci and wrap symbols around the alphabet range:
	affordance.data[loci] = 1 .+ mod.(
		affordance.data[loci] + rand([-1,1],sum(loci)) .-1,
		length(affordance.alphabet)
	)

	affordance
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
		Affordance(mummy.alphabet,sally,mummy.stability),
		Affordance(daddy.alphabet,billy,daddy.stability)
	)
end
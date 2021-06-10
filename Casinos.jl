casinosunittest = false						# Set up unit testing

module Casinos
#=====================================================================
# Module Casinos: A repository for fast access to random numbers.
=====================================================================#
using Random

export Casino, draw, shuffle!

#====================================================================#
@doc raw"""
	```REDUNDANCY```

Integer constant indicating the redundancy of the Casino repository.
"""
const REDUNDANCY = 5

@doc raw"""
	```Casino```

A Casino encapsulates a repository that makes avaiable fast access to
2-D blocks of random numbers.
"""
mutable struct Casino
	nrows::Int				# Maximum num of drawable rows
	ncols::Int				# Maximum num of drawable columns
	vault					# Repository of random numbers in [0,1)
	bernoulli				# Dictionary of Bernoulli outcomes

	function Casino()
    	new(0,0,rand(0,0),Dict{Float64,BitMatrix}())
	end
end

#---------------------------------------------------------------------
@doc raw"""
	```draw( casino, nrows, ncols)```

Draw the required number of rows and columns from the casino, first
ensuring that it is large enough for the withdrawal.
"""
function draw( casino::Casino, nrows::Int, ncols::Int)
	if		nrows > casino.nrows || ncols > casino.ncols
		# Repository is too small - reallocate:
		reallocate!( casino, nrows, ncols)
	end

	access( casino.vault, nrows, ncols)
end

#---------------------------------------------------------------------
@doc raw"""
	```draw( casino, nrows, ncols, bernoulli)```

Draw (nrows x ncols) Boolean coin-toss values from the casino, using
a bernoulli-biased coin.
"""
function draw( casino::Casino, nrows::Int, ncols::Int, bernoulli::Float64)
	if		nrows > casino.nrows || ncols > casino.ncols
		# Vault is too small - reallocate:
		reallocate!( casino, nrows, ncols)
	end

	# Ensure bernoulli is a probability:
	bernoulli = max( 0, min( 1, bernoulli))

	# Ensure Bernoulli entry exists in the Dictionary:
	if !haskey( casino.bernoulli, bernoulli)
		casino.bernoulli[bernoulli] = (casino.vault .< bernoulli)
	end

	access( casino.bernoulli[bernoulli], nrows, ncols)
end

#---------------------------------------------------------------------
@doc raw"""
	```shuffle!( casino)```

Reassign vault values, retaining current size, and update Bernoulli
outcomes to fit.
"""
function shuffle!( casino::Casino)
    rand!( casino.vault)
	for coin ∈ casino.bernoulli
		casino.bernoulli[coin[1]] = (casino.vault .< coin[1])
	end
end

#---------------------------------------------------------------------
@doc raw"""
	```reallocate!( casino, nrows, ncols)```

Change (typically increase) nrows and ncols, then reallocate vault
accordingly.
"""
function reallocate!( casino::Casino, nrows::Int, ncols::Int)
	casino.nrows = nrows
	casino.ncols = ncols
	casino.vault = rand( (nrows+1)*REDUNDANCY, (ncols+1)*REDUNDANCY)
	casino.bernoulli = Dict()
end

#---------------------------------------------------------------------
@doc raw"""
    ```access( matrix, nrows, ncols)```

Access the required number of rows and columns from a matrix, on the
assumption that the matrix is big enough.
"""
function access( matrix, nrows::Int, ncols::Int)
	# Choose random offsets and strides for drawing on the matrix:
	reprows, repcols = size(matrix)
	offset_r = rand( 1 : (reprows-nrows))
	stride_r = (nrows <= 1) ? 1 :
					rand( 1 : (reprows-offset_r) ÷ (nrows-1))
	offset_c = rand( 1 : (repcols-ncols))
	stride_c = (ncols <= 1) ? 1 :
					rand( 1 : (repcols-offset_c) ÷ (ncols-1))

	# Return a randomly chosen table of slices from the matrix:
	@view matrix[
		(offset_r : stride_r : (offset_r + (nrows-1)*stride_r)),
		(offset_c : stride_c : (offset_c + (ncols-1)*stride_c))
	]
end

end		# ... of module Casinos

#========================= Unit testing =============================#
if casinosunittest
	using .Casinos
	function unittest()
		println("\n============ Unit test Casinos: ===============")
		println("Create an empty Casino:")
		casino = Casino()
		display( casino)
		println("\nDraw a (1x2) table from casino, then redisplay:")
		display( draw( casino, 1, 2))
		display(casino)
		println("\nDraw (2x3) coins with Bernoulli probability 0.7:")
		display( draw( casino, 2, 3, 0.7))
		display(casino)
		println("\nDraw (1x3) coins with Bernoulli probability 0.3:")
		display( draw( casino, 1, 2, 0.3))
		display(casino)
		println("\nFinally, we reshuffle the casino and redisplay:")
		shuffle!(casino)
		display(casino)
	end
end
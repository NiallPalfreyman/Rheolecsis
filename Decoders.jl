decodersunittest = false					# Set up unit testing

module Decoders
#=====================================================================
# A decoder of Vector{Int} into Float64s.
=====================================================================#
export Decoder, encode

#====================================================================#
@doc """
    ```Decoder```

Decoder between n-ary vectors and Float64 vectors.
"""
struct Decoder
	base::Int					# n-ary base alphabet
	lo::Vector{Float64}			# Low value of each domain dimension
	ndims::Int					# Number of dimensions in domain
	nplaces::Int				# Number of places encoding each dimension
	decoder::Matrix{Float64}	# Matrix of place contributions

	"Construct a new Decoder instance"
	function Decoder( dom=[[0.0,1.0]], nplaces::Int=15, base::Int=2)
		# Set up decoding apparatus ...
		spans = [dom[i][2]-dom[i][1] for i in 1:length(dom)]
		nary_places = (1/base).^(1:nplaces)
		nary_places = nary_places / sum(nary_places)
		# ... then create Decoder instance:
		new( base, map(x->x[1],dom), length(dom),
				nplaces, (spans*nary_places'))
	end
end

#---------------------------------------------------------------------
@doc """
    ```alphabet(decod)```

Return the alphabet of this Decoder.
"""
function alphabet(decod::Decoder)
	0:decod.base-1
end
		
#---------------------------------------------------------------------
@doc """
    ```(decod)(code)```

Decode Vector{Int} code into Vector{Float64} data.
"""
function (decod::Decoder)( code::Vector{Int})
	vec(
		decod.lo .+ sum(
			decod.decoder .*
				transpose(
					reshape( code, (decod.nplaces,decod.ndims))
				),
			dims=2
		)
	)
end
		
#---------------------------------------------------------------------
@doc """
    ```encode( decod, data)```

Encode Vector{Float64} data into Vector{Int} code.
"""
function encode( decod::Decoder, data::Vector{Float64})
	proflength = length(data) ÷ decod.ndims
	encoding =
		[zeros(Int,decod.ndims*decod.nplaces) for _ ∈ 1:proflength]

	for code ∈ 1:proflength
		letter = 1
		for dim ∈ 1:decod.ndims
			value = data[dim + (code-1)*decod.ndims] - decod.lo[dim]
			for place ∈ 1:decod.nplaces
				encoding[code][letter] = value ÷ decod.decoder[dim,place]
				value = rem( value, decod.decoder[dim,place])
				letter += 1
			end
		end
	end

	encoding
end
		
end		# ... of module Decoders

#========================= Unit testing =============================#
if decodersunittest
	using .Decoders
	function unittest()
		println("\n============ Unit test Decoders: ===============")
		println("Testing NCoder for the data:")
		println("[1.6667,4.3333,-4.6000,1.3333,3.6667,1.0000] ...")
		println()

		decod = Decoder( [[1,2],[3,5],[-7,5]], 20, 2)
		data = [1.6667,4.3333,-4.6000,1.3333,3.6667,1.0000]
		expressions = encode( decod, data)
		println( "Encoded: ", expressions)
		decoded = decod.(expressions)
		println( "Decoded: ", map(decoded) do value round.(value,digits=4) end)
	end
end
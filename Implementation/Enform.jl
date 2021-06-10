#=====================================================================
# Abstract Enform interface: Codefines the objective function for
# optimisation. (Environmental informing)
=====================================================================#
@doc raw"""
	```Construction```

General type for all Niche Construction profiles.
"""
Construction{T} = Vector{Vector{T}}

@doc raw"""
	```Response```

General type for all Niche Construction responses.
"""
Response = Vector{Float64}

#---------------------------------------------------------------------
@doc raw"""
	```Enform```
	
Interface for all Enforms
"""
abstract type Enform end;

#---------------------------------------------------------------------
@doc raw"""
	```construct!( enform, profile) -> Response```

Construct Enform according to a construction profile, in general
generating changes that result in an success scoring of the profile.
"""
function construct!( enform::Enform, profile::Construction)
	missing												# Response
end

#---------------------------------------------------------------------
@doc raw"""
	```interpret( enform, profile)``` -> ```String```

For display purposes, interpret the given construction profile within the
given Enform as a string.
"""
function interpret( enform::Enform, profile::Construction)
	missing										# Printable decoding
end
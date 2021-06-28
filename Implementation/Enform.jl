#=====================================================================
# Abstract Enform interface: Codefines the objective function for
# optimisation. (Environmental informing)
# An Enform is the home of all external meaning of a rheolectic
# system, and will generally involve spatial flows.
=====================================================================#
@doc """
	```Construction```

General type for all Niche Construction profiles.
"""
Construction{T} = Vector{Vector{T}}

@doc """
	```Response```

General type for all Niche Construction responses.
"""
Response = Vector{Float64}

#---------------------------------------------------------------------
@doc """
	```Enform```
	
Interface for all Enforms
"""
abstract type Enform end;

#---------------------------------------------------------------------
@doc """
	```construct!( enform, profile) -> Response```

Construct Enform according to a construction profile, in general
generating changes that result in an success scoring of the profile.
"""
function construct!( enform::Enform, profile::Construction)
	missing												# Response
end

#---------------------------------------------------------------------
@doc """
	```interpret( enform, profile)``` -> ```String```

For display purposes, interpret the given construction profile within the
given Enform as a string.
"""
function interpret( enform::Enform, profile::Construction)
	missing										# Printable decoding
end
objectivesunittest = false					# Set up unit testing

module Objectives
#=====================================================================
# A collection of De Jong and Watson objective functions.
=====================================================================#
#using Base: Number
using Plots, SpecialFunctions
export Objective, depict

#====================================================================#
@doc raw"""
    ```Objective```

An objective function for testing RAs.
"""
struct Objective
	fun
	dimension::Int
	domain::Vector{Vector}

	"Construct a new Objective instance"
	function Objective( fun=6, dim=0, dom=[[-Inf,Inf]])
		if fun isa Int
			# Use a function from the test suite:
			if dim == 0
				# Use default dimension:
				fun, dim, dom = TEST_FUNCTION[fun]
			else
				# Use one of test function suite:
				fun = TEST_FUNCTION[fun][1]
			end
		end

		# Check objective function's domain and dimension:
		if dom[1] isa Number
			println(fun, dim, dom)
			# Client has forgotten [[double brackets]]:
			dom = [[dom[1],dom[2]]]
		end
		if any( length.(dom) .!= 2) || any( getindex.(dom,2) .<= getindex.(dom,1))
			error( "Domain specification is invalid")
		end
		if length(dom) > 1
			# In this case we discard requested dim:
			dim = length(dom)
		else
			dom = [dom[1] for _ in 1:dim]
		end
		
		# If we're here, then dim == length(dom) and all is ok:
		new( fun, dim, dom)
	end
end

#---------------------------------------------------------------------
@doc raw"""
    ```rand( obj, n)```

Return a vector of n random points within the objective function
domain.
"""
function rand( obj::Objective, n::Int)
	if any(any(abs(obj.domain)==Inf))
		error( "Cannot sample an infinite domain")
	end

	lo = getindex.(obj.domain,1)
	dif = getindex.(obj.domain,2) - lo

	[lo + dif .* rand(n) for _ in 1:n]
end

#---------------------------------------------------------------------
@doc raw"""
    ```obj( x)```

Evaluate Objective function for the given vector argument x.
"""
function (obj::Objective)(x::Vector{Float64})
	obj.fun(x)
end

#---------------------------------------------------------------------
@doc raw"""
    ```obj( x)```

Evaluate Objective function for the given number argument x.
"""
function (obj::Objective)(x::Real)
	obj.fun([x])
end

#---------------------------------------------------------------------
@doc raw"""
    ```depict( obj, dims, centre, radius; blob)```

Depict given dimension(s) of objective function over rectangular
neighbourhood with given centre and radius.
"""
function depict( obj, dims=1:min(2,obj.dimension), centre=NaN, radius=NaN; blob=NaN)
	dim = obj.dimension						# Store for multiple Use

	if isempty(dims)
		# Plot a slice through all dimensions of objective:
		upb = getindex.(obj.domain,2)
		args = [getindex.(obj.domain,1) for _ in 0:dim]
		for i in 1:dim
			args[i+1][1:i] = upb[1:i]
		end
		return plot( 0:obj.dimension, obj.(args))
	end
	
	# dims is from this point on correctly defined.
	if centre === NaN
		if any(abs.(Iterators.flatten(obj.domain)).==Inf)
			error( "Cannot display an infinite domain")
		end
		# Extract centre and radius vectors of domain:
		centre = sum.(obj.domain[dims])/2
		radius = (getindex.(obj.domain[dims],2) - getindex.(obj.domain[dims],1))/2
	elseif radius === NaN
		radius = ones(dim)
	end

	# All parameters are now present and correct:
	nticks = 101;			# Number of data ticks in depiction
	nsteps = nticks - 1;	# Number of gradation steps
	glb = max.(getindex.(obj.domain[dims],1),centre-radius)
	lub = min.(getindex.(obj.domain[dims],2),centre+radius)
	midpt = sum.(obj.domain)/2

	len = length(dims)
	if len == 1
		# Use plot for single dimension:
		x = glb[1]:(lub[1]-glb[1])/nsteps:lub[1]
		args = fill(midpt,nticks)
		for i in 1:nticks
			args[i] = copy(midpt)
			args[i][dims] = [x[i]]
		end
		depiction = plot(x,obj.(args))
		plot!(depiction,xlabel="x",ylabel="Evaluation")

		if blob !== NaN
			# Display the blob:
			plot!(depiction,[blob[1]],[blob[2]],st=:scatter,
						ms=10,mc=:lime,shape=:star5,leg=:none)
		end
	elseif len == 2
		# Construct arguments for contour map:
		x = glb[1]:(lub[1]-glb[1])/nsteps:lub[1]
		y = glb[2]:(lub[2]-glb[2])/nsteps:lub[2]
		args = fill(midpt,(nticks,nticks))
		for i in 1:nticks, j in 1:nticks
			args[i,j] = copy(midpt)
			args[i,j][dims] = [x[j],y[i]]
		end
		depiction = plot(x,y,obj.(args),st=:contourf)
		plot!(depiction,xlabel="x",ylabel="y")

		if blob !== NaN
			# Display the blob:
			plot!(depiction,[blob[1]],[blob[2]],st=:scatter,
						ms=10,mc=:lime,shape=:star5,leg=:none)
		end
	else
		error( "Cannot depict more than 2 dimensions")
	end

	depiction
end

#---------------------------------------------------------------------
@doc raw"""
    ```hintless( x::Vector)```

Hinton and Nowlan's (1987) hintless function.
"""
function hintless( x::Vector)
	any(x.!=1) ? 0.0 : 1.0
end

#---------------------------------------------------------------------
@doc raw"""
    ```mepi( x::Vector)```

Watson's (2007) maximally epistatic objective function.
"""
function mepi( x::Vector)
	dim = length(x)
	if dim == 1
		1
	else
		middle = dim ÷ 2
		dim * (1 - prod(+x) - prod(1 .- x)) +
			mepi(x[1:middle]) + mepi(x[middle+1:end])
	end
end

#---------------------------------------------------------------------
@doc raw"""
    ```TEST_FUNCTION```

A suite of standard GA test functions. fun is n-th test function over
a default domain. Function 18 comes from Watson (2007).
"""
TEST_FUNCTION = [
# Function 1. Minimum f(0) = 1:
	((x -> abs(x[1]) + cos(x[1])), 1, [[-20,20]]),
# Function 2. Minimum f(0) = 0:
	((x -> abs(x[1]) + sin(x[1])), 1, [[-20,20]]),
# Function 3. Minimum f(0,0) = 1:
	((x -> 1 + sum(abs2.(x - [4,3]))), 2, [[-3,7]]),
# Function 4. Minimum f(1,1) = 0:
	((x -> sum(100*(x[2:end] - x[1:end-1].^2).^2 + (1 .- x[1:end-1]).^2)), 2, [[-1,1]]),
# Function 5. Minimum f(9.6204) = -100.22:
	((x -> (abs2(x[1])+x[1]) * cos(x[1])), 1, [[-10,10]]),
# Function 6. Minimum f(9.039,8.668) = -18.5547:
	((x -> x[1]*sin(4*x[1]) + 1.1*x[2]*sin(2*x[2])), 2, [[0,10]]),
# Function 7. Minimum f(0.9039,0.8668) = -18.5547 ???:
	((x -> x[2]*sin(4*x[1]) + 1.1*x[1]*sin(2*x[2])), 2, [[0,10]]),
# Function 8. Minimum f(0,0) = 0:
	((x -> 10*length(x) + sum(abs2.(x) - 10*cos.(2*pi*x))), 2, [[-4,4]]),
# Function 9. Minimum f(0,0) = 0:
	((x -> 1 + sum(x.^2/4000) - prod(cos.(x))), 2, [[-10,10]]),
# Function 10. Minimum f(1.897,1.006) = -0.5231:
	((x -> 0.5 + (sin(sqrt(sum(x.^2))).^2 - 0.5) ./ (1 + 0.1*sum(x.^2))), 2, [[-5,5]]),
# Function 11. Minimum f(0,0) = 0:
	((x -> sum(abs.(x)) + sum(x.^2).^0.25 .* sin(30*(((x[1]+0.5).^2 + x[2].^2).^0.1))),
		2, [[-10,10]]),
# Function 12. Minimum f(1,16606) = -0.3356:
	((x -> besselj(0,sum(x.^2)) + 0.1*sum(abs.(1 .- x))), 2, [[-5,5]]),
# Function 13. Minimum f(-14.58,-20) = -23.806:
	((x -> x[1].*sin(sqrt(abs(x[1]-(x[2]+9)))) - (x[2]+9).*sin(sqrt(abs(x[2]+0.5*x[1]+9)))),
		2, [[-20,20]]),
# Function 14. Hinton and Nowlan's hintless function:
	(hintless, 30, [[0,1]]),
# Function 15. Watson's maximally epistatic function:
	(mepi, 128, [[0,1]]),
# Function 16. Trivial test function (abs(x)):
	((x -> abs(x[1])), 1, [[-5,5]])
]
		
end		# ... of module Objectives

#========================= Unit testing =============================#
if objectivesunittest
	using .Objectives
	function unittest()
		println("\n============ Unit test Objectives: ===============")
		obj = Objective(6)
		println(
			"Objective function 6 has a minimum at the point " *
			"[9.039,8.668] of ", obj([9.039,8.668])
		)
		depict(obj, blob=[9.039,8.668,-18.5547])
	end
end
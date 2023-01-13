"""
Caputo sense fractional derivative algorithms, please refer to [Caputo derivative](https://en.wikipedia.org/wiki/Fractional_calculus#Caputo_fractional_derivative) for more details.
"""
abstract type Caputo <: FracDiffAlg end


"""
# Caputo sense fractional derivative.

    fracdiff(f::Function, α, start_point, end_point, step_size, ::Caputo)

### Example: 

```julia-repl
julia> fracdiff(x->x^5, 0.5, 0, 2.5, 0.0001, CaputoDirect())
```

Returns a tuple (**result**, **error**), which means the value of this derivative is 141.59714979764541, and the error estimate is 1.1532243848672914e-6.

Refer to [Caputo derivative](https://en.wikipedia.org/wiki/Fractional_calculus#Caputo_fractional_derivative)

!!! note
    ```Caputo Direct``` algorithms belong to direct computing, precise are ensured, but maybe cause more memory allocation and take more compilation time.

Using the direct mathematic expression:

```math
^CD_t^α=\\frac{1}{\\Gamma(n-α)}\\int_0^t\\frac{f^{(n)}(τ)}{(t-τ)^{α+1-n}}
```

As for the derivative inside the integral, we use the **Complex Step Differentiation** to obtain a more accurate value.
"""
struct CaputoDirect <: Caputo end

"""
# Caputo sense fractional derivative with first derivative known.

    fracdiff(fd, α, start_point, end_point, CaputoDirectFirstDiffKnown())

If the first order derivative of a function is already known, we can use this method to compute the fractional order derivative more precisely.

The input function should be the first order derivative of a function

### Example

```julia-repl
julia> fracdiff(x->5*x^4, 0.5, 0, 2.5, CaputoDirectFirstDiffKnown())
```
Return the semi-derivative of ``f(x)=x^5`` at ``x=2.5``.

Compared with **CaputoDirect** method, this method don't need to specify step size, more precision are guaranteed.
"""
struct CaputoDirectFirstDiffKnown <: Caputo end

"""
# Caputo sense fractional derivative with first and second derivative known.

    fracdiff(fd1, fd2, α, start_point, end_point, Caputo_Direct_First_Second_Diff_Known)

If the first and second order derivative of a function is already known, we can use this method to compute the fractional order derivative more precisely.


### Example

```julia-repl
julia> fracdiff(x->5*x^4, x->20*x^3, 0.5, 0, 2.5, Caputo_Direct_First_Second_Diff_known())
```
Return the semi-derivative of ``f(x)=x^5`` at ``x=2.5``.
    
Compared with **CaputoDirect** method, this method don't need to specify step size, more precision are guaranteed.
"""
struct Caputo_Direct_First_Second_Diff_Known <: Caputo end


"""
# Caputo sense Piecewise algorithm

    fracdiff(f, α, end_point, h, CaputoPiecewise())

Using piecewise linear interpolation function to approximate input function and combining Caputo derivative then implement summation.

### Example

```julia-repl
julia> fracdiff(x->x^5, 0.5, 2.5, 0.001, CaputoPiecewise())
```

Return the fractional derivative of ``f(x)=x^5`` at point ``x=2.5``.

```tex
@article{LI20113352,
title = {Numerical approaches to fractional calculus and fractional ordinary differential equation},
author = {Changpin Li and An Chen and Junjie Ye},
}
```

"""
struct CaputoPiecewise <: Caputo end



"""
# Caputo sense Diethelm computation
    
    fracdiff(f, α, end_point, h, CaputoDiethelm())

Using quadrature weights(derived from product trapezoidal rule) to approximate the derivative.

### Example

```julia-repl
julia> fracdiff(x->x, 0.5, 1, 0.007, CaputoDiethelm())
1.128378318687192
```

!!! info "Scope"
    0 < α < 1

Diethelm's method for computingn Caputo sense fractional derivative using [product trapezoidal rule](https://en.wikipedia.org/wiki/Trapezoidal_rule) and [Richardsin extrapolation](https://en.wikipedia.org/wiki/Richardson_extrapolation)

```tex
@article{10.1093/imanum/17.3.479,
author = {DIETTELM, KAI},
title = "{Generalized compound quadrature formulae for finite-part integrals}",
journal = {IMA Journal of Numerical Analysis},
doi = {10.1093/imanum/17.3.479},
}
```

"""
struct CaputoDiethelm <: Caputo end


"""
# Caputo sense fractioal derivative with p-th order precision.

    fracdiff(f, α, t, p, CaputoHighPrecision())

Use the high precision algorithm to compute the Caputo sense fractional derivative.

The **p** here is the grade of precision.
"""
struct CaputoHighPrecision <: Caputo end



"""
# Caputo sense fractional derivative high order approximation.

!!! info
    By using ```CaputoHighOrder``` method, we can set ``0<\\alpha<2``

### Example

```julia-repl
julia> fracdiff(x->x, 0.5, 1, 0.01, 2, CaputoHighOrder())
1.1283791670955123
```

```tex
@article{Li2017HighOrderAT,
  title={High-Order Approximation to Caputo Derivatives and Caputo-type Advection–Diffusion Equations: Revisited},
  author={Changpin Li and Minhao Cai},
  journal={Numerical Functional Analysis and Optimization},
  year={2017},
  volume={38},
  pages={861 - 890}
}
```
"""
struct CaputoHighOrder <: Caputo end
################################################################
###                    Type definition done                  ###
################################################################



function fracdiff(f::Union{Function, Number}, α::Float64, start_point, end_point, h::Float64, ::CaputoDirect)
    #checks(f, α, start_point, end_point)
    typeof(f) <: Number ? (end_point == 0 ? 0 : f/sqrt(pi*end_point)) : nothing
    #Using complex step differentiation to calculate the first order differentiation
    g(τ) = imag(f(τ+1*im*h) ./ h) ./ ((end_point-τ) .^α)
    result = quadgk(g, start_point, end_point) ./gamma(1-α)
    return result
end

function fracdiff(f::FunctionAndNumber, α::Float64, start_point, end_point::AbstractArray, h::Float64, ::CaputoDirect)::Vector
    #=
    ResultArray = Float64[]
    for (_, value) in enumerate(end_point)
        append!(ResultArray, fracdiff(f, α, start_point, value, h, CaputoDirect()))
    end
    return ResultArray
    =#
    result = map(x->fracdiff(f, α, start_point, x, h, CaputoDirect())[1], end_point)
    return result
end

function fracdiff(f::Union{Function, Number}, α::Float64, end_point, h::Float64, ::CaputoDirect)
    fracdiff(f::Union{Function, Number}, α::Float64, 0, end_point, h::Float64, CaputoDirect())
end

function fracdiff(f::FunctionAndNumber, α::Float64, end_point, h::Float64, ::CaputoPiecewise)
    typeof(f) <: Number ? (end_point == 0 ? (return 0) : (return f/sqrt(pi*end_point))) : nothing
    end_point == 0 ? (return 0) : nothing
    m = floor(Int, α)+1

    summation = zero(Float64)
    n = floor(Int, end_point/h)

    @fastmath @inbounds @simd for i in 0:n
        summation += W₅(i, n, m, α)*first_order(f, i*h, h)
    end

    result = summation*h^(m-α)/gamma(m-α+2)
    return result
end
function W₅(i, n, m, α)
    if i == 0
        return n^(m-α)*(m-α+1-n) + (n-1)^(m-α+1)
    elseif i == n
        return 1
    else
        return (n-i-1)^(m-α+1) + (n-i+1)^(m-α+1) - 2*(n-i)^(m-α+1)
    end
end
# Deploy Complex Step Differentiation to compute the first order derivative.
first_order(f, point, h::Float64) = imag(f(point + im*h))/h


function fracdiff(f::FunctionAndNumber, α::Float64, end_point::AbstractArray, h::Float64, ::CaputoPiecewise)::Vector
    result = map(x->fracdiff(f, α, x, h, CaputoPiecewise()), end_point)
    return result
end


#=
Caputo Diethelm algorithm
=#
function fracdiff(f::FunctionAndNumber, α::Float64, end_point::Number, h::Float64, ::CaputoDiethelm)
    #checks(f, α, 0, end_point)
    typeof(f) <: Number ? (end_point == 0 ? 0 : f/sqrt(pi*end_point)) : nothing
    N = round(Int, end_point/h)
    result = zero(Float64)

    @fastmath @inbounds @simd for i in 0:N
        result += quadweights(i, N, α)*(f(end_point-i*h) - f(0))
    end

    return result*h^(-α)/gamma(2-α)
end
function quadweights(n, N, α)
    if n == 0
        return 1
    elseif  0 < n < N
        return (n+1)^(1-α) - 2*n^(1-α) + (n-1)^(1-α)
    elseif n == N
        return (1-α)*N^(-α) - N^(1-α) + (N-1)^(1-α)
    end
end

function fracdiff(f, α::Float64, end_point::AbstractArray, h::Float64, ::CaputoDiethelm)::Vector
    result = map(x->fracdiff(f, α, x, h, CaputoDiethelm()), end_point)
    return result
end


#=
Caputo sense high precision algorithm
=#
function fracdiff(y::FunctionAndNumber, α, t, p::Integer, ::CaputoHighPrecision)
    h = t[2]-t[1]
    t = t[:]
    n = length(t)
    y = y.(t)
    q = ceil(Int, α)
    r::Int = max(p, q)
    R = reverse(Vandermonde(collect(0:(r-1)).*h))
    c = inv(R)*y[1:r]
    u = 0
    du = 0
    for i = 1:r
        u = u.+c[i]*t.^(i-1)
    end
    if q < r
        for i in (q+1):p
            du = du.+c[i]*t.^(i-1-α)*gamma(1)/gamma(i-α)
        end
    end

    v = y[:] - u[:]
    dv = fracdiff(v, α, t, p, GL_High_Precision())
    dy = dv[:] + du[:]
    return dy
end

function fracdiff(f::FunctionAndNumber, α, T, h, p::Integer, ::CaputoHighOrder)
    n::Int64 = round(Int, T/h)
    A = wj(n, p, α)
    B = fj(n, T, f)
    C = ones(1, n)
    hh = h^(-α)/(gamma(1-α))
    D = C*A*B*hh
    return D[1]
end

function wj(n::Int64, r::Int64, α)
    A=zeros(n, n+1)
    for iw=1:r-2
        for jw in 1:iw+1
            A[iw, jw]=w(iw+1-jw, iw+1, iw, n, α)
        end
    end
    for iw=r-1:n
        for jw=iw-r+2:iw+1
            A[iw, jw]=w(iw+1-jw, r, iw, n, α)
        end
    end
    return A
end

function w(i::Int64, r, j, n, a)
    ar = ones(r-1)
    br = ones(r-1)
    for lj in 1:r-2
        jj = r-lj-1
        kj = r-2
        tj = i-1
        aj = collect(Int64, 0:tj)
        bj = collect(Int64, tj+2:kj+1)
        cj = [aj; bj]
        dj = collect(Int64, -1:tj-1)
        ej = collect(Int64, tj+1:kj)
        fj = [dj; ej]
        yj = binomial.(cj, jj)
        pj = binomial.(fj, jj)
        sj = 1
        tj = 1
        for m in 1:jj
            sj = sj.*yj[:, m]
            tj = tj.*pj[:, m]
            ar[lj] = sum(sj)
            br[lj] = sum(tj)
        end
    end
    s=0
    for l=1:r-1
        k=1
        for m1=1:l
            k=k/(m1-a)
        end
        k=k*factorial(l)
        k=k*(ar[l]*((n-j)^(l-a))-br[l]*((n-j+1)^(l-a)))
        s=s+k
    end
    s=s*((-1)^(i+1))/(factorial(i)*factorial(r-1-i))
    return s
end

function fj(n::Int64, T, fy)
    B = zeros(n+1)
    for i2 = 1:n+1
        B[i2] = fy(T*(i2-1)/n)
    end
    return B
end
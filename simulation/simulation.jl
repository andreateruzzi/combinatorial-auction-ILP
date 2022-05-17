include("/Users/andreateruzzi/Desktop/combinatorial_auction_ILP/cap_juMP_julia/auction.jl") 
using .CAP, JuMP, HiGHS, Plots

n = 8             #number of items
m = 2             #number of bidders
subset = true     #restricting valuations to n^2 instead of 2^n
display = true    #showing details of integer program solver

M, v, S = CAP.auction(n, m, subset) 
CAP.cap_solver(M, S, HiGHS.Optimizer, display)
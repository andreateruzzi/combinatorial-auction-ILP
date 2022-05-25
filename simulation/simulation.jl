include("/Users/andreateruzzi/Desktop/combinatorial_auction_ILP/cap_juMP_julia/auction.jl") 
using .CAP, JuMP, HiGHS

m = 10              #number of items
n = 1               #number of bidders | wlog, set m=1  for a faster simulation
subset = true      #restricting valuations to n^2 instead of 2^n
display = true     #showing details of integer program solver

W, Z= CAP.cap_solver(M, S, HiGHS.Optimizer, display)
w, z = CAP.greedy_solver(M,S)
println(Z/z)

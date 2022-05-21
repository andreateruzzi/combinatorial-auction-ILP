include("/Users/andreateruzzi/Desktop/combinatorial_auction_ILP/cap_juMP_julia/auction.jl") 
using .CAP, JuMP, HiGHS

m = 9              #number of items
n = 1               #number of bidders | wlog, set m=1  for a faster simulation
subset = true      #restricting valuations to n^2 instead of 2^n
display = false     #showing details of integer program solver

for m in 3:20
    M, v, S = CAP.auction(m, n, subset) 
    W, Z= CAP.cap_solver(M, S, HiGHS.Optimizer, display)
    w, z = CAP.greedy_solver(M,S)
    print(Z/z, "\n")
end

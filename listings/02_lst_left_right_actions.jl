# tex-file: 02_liouv_space.tex
# tex-label: lst:left-right-actions
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate("/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"; io=devnull)
using ITensors

# ===== LISTING =====
using ProcessTensors

sites = siteinds("S=1/2", 1)
sites_L = liouv_sites(sites)
sL = only(sites_L)

A_L = op("Sx_L", sL)        # vec(Sx * rho)
B_R = op("Sz_R", sL)        # vec(rho * Sz)
A_jump = op("S-_Jump", sL)  # vec(S- * rho * S+)

# ===== CHECKS =====
@assert dim(sL) == 4
@assert inds(A_L) == inds(B_R) == inds(A_jump)

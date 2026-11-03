# tex-file: 02_liouv_space.tex
# tex-label: lst:liouvillian-construction
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate("/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"; io=devnull)

using ProcessTensors

sites = siteinds("S=1/2", 1)
sites_L = liouv_sites(sites)

# ===== LISTING =====
H = OpSum()
H += 0.7, "Sx", 1
H += 0.2, "Sz", 1

L_H = liouvillian_mpo(H, sites_L)
L_open = liouvillian_mpo(
    H,
    sites_L;
    jump_ops=[(0.1, "S-", 1)],
)

# ===== CHECKS =====
@assert length(L_H) == 1
@assert length(L_open) == 1

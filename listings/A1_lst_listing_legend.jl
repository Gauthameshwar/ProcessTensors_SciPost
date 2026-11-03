# tex-file: A1_code_listings.tex
# tex-label: lst:listing-legend
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate(get(ENV, "PROCESSTENSORS_JL", "/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"); io=devnull)

# ===== LISTING =====
using ITensors, ProcessTensors

s = Index(2, "s")                       # ITensor index
psi = ITensor([1.0, 0.0], s)
sites = siteinds("S=1/2", 1)

rho = to_dm(MPS(sites, ["Up"]))         # ProcessTensors converter + MPS
H = OpSum()
H += 0.7, "Sx", 1
L = liouvillian_mpo(H, liouv_sites(sites))

# ===== CHECKS =====
@assert length(sites) == 1
@assert length(L) == 1

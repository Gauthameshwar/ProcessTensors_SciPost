# tex-file: 02_liouv_space.tex
# tex-label: lst:hilbert-to-liouville
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate("/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"; io=devnull)

# ===== LISTING =====
using ProcessTensors

sites = siteinds("S=1/2", 3)
sites_L = liouv_sites(sites)

psi1 = MPS(sites, ["Up", "Up", "Up"])
psi2 = MPS(sites, ["Dn", "Dn", "Dn"])
rho = to_dm([psi1, psi2]; coeffs=[0.8, 0.2])
rho_L = to_liouville(rho; sites=sites_L)

Id = OpSum()
Id += 1.0, "Id", 1
O = OpSum()
O += 1.0, "Sz", 2

Id_L = to_liouville(MPO(Id, sites); sites=sites_L)
O_L = to_liouville(MPO(O, sites); sites=sites_L)
normalisation = inner(Id_L, rho_L)
expectation = inner(O_L, rho_L)

# ===== CHECKS =====
@assert length(rho) == 3
@assert length(rho_L) == 3
@assert real(normalisation) ≈ 1
@assert real(expectation) ≈ 0.3

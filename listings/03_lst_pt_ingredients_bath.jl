# tex-file: 03_process_tensors.tex
# tex-label: lst:pt-ingredients-bath
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate("/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"; io=devnull)

using ITensors
using ProcessTensors

# ===== LISTING =====
bath_sites = siteinds("S=1/2", 1)
bath_sites_L = liouv_sites(bath_sites)

omega_E = 1.1
H_E = OpSum()
H_E += (omega_E / 2), "Sz", 1

psi_E0 = MPS(bath_sites, ["Dn"])
rho_E0 = to_dm(psi_E0)
rho_E0_L = to_liouville(rho_E0; sites=bath_sites_L)

g = 0.35
H_SE = OpSum()
H_SE += g, "Sz", 1, "Sz", 2

mode = spin_mode(
    bath_sites_L,
    H_E,
    rho_E0_L;
    coupling=H_SE,
)
environment = spin_bath([mode])

println(environment)

# ===== CHECKS =====
@assert length(environment.modes) == 1
@assert dim(only(environment.sites)) == 4

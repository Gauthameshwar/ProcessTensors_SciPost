# tex-file: A2_time_dynamics.tex
# tex-label: lst:appendix-liouville-tebd
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate("/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"; io=devnull)

# ===== LISTING =====
using ITensors, ProcessTensors
using ITensors.Ops: Trotter

sites = siteinds("S=1/2", 2)
sites_L = liouv_sites(sites)
psi0 = MPS(sites, ["Up", "Dn"])
rho_L0 = to_liouville(to_dm(psi0); sites=sites_L)

H = OpSum()
H += 1.0, "Sz", 1, "Sz", 2
H += 0.4, "Sx", 1
H += 0.4, "Sx", 2
jumps = [(0.15, "S-", 1), (0.15, "S-", 2)]

dt, T = 0.025, 0.1
rho_L_tebd = tebd(
    rho_L0, H, dt, T;
    jump_ops=jumps,
    alg=Trotter{2}(),
    maxdim=32,
    cutoff=1e-12,
)

# ===== CHECKS =====
@assert length(rho_L_tebd) == 2
@assert maxlinkdim(rho_L_tebd) <= 32

# tex-file: 03_process_tensors.tex
# tex-label: lst:choi-pt-mpo
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate(get(ENV, "PROCESSTENSORS_JL", "/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"); io=devnull)

using ITensors
using ProcessTensors
using ITensors.Ops: Trotter

system_sites = siteinds("S=1/2", 1)

h = 0.7
H_S = OpSum()
H_S += h, "Sx", 1
system = spin_system(system_sites, H_S)

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

dt = 0.05
nsteps = 3
pt_dense = build_process_tensor(
    system;
    method=Dense(),
    environment=environment,
    dt=dt,
    nsteps=nsteps,
    sys_alg=Trotter{2}(),
    progress=false,
)

# ===== LISTING =====
W = choi_pt_mpo(pt_dense)

j = 1
i = only(siteinds(W, j; tags="in", plev=0))
o = only(siteinds(W, j; tags="out", plev=0))
println((i, prime(i), o, prime(o)))
println(tr(W))

# ===== CHECKS =====
@assert occursin("tstep=1", string(i))
@assert occursin("tstep=1", string(o))
@assert !occursin("tstep=0", string(i))
@assert real(tr(W)) ≈ 8
@assert length(W) == 3

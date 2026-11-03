# tex-file: 03_process_tensors.tex
# tex-label: lst:pt-build-ace
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate("/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"; io=devnull)

using ITensors
using ProcessTensors
using ITensors.Ops: Trotter

system_sites = siteinds("S=1/2", 1)
H_S = OpSum()
H_S += 0.7, "Sx", 1
system = spin_system(system_sites, H_S)

dt = 0.05
nsteps = 3

bath_sites_1 = siteinds("S=1/2", 1)
bath_sites_1_L = liouv_sites(bath_sites_1)
H_1 = OpSum()
H_1 += 0.4, "Sz", 1
rho_1 = to_liouville(to_dm(MPS(bath_sites_1, ["Dn"])); sites=bath_sites_1_L)
coupling_1 = OpSum()
coupling_1 += 0.2, "Sz", 1, "Sz", 2
mode_1 = spin_mode(bath_sites_1_L, H_1, rho_1; coupling=coupling_1)

bath_sites_2 = siteinds("S=1/2", 1)
bath_sites_2_L = liouv_sites(bath_sites_2)
H_2 = OpSum()
H_2 += 0.5, "Sz", 1
rho_2 = to_liouville(to_dm(MPS(bath_sites_2, ["Up"])); sites=bath_sites_2_L)
coupling_2 = OpSum()
coupling_2 += 0.15, "Sz", 1, "Sz", 2
mode_2 = spin_mode(bath_sites_2_L, H_2, rho_2; coupling=coupling_2)

modes = [mode_1, mode_2]

# ===== LISTING =====
ace_environment = spin_bath(modes)

pt_ace = build_process_tensor(
    system;
    method=ACE(
        cutoff=1e-10,
        maxdim=512,
        compression=:canonzip,
    ),
    environment=ace_environment,
    dt=dt,
    nsteps=nsteps,
    sys_alg=Trotter{2}(),
    combine_alg=Trotter{2}(),
)

# ===== CHECKS =====
@assert pt_ace.nsteps == 3
@assert length(pt_ace.core) == 3
@assert maxlinkdim(pt_ace) >= 1

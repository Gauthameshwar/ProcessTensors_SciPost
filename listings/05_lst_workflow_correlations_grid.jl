# tex-file: 05_pt_workflows.tex
# tex-label: lst:workflow-correlations-grid
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate(get(ENV, "PROCESSTENSORS_JL", "/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"); io=devnull)

using ITensors
using ProcessTensors
using ITensors.Ops: Trotter

system_sites = siteinds("S=1/2", 1)
H_S = OpSum()
H_S += 1.0, "Sx", 1
system = spin_system(system_sites, H_S)

bath_sites = siteinds("S=1/2", 1)
bath_sites_L = liouv_sites(bath_sites)
H_E = OpSum()
H_E += 1.0, "Sx", 1
rho_E0_L = to_liouville(to_dm(MPS(bath_sites, ["Up"])); sites=bath_sites_L)
coupling = OpSum()
coupling += 1.0, "Sz", 1, "Sz", 2
mode = spin_mode(bath_sites_L, H_E, rho_E0_L; coupling=coupling)
environment = spin_bath([mode])

process_tensor = build_process_tensor(
    system;
    method=Dense(),
    environment=environment,
    dt=0.2,
    nsteps=4,
    sys_alg=Trotter{2}(),
    progress=false,
)
rho_S0 = to_dm(MPS(system_sites, ["Dn"]))
sigma_z = OpSum()
sigma_z += 2.0, "Sz", 1
time_indices = 1:(process_tensor.nsteps + 1)

# ===== LISTING =====
Czz = [
    evaluate_process(
        process_tensor,
        two_time_correlation_seq(
            process_tensor, (sigma_z, n2), (sigma_z, n1);
            rho0=rho_S0,
        ),
    )
    for n1 in time_indices, n2 in time_indices
]

# ===== CHECKS =====
@assert first(time_indices) == 1
@assert last(time_indices) == process_tensor.nsteps + 1
@assert size(Czz) == (length(time_indices), length(time_indices))
@assert all(isfinite, real.(Czz))
@assert all(isfinite, imag.(Czz))
@assert real(Czz[end, end]) ≈ 1

# tex-file: 05_pt_workflows.tex
# tex-label: lst:workflow-correlations-seq
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate("/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"; io=devnull)

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
    nsteps=5,
    sys_alg=Trotter{2}(),
    progress=false,
)
rho_S0 = to_dm(MPS(system_sites, ["Dn"]))
sigma_z = OpSum()
sigma_z += 1.0, "Sz", 1

# ===== LISTING =====
seq = two_time_correlation_seq(
    process_tensor, (sigma_z, 4), (sigma_z, 2);
    rho0=rho_S0,
)
println(seq)

# ===== CHECKS =====
@assert haskey(seq.entries, (1, :input))
@assert haskey(seq.entries, (1, :between))
@assert haskey(seq.entries, (3, :between))
@assert haskey(seq.entries, (4, :between))
@assert haskey(seq.entries, (5, :output))
@assert seq.entries[(1, :input)] isa StatePreparation
@assert seq.entries[(5, :output)] isa TraceOut
@assert seq.nsteps == 5

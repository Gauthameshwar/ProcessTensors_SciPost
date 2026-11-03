# tex-file: 04_instruments.tex
# tex-label: lst:instrument-seq-example
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
psi0 = MPS(system_sites, ["Up"])
rho0 = to_dm(psi0)

H_control = OpSum()
H_control += 0.4, "Sy", 1

O_final = OpSum()
O_final += 1.0, "Sz", 1

seq = InstrumentSeq(
    default=identity_operation(),
    nsteps=pt_dense.nsteps,
)
seq += state_preparation(rho0), 1
seq += unitary_propagation(H_control, system.sites), 2
seq += observable_measurement(O_final), pt_dense.nsteps

# ===== CHECKS =====
@assert haskey(seq.entries, (1, :input))
@assert seq.entries[(1, :input)] isa StatePreparation
@assert haskey(seq.entries, (2, :between))
@assert seq.entries[(2, :between)] isa UnitaryPropagation
@assert haskey(seq.entries, (pt_dense.nsteps, :output))
@assert seq.entries[(pt_dense.nsteps, :output)] isa ObservableMeasurement
@assert !haskey(seq.entries, (0, :input))
@assert !haskey(seq.entries, (2, :input))
@assert !haskey(seq.entries, (2, :output))

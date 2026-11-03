# tex-file: 04_instruments.tex
# tex-label: lst:open-leg-info
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

psi0 = MPS(system_sites, ["Up"])
rho0 = to_dm(psi0)

# ===== LISTING =====
seq_open = InstrumentSeq(
    default=identity_operation(),
    nsteps=pt_dense.nsteps,
)
add!(seq_open, state_preparation(rho0), 1)
add!(seq_open, open_inout(), 2)
add!(seq_open, trace_out(), pt_dense.nsteps)

info = open_leg_info(pt_dense, seq_open)
reduced = evaluate_process(pt_dense, seq_open; progress=false)

println("open input tsteps: ", info.open_in)
println("open output tsteps: ", info.open_out)
println("expected open legs: ", info.n_open_expected)
println("open dimensions: ", info.open_dims)
println("return type: ", typeof(reduced))

# ===== CHECKS =====
@assert info.open_in == [3]
@assert info.open_out == [2]
@assert info.n_open_expected == 2
@assert info.open_dims == [4, 4]
@assert reduced isa ITensor
@assert haskey(seq_open.entries, (1, :input))
@assert haskey(seq_open.entries, (2, :between))
@assert haskey(seq_open.entries, (pt_dense.nsteps, :output))

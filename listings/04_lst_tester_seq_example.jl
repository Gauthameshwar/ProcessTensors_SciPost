# tex-file: 04_instruments.tex
# tex-label: lst:tester-seq-example
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate("/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"; io=devnull)

using ITensors
using ProcessTensors
using ITensors.Ops: Trotter

system_sites_spin = siteinds("S=1/2", 1)
H_S = OpSum()
H_S += 0.7, "Sx", 1
system = spin_system(system_sites_spin, H_S)

bath_sites = siteinds("S=1/2", 1)
bath_sites_L = liouv_sites(bath_sites)
H_E = OpSum()
H_E += 0.55, "Sz", 1
rho_E0_L = to_liouville(to_dm(MPS(bath_sites, ["Dn"])); sites=bath_sites_L)
H_SE = OpSum()
H_SE += 0.35, "Sz", 1, "Sz", 2
mode = spin_mode(bath_sites_L, H_E, rho_E0_L; coupling=H_SE)
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
system_sites = siteinds("Qubit", 1)
tester_sites = siteinds("Qubit", 1)
rho_A0 = to_dm(MPS(tester_sites, ["1"]))
memory = tester(tester_sites, rho_A0)

U_SA = op("SWAP", only(system_sites), only(tester_sites))
U_A = op("X", only(tester_sites))
joint_U_SA = joint_unitary(U_SA, system_sites, tester_sites)
local_U_A = tester_unitary(U_A, tester_sites)

tester_seq = TesterSeq(nsteps=pt_dense.nsteps)
tester_seq += joint_U_SA, 1
tester_seq += local_U_A, 2
tester_seq += joint_U_SA, 3

# ===== CHECKS =====
@assert tester_seq.nsteps == 3
@assert haskey(tester_seq.entries, 1)
@assert haskey(tester_seq.entries, 2)
@assert haskey(tester_seq.entries, 3)
@assert !haskey(tester_seq.entries, 0)

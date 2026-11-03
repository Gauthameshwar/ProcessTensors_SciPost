# tex-file: 04_instruments.tex
# tex-label: lst:evaluate-tester
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate("/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"; io=devnull)

using ITensors
using ProcessTensors
using ITensors.Ops: Trotter

system_sites = siteinds("Qubit", 1)
H_S = OpSum()
H_S += 0.2, "Z", 1
system = qubit_system(system_sites, H_S)

pt_dense = build_process_tensor(
    system;
    method=Dense(),
    dt=0.05,
    nsteps=3,
    sys_alg=Trotter{2}(),
    progress=false,
)

rho0 = to_dm(MPS(system_sites, ["0"]))
H_control = OpSum()
H_control += 0.4, "Y", 1
O_final = OpSum()
O_final += 1.0, "Z", 1

seq = InstrumentSeq(
    default=identity_operation(),
    nsteps=pt_dense.nsteps,
)
seq += state_preparation(rho0), 1
seq += unitary_propagation(H_control, system.sites), 2
seq += observable_measurement(O_final), pt_dense.nsteps

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

# ===== LISTING =====
result = evaluate_process(
    pt_dense,
    seq;
    tester=memory,
    tester_seq=tester_seq,
    progress=false,
)

# ===== CHECKS =====
@assert result isa Number
@assert isfinite(real(result))
@assert abs(imag(result)) < 1e-8

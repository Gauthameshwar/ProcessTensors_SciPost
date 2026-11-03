# tex-file: 05_pt_workflows.tex
# tex-label: lst:workflow-tester
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
process_tensor = build_process_tensor(
    system;
    method=Dense(),
    dt=0.05,
    nsteps=4,
    sys_alg=Trotter{2}(),
    progress=false,
)
ancilla_sites = siteinds("Qubit", 1)
rho_A0 = to_dm(MPS(ancilla_sites, ["0"]))
rho_S0 = to_dm(MPS(system_sites, ["+"]))
store_step = 1
phase_step = 2
retrieve_step = 3

# ===== LISTING =====
memory = tester(ancilla_sites, rho_A0)

U_SA = op("SWAP", only(system_sites), only(ancilla_sites))
U_A = op("Z", only(ancilla_sites))
joint_U_SA = joint_unitary(U_SA, system_sites, ancilla_sites)
local_U_A = tester_unitary(U_A, ancilla_sites)

controls = TesterSeq(nsteps=process_tensor.nsteps)
controls += joint_U_SA, store_step
controls += local_U_A, phase_step
controls += joint_U_SA, retrieve_step

trajectory = evolve(
    process_tensor, rho_S0;
    tester=memory, tester_seq=controls, return_joint=true,
)

# ===== CHECKS =====
@assert haskey(controls.entries, store_step)
@assert haskey(controls.entries, phase_step)
@assert haskey(controls.entries, retrieve_step)
@assert !haskey(controls.entries, 0)
@assert length(trajectory.times) == process_tensor.nsteps + 1
@assert trajectory.times[1] == 0.0
@assert trajectory.times[end] == process_tensor.nsteps * process_tensor.dt
@assert length(trajectory.states_hilbert) == length(trajectory.times)
@assert length(trajectory.joint_states_hilbert) == length(trajectory.times)

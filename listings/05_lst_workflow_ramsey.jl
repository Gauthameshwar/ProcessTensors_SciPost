# tex-file: 05_pt_workflows.tex
# tex-label: lst:workflow-ramsey
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate(get(ENV, "PROCESSTENSORS_JL", "/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"); io=devnull)

using ITensors
using ProcessTensors
using ITensors.Ops: Trotter

system_sites = siteinds("Qubit", 1)
H_S = OpSum()
H_S += 0.3, "Z", 1
system = qubit_system(system_sites, H_S)
process_tensor = build_process_tensor(
    system;
    method=Dense(),
    dt=0.05,
    nsteps=6,
    sys_alg=Trotter{2}(),
    progress=false,
)
readout_steps = (2, 3, 4)
probabilities = Dict{Tuple{Int, Int, Int}, Float64}()

# ===== LISTING =====
eta = 0.90
rho_r = to_dm(MPS(system_sites, ["+"]))

effects = Dict(x => (OpSum() + (0.5, "Id", 1) + (0.5 * x * eta, "X", 1)) for x in (-1, 1))
instruments = Dict(
    x => observable_measurement(effects[x]) * state_preparation(rho_r)
    for x in (-1, 1)
)

for record in Iterators.product((-1, 1), (-1, 1), (-1, 1))
    seq = default_schedule(process_tensor)
    seq += state_preparation(rho_r), 1
    for (k, x) in zip(readout_steps, record)
        seq += instruments[x], k
    end
    seq += trace_out(), process_tensor.nsteps
    probabilities[record] = real(evaluate_process(process_tensor, seq))
end

# ===== CHECKS =====
@assert length(probabilities) == 8
@assert abs(sum(values(probabilities)) - 1) < 1e-8
@assert all(value -> value >= -1e-8, values(probabilities))

check_seq = default_schedule(process_tensor)
check_seq += state_preparation(rho_r), 1
check_seq += instruments[1], readout_steps[1]
check_seq += instruments[-1], readout_steps[2]
check_seq += instruments[1], readout_steps[3]
check_seq += trace_out(), process_tensor.nsteps
@assert haskey(check_seq.entries, (1, :input))
@assert check_seq.entries[(1, :input)] isa StatePreparation
@assert haskey(check_seq.entries, (readout_steps[1], :between))
@assert haskey(check_seq.entries, (readout_steps[2], :between))
@assert haskey(check_seq.entries, (readout_steps[3], :between))
@assert haskey(check_seq.entries, (process_tensor.nsteps, :output))

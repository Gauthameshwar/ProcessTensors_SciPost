# tex-file: 05_pt_workflows.tex
# tex-label: lst:workflow-central-spin
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate("/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"; io=devnull)

using ITensors
using ProcessTensors

N = 1
J = 1.0
nsteps = 2

system_sites = siteinds("S=1/2", 1)
H_S = OpSum()
system = spin_system(system_sites, H_S)
rho_S0 = to_dm(MPS(system_sites, ["X+"]))
Sx = ComplexF64[0.0 0.5; 0.5 0.0]

function density_matrix(state)
    sites = [only(filter(i -> plev(i) == 0, pair)) for pair in siteinds(state)]
    tensor = foldl(*, state)
    d = prod(dim.(sites))
    return reshape(ComplexF64.(Array(tensor, prime.(sites)..., sites...)), d, d)
end

# ===== LISTING =====
bath_sites = siteinds("S=1/2", N)
bath_sites_L = liouv_sites(bath_sites)

modes = SpinMode[]
for k in 1:N
    rho_k = to_dm(MPS([bath_sites[k]], ["Up"]))
    rho_k_L = to_liouville(rho_k; sites=[bath_sites_L[k]])
    coupling = OpSum()
    coupling += J / N, "Sx", 1, "Sx", 2
    coupling += J / N, "Sy", 1, "Sy", 2
    coupling += J / N, "Sz", 1, "Sz", 2
    push!(
        modes,
        spin_mode([bath_sites_L[k]], OpSum(), rho_k_L; coupling=coupling),
    )
end
bath = spin_bath(modes)

process_tensor = build_process_tensor(
    system; method=ACE(cutoff=1e-10),
    environment=bath, dt=0.01, nsteps=nsteps,
)

trajectory = evolve(process_tensor, rho_S0)
Sx_t = [real(tr(Sx * density_matrix(rho)))
        for rho in trajectory.states_hilbert]

# ===== CHECKS =====
@assert process_tensor.nsteps == nsteps
@assert length(process_tensor.core) == nsteps
@assert length(trajectory.times) == nsteps + 1
@assert trajectory.times[1] == 0.0
@assert trajectory.times[end] == nsteps * process_tensor.dt
@assert length(Sx_t) == nsteps + 1
@assert all(isfinite, Sx_t)

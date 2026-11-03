# tex-file: 03_process_tensors.tex
# tex-label: lst:pt-ingredients-time
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate(get(ENV, "PROCESSTENSORS_JL", "/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"); io=devnull)

# ===== LISTING =====
dt = 0.05
nsteps = 3
t_final = round(dt * nsteps; digits=10)
println("time grid: dt=$dt, nsteps=$nsteps, t_final=$t_final")

# ===== CHECKS =====
@assert nsteps == 3
@assert t_final == 0.15

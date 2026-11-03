# tex-file: 03_process_tensors.tex
# tex-label: lst:pt-ingredients-system
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate("/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"; io=devnull)

using ITensors
using ProcessTensors

# ===== LISTING =====
system_sites = siteinds("S=1/2", 1)

h = 0.7
H_S = OpSum()
H_S += h, "Sx", 1

system = spin_system(system_sites, H_S)
println(system)

# ===== CHECKS =====
@assert length(system.sites) == 1
@assert dim(only(system.sites)) == 4
@assert isempty(system.jump_ops)

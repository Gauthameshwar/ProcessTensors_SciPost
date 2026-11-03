# tex-file: 02_liouv_space.tex
# tex-label: lst:fig2-vectorisation
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate(get(ENV, "PROCESSTENSORS_JL", "/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"); io=devnull)
using ITensors

# ===== LISTING =====
using ProcessTensors

sites = siteinds("S=1/2", 1)
sites_L = liouv_sites(sites)

A = OpSum()
A += 1.0, "Sx", 1
A_L = to_liouville(MPO(A, sites); sites=sites_L) # (a) |A>>

Id = OpSum()
Id += 1.0, "Id", 1
Id_L = to_liouville(MPO(Id, sites); sites=sites_L) # (b) <<I|

TrA = inner(Id_L, A_L) # (c) Tr(A) = <<I|A>>

rho_L = to_liouville(to_dm(MPS(sites, ["Up"])); sites=sites_L)
O = OpSum()
O += 1.0, "Sz", 1
O_L = to_liouville(MPO(O, sites); sites=sites_L)
expect_O = inner(O_L, rho_L) # (d) <O> = <<O|rho>>

# ===== CHECKS =====
@assert length(sites_L) == 1
@assert dim(only(sites_L)) == 4
@assert real(TrA) ≈ 0
@assert real(expect_O) ≈ 0.5

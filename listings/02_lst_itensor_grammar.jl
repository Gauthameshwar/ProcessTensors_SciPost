# tex-file: 02_liouv_space.tex
# tex-label: lst:itensor-grammar
# run: yes

# ===== PREAMBLE =====
using Pkg
Pkg.activate(get(ENV, "PROCESSTENSORS_JL", "/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl"); io=devnull)

# ===== LISTING =====
using ITensors

s = Index(2, "s")

psi = ITensor([1.0, 0.0], s) # (a) ket |psi> = psi_s

psidag = dag(prime(psi)) # (b) bra <psi| = psi_s'

A = random_itensor(s, prime(s)) # (c) operator A = a_ss'

Apsi = A * prime(psi) # (d) A|psi> = A_ss' psi_s'

i = Index(2, "i")
k = Index(2, "k")
j = Index(2, "j")
AB = random_itensor(i, k) * random_itensor(k, j) # (e) AB = a_ik b_kj

l = Index(2, "l")
AxB = random_itensor(i, j) * random_itensor(k, l) # (f) A ox B = a_ij b_kl  (no shared index)

TrA = A * delta(s, prime(s)) # (g) Tr(A) = a_ii

AT = swapinds(A, s, prime(s)) # (h) AT = a_ji

# ===== CHECKS =====
@assert inds(psi) == IndexSet(s)
@assert hassameinds(Apsi, (s,))
@assert hassameinds(AB, (i, j))
@assert hassameinds(AxB, (i, j, k, l))
@assert isempty(inds(TrA))
@assert hassameinds(AT, (s, prime(s)))

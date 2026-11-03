# tex-file: 07_roadmap.tex
# tex-label: lst:roadmap-driven-bath-mode
# run: no

# ===== PREAMBLE =====
# Prospective interface. spin_mode does not accept a time-dependent Hamiltonian, so this file is not executed.

# ===== LISTING =====
function H_E(t)
    H = OpSum()
    H += omega_E / 2, "Sz", 1
    H += drive * cos(nu * t), "Sx", 1
    return H
end

driven_mode = spin_mode(bath_sites_L, H_E, rho_E0_L; coupling=H_SE)

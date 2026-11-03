# tex-file: 07_roadmap.tex
# tex-label: lst:roadmap-dissipative-bath-mode
# run: no

# ===== PREAMBLE =====
# Prospective interface. jump_ops is not accepted by bosonic_mode, so this file is not executed.

# ===== LISTING =====
loss = OpSum()
loss += kappa, "A", 1

mode = bosonic_mode(
    bath_sites_L,
    H_E,
    rho_E0_L;
    coupling=H_SE,
    jump_ops=[loss],
)

# tex-file: 07_roadmap.tex
# tex-label: lst:roadmap-pttempo-builder
# run: no

# ===== PREAMBLE =====
# Prospective interface. gaussian_bath and PTTEMPO are not implemented, so this file is not executed.

# ===== LISTING =====
bath = gaussian_bath(J, T; coupling=H_SB)

process_tensor = build_process_tensor(
    system;
    environment=bath,
    method=PTTEMPO(
        #kwargs...
    ),
    dt=dt,
    nsteps=nsteps,
)

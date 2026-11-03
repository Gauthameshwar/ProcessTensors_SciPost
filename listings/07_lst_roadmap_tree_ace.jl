# tex-file: 07_roadmap.tex
# tex-label: lst:roadmap-tree-ace
# run: no

# ===== PREAMBLE =====
# Prospective interface. ACE does not take contraction or parallel, so this file is not executed.

# ===== LISTING =====
pt_tree = build_process_tensor(
    system;
    method=ACE(
        cutoff=1e-10,
        compression=:canonzip,
        contraction=:tree,
        parallel=true,
        # Other ACE kwargs
    ),
    environment=environment,
    dt=dt,
    nsteps=nsteps,
)

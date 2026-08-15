"""Julia lexer with ProcessTensors.jl / ITensor API highlighting."""

from pygments.lexer import inherit, words
from pygments.lexers.julia import JuliaLexer
from pygments.token import Name

# ITensor / ITensorMPS names that appear in the manuscript listings.
# These render in teal (Name.Builtin), distinct from ProcessTensors.jl (violet).
ITENSOR_BUILTINS = (
    "Index",
    "ITensor",
    "MPS",
    "MPO",
    "OpSum",
    "apply",
    "dag",
    "delta",
    "inner",
    "op",
    "prime",
    "random_itensor",
    "siteinds",
)

# ProcessTensors.jl user-facing functions / methods (violet).
PT_FUNCTIONS = (
    "add!",
    "build_process_tensor",
    "default_schedule",
    "evaluate_process",
    "evolve",
    "liouv_sites",
    "liouvillian_mpo",
    "liouvillian_propagator",
    "observable_measurement",
    "spin_bath",
    "spin_mode",
    "spin_system",
    "state_preparation",
    "to_dm",
    "to_hilbert",
    "to_liouville",
    "two_time_correlation_seq",
)

# Package / backend types and space tags used as type-like names in examples.
PT_TYPES = (
    "ACE",
    "BosonSystem",
    "CustomTwoLegInstrument",
    "Dense",
    "Hilbert",
    "IdentityOperation",
    "InstrumentSeq",
    "LeftRightOperator",
    "Liouville",
    "ObservableMeasurement",
    "OpenInOut",
    "OpenInput",
    "OpenOutput",
    "ProcessTensor",
    "ProductInstrument",
    "SpinSystem",
    "StatePreparation",
    "TraceOut",
    "UnitaryPropagation",
)


class ProcessTensorsJuliaLexer(JuliaLexer):
    """JuliaLexer with manuscript-specific API and type tokens preferred first."""

    name = "ProcessTensorsJulia"
    aliases = ["ptjulia", "julia-pt"]
    filenames = []
    mimetypes = []

    tokens = {
        "root": [
            (r"\badd!", Name.Function.Magic),
            (words(PT_TYPES, suffix=r"\b"), Name.Class),
            (words(PT_FUNCTIONS, suffix=r"\b"), Name.Function.Magic),
            (words(ITENSOR_BUILTINS, suffix=r"\b"), Name.Builtin),
            inherit,
        ],
    }

"""Print-friendly, high-contrast highlighting for ProcessTensors.jl listings."""

from pygments.style import Style
from pygments.token import (
    Comment,
    Error,
    Generic,
    Keyword,
    Name,
    Number,
    Operator,
    Punctuation,
    String,
    Whitespace,
)


class ProcessTensorsJuliaStyle(Style):
    """
    Colour roles (print-oriented, mutually distinct):

    - Keyword: Julia language keywords (blue)
    - Name.Builtin: ITensor / Julia-native constructors (teal)
    - Name.Function.Magic: ProcessTensors.jl API (violet)
    - Name.Class: structs / types / backends (orange)
    - Name: variables (near-black)
    - Number: numeric literals (green)
    - String: string literals (crimson)
    - Comment: comments (gray italic)
    """

    name = "ptjulia"
    background_color = "#f4f6f8"

    styles = {
        Whitespace: "",
        Comment: "italic #6b7280",
        Comment.Multiline: "italic #6b7280",
        Keyword: "bold #1d4ed8",
        Keyword.Constant: "bold #1d4ed8",
        Keyword.Declaration: "bold #1d4ed8",
        Keyword.Namespace: "bold #1d4ed8",
        Keyword.Type: "bold #ea580c",
        Operator: "#111827",
        Punctuation: "#111827",
        Name: "#111827",
        Name.Builtin: "bold #0f766e",
        Name.Builtin.Pseudo: "bold #0f766e",
        Name.Function: "bold #0f766e",
        Name.Function.Magic: "bold #7c3aed",
        Name.Class: "bold #c2410c",
        Name.Attribute: "#374151",
        Name.Constant: "#b45309",
        Name.Namespace: "#1d4ed8",
        Name.Variable: "#111827",
        String: "#be123c",
        String.Symbol: "#be123c",
        String.Char: "#be123c",
        Number: "bold #15803d",
        Number.Float: "bold #15803d",
        Number.Integer: "bold #15803d",
        Number.Hex: "bold #15803d",
        Generic: "#111827",
        Error: "bold #b91c1c",
    }

# Compare each standalone listing script with the SciPost manuscript.
#
# Run from anywhere:
#   PROCESSTENSORS_JL=/path/to/ProcessTensors.jl julia listings/check_listings.jl
#
# A mismatch is printed. This file does not edit any tex file.
# PROCESSTENSORS_JL selects the package checkout. The default is this
# author's local checkout, so an unset variable still runs here.
# LISTINGS_TEXT_ONLY=1 skips executing the Julia listings.

using Pkg

const REPO = dirname(@__DIR__)
const LISTINGS = @__DIR__
const PACKAGE = get(ENV, "PROCESSTENSORS_JL", "/Users/gauthameshwar/Documents/VSCode/ProcessTensors.jl")
Pkg.activate(PACKAGE; io=devnull)

function trim_blank_edges(text)
    lines = split(replace(text, "\r\n" => "\n"), "\n", keepempty=true)
    while !isempty(lines) && isempty(lines[1])
        popfirst!(lines)
    end
    while !isempty(lines) && isempty(lines[end])
        pop!(lines)
    end
    return join(lines, "\n")
end

function mask_ids(text)
    return replace(text, r"id=\d+" => "id=*")
end

function read_script(path)
    text = read(path, String)
    lines = split(replace(text, "\r\n" => "\n"), "\n", keepempty=true)
    tex_file = ""
    tex_label = ""
    run_script = true
    regions = Dict{String, Vector{String}}()
    current = ""
    for line in lines
        if startswith(line, "# tex-file:")
            tex_file = strip(line[length("# tex-file:") + 1:end])
        elseif startswith(line, "# tex-label:")
            tex_label = strip(line[length("# tex-label:") + 1:end])
        elseif startswith(line, "# run:")
            run_script = strip(line[length("# run:") + 1:end]) == "yes"
        elseif line == "# ===== PREAMBLE =====" ||
               line == "# ===== LISTING =====" ||
               line == "# ===== DISPLAY =====" ||
               line == "# ===== CHECKS ====="
            current = strip(replace(line, "#" => ""))
            regions[current] = String[]
        elseif !isempty(current)
            push!(regions[current], line)
        end
    end
    listing = get(regions, "===== LISTING =====", String[])
    return (;
        tex_file,
        tex_label,
        run_script,
        listing=join(listing, "\n"),
    )
end

function options_end(lines, begin_at)
    begin_line = lines[begin_at]
    if occursin("]", begin_line)
        return begin_at
    end
    for i in (begin_at + 1):length(lines)
        if occursin(r"^\s*\]", lines[i])
            return i
        end
    end
    error("Could not find the end of the environment options at line $begin_at.")
end

function environment_body(lines, begin_at, ending)
    start_line = options_end(lines, begin_at) + 1
    finish = 0
    for i in start_line:length(lines)
        if occursin(ending, lines[i])
            finish = i
            break
        end
    end
    finish == 0 && error("Could not find $ending after line $begin_at.")
    return join(lines[start_line:(finish - 1)], "\n")
end

function first_line_from(lines, start_line, needle)
    for i in start_line:length(lines)
        if occursin(needle, lines[i])
            return i
        end
    end
    return nothing
end

function tex_listing(tex_path, label)
    lines = split(replace(read(tex_path, String), "\r\n" => "\n"), "\n", keepempty=true)
    label_at = 0
    for i in 1:length(lines)
        if occursin("label={$label}", lines[i])
            label_at = i
            break
        end
    end
    label_at == 0 && error("Label $label was not found in $tex_path.")

    code_at = nothing
    for i in label_at:-1:1
        if occursin("\\begin{juliacode}", lines[i])
            code_at = i
            break
        end
        if occursin("\\begin{julialistingpair}", lines[i])
            code_at = first_line_from(lines, i + 1, "\\begin{juliacode}")
            break
        end
    end
    code_at === nothing && error("No juliacode environment for $label in $tex_path.")
    code = environment_body(lines, code_at, "\\end{juliacode}")

    output = nothing
    output_at = first_line_from(lines, code_at + 1, "\\begin{juliaoutput}")
    if output_at !== nothing
        next_code = nothing
        for i in (code_at + 1):length(lines)
            if occursin("\\begin{juliacode}", lines[i]) || occursin("\\begin{julialistingpair}", lines[i])
                next_code = i
                break
            end
        end
        if next_code === nothing || output_at < next_code
            output = environment_body(lines, output_at, "\\end{juliaoutput}")
        end
    end
    return code, output
end

failures = String[]
script_paths = filter(path -> endswith(path, ".jl") && basename(path) != "check_listings.jl",
                      readdir(LISTINGS, join=true))
sort!(script_paths)

for path in script_paths
    name = basename(path)
    info = read_script(path)
    tex_path = joinpath(REPO, info.tex_file)
    code, output = tex_listing(tex_path, info.tex_label)
    if trim_blank_edges(info.listing) != trim_blank_edges(code)
        push!(failures, name * " listing text differs from " * info.tex_label)
        println("---- ", name, " listing text differs from ", info.tex_file, " ----")
        println("SCRIPT:")
        println(trim_blank_edges(info.listing))
        println("TEX:")
        println(trim_blank_edges(code))
        println()
    end

    if !info.run_script || get(ENV, "LISTINGS_TEXT_ONLY", "0") == "1"
        println(name, ": text only")
        continue
    end

    println(name, ": running")
    out_file = tempname()
    err_file = tempname()
    command = `julia --project=$PACKAGE $path`
    ok = success(pipeline(command, stdout=out_file, stderr=err_file))
    printed = read(out_file, String)
    errors = read(err_file, String)
    rm(out_file, force=true)
    rm(err_file, force=true)
    if !ok
        push!(failures, name * " did not run")
        println("---- ", name, " failed ----")
        println(errors)
        println(printed)
        println()
        continue
    end
    if output !== nothing
        got = mask_ids(trim_blank_edges(printed))
        expected = mask_ids(trim_blank_edges(output))
        if got != expected
            push!(failures, name * " terminal output differs from " * info.tex_label)
            println("---- ", name, " terminal output differs ----")
            println("SCRIPT:")
            println(got)
            println("TEX:")
            println(expected)
            println()
        end
    end
end

println()
if isempty(failures)
    println("All listing checks passed.")
else
    println(length(failures), " listing check(s) failed:")
    for failure in failures
        println("  ", failure)
    end
    exit(1)
end

using DataFrames
using CSV

symbols = DataFrame(Symbol=String[], Value=Int[])
for i = 0:15
    push!(symbols, ["R$(i)" i])
end
push!(symbols, ["SCREEN" 16384])
push!(symbols, ["KBD" 24576])
push!(symbols, ["SP" 0])
push!(symbols, ["LCL" 1])
push!(symbols, ["ARG" 2])
push!(symbols, ["THIS" 3])
push!(symbols, ["THAT" 4])

variables = DataFrame(Symbol=String[], Value=Int[])
push!(variables, ["", 15])

dest = DataFrame(CSV.File("./dest.csv"))
jump = DataFrame(CSV.File("./jump.csv"))
comp = DataFrame(CSV.File("./comp.csv"))

function parser(line)
    no_spaces = filter(x -> !isspace(x), line)
    if isempty(no_spaces) || no_spaces[1] == '/'
        return nothing  
    end
    if findfirst('/', no_spaces) !== nothing
        no_spaces = no_spaces[1:findfirst('/', no_spaces)-1]
    end
    if no_spaces[1] == '@'
        return ["@", no_spaces[2:end]]
    elseif no_spaces[1] == '('
        return ["(", no_spaces[2:end-1]]
    else
        eq = findfirst('=', no_spaces)
        sc = findfirst(';', no_spaces)
        if sc == 1
            return ["", "", no_spaces[2:end]]
        elseif eq === nothing
            if sc === nothing
                return ["", no_spaces, ""]
            else
                return ["", no_spaces[1:sc-1], no_spaces[sc+1:end]]
            end
        else
            if sc === nothing
                return [no_spaces[1:eq-1], no_spaces[eq+1:end], ""]
            else
                return [no_spaces[1:eq-1], no_spaces[eq+1:sc-1], no_spaces[sc+1:end]]
            end
        end
    end
end

function Atobinary(number)
    n = copy(number)
    bin_number = ""
    for i in 1:15
        bin_number = string(n % 2) * bin_number
        n = div(n, 2)
    end
    return bin_number
end

function HackAssembler(file_name)
    open(file_name) do file
        line_number = 0
        while !eof(file)
            line = readline(file)
            instructions = parser(line)
            if instructions !== nothing
                if (instructions[1] == "(") && (!all(isdigit, instructions[2]))
                    if instructions[2] ∉ symbols.Symbol
                        push!(symbols, [instructions[2], line_number])
                    end
                else
                    line_number += 1
                end
            end
        end
    end
    open(file_name) do file
        program = ""
        while !eof(file)
            line = readline(file)
            instructions = parser(line)
            if instructions === nothing
            elseif instructions[1] == "@"
                if (!all(isdigit, instructions[2]))
                    if instructions[2] ∈ symbols.Symbol
                        number = symbols.Value[symbols.Symbol .== instructions[2]][1]
                    elseif instructions[2] ∈ variables.Symbol
                        number = variables.Value[variables.Symbol .== instructions[2]][1]
                    else
                        push!(variables, [instructions[2], variables.Value[end]+1])
                        number = variables.Value[end]
                    end
                else
                    number = parse(Int, instructions[2])
                end
                program = program * "0" * Atobinary(number) * "\n"
            elseif instructions[1] != "("
                program = program * "111"
                if instructions[2] != ""
                    program = program * comp.Value[comp.Symbol .== instructions[2]][1][2:end]
                else
                    program = program * "0000000"
                end

                a = 'A' ∈ instructions[1] ? "1" : "0"
                d = 'D' ∈ instructions[1] ? "1" : "0"
                m = 'M' ∈ instructions[1] ? "1" : "0"
                program = program * a * d * m 
                
                if instructions[3] != ""
                    program = program * jump.Value[jump.Symbol .== instructions[3]][1][2:end]
                else
                    program = program * "000"
                end
                program = program * "\n"
            end
        end
        if findfirst('.', file_name) === nothing
            write_name = file_name * ".hack"
        else
            write_name = file_name[1:end-findfirst('.', file_name[end:-1:1])] * ".hack"
        end
        touch(write_name)
        f = open(write_name, "w")
        write(f, program)
        close(f)
        print("File saved to " * write_name * "\n")
    end
end
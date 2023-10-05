mutable struct Program
    target::IOStream
    source::IOStream
    line::String
    n_line::Int
    position::Int
    token::Union{Char, String, Nothing}
    token_type::Union{String, Nothing}

    function Program(target::IOStream, source::IOStream, line::String, n_line::Int, position::Int, token::Union{Char, String, Nothing}, token_type::Union{Char, String, Nothing})
        new(target, source, line, n_line, position, token, token_type)
    end

    function Program(path::String)
        if path[end-4:end] != ".jack"
            error("Invalid file extension.")
        end
        write_path = path[1:end-5] * ".vm"
        rm(write_path, force=true)
        touch(write_path)
        target = open(write_path, "a")
        source = open(path, "r")
        line = readline(source)
        new(target, source, line, 1, 1, nothing, nothing)
    end
end

function advance!(program::Program)
    new_line = false
    while ((length(program.line) >= program.position + 2) && (program.line[program.position:program.position+2] == "/**")) ||
          ((length(program.line) >= program.position + 1) && (program.line[program.position:program.position+1] == "//")) ||
          ((program.line[program.position:end] == "") && (!eof(program.source))) ||
          ((program.position <= length(program.line)) && (program.line[program.position] ∈ [' ', '\t']))
        if (length(program.line) >= program.position + 2) && (program.line[program.position:program.position+2] == "/**")
            program.position += 3
            while findfirst("*/", program.line) === nothing
                program.n_line +=1
                program.position = 1
                program.line = readline(program.source)
            end
            program.n_line +=1
            program.position = 1
            program.line = readline(program.source)
            new_line = true
        elseif (length(program.line) >= program.position + 1) && (program.line[program.position:program.position+1] == "//")
            program.n_line += 1
            program.position = 1
            program.line = readline(program.source)
            new_line = true
        elseif program.line[program.position:end] == ""
            program.n_line += 1
            program.position = 1
            program.line = readline(program.source)
            new_line = true
        elseif ((program.position <= length(program.line)) && (program.line[program.position] ∈ [' ', '\t']))
            program.position += 1
        end
    end
    if eof(program.source)
        return (nothing, nothing)
    end
    if new_line
        write(program.target, "// " * program.line[findfirst(!isspace, program.line):end] * "        | Line " * string(program.n_line) * '\n')
    end
    if program.line[program.position] ∈ ['{','}','(',')','[',']','.',',',';','+','-','*','/','&','|','<','>','=','~']
        token, token_type = program.line[program.position], "symbol"
        program.position += 1
    elseif program.line[program.position] == '"'
        idx = findnext('"', program.line, program.position + 1)
        if idx === nothing
            error("Program ended while reading a string.")
        end
        token, token_type = program.line[program.position + 1 : idx - 1], "stringConstant"
        program.position = idx + 1
    elseif isdigit(program.line[program.position])
        idx = findnext(!isdigit, program.line, program.position)
        token, token_type = program.line[program.position : idx - 1], "integerConstant"
        program.position = idx
    elseif program.line[program.position] == '_' || isletter(program.line[program.position]) 
        idx = findnext(x -> !isnumeric(x) && !isletter(x) && x!='_', program.line, program.position)
        token = program.line[program.position : idx-1]
        program.position = idx
        if token in ["class", "constructor", "function", "method", "field", "static", "var", "int", "char", "boolean", "void", "true", "false", "null", "this", "let", "do", "if", "else", "while", "return"]
            token, token_type = token, "keyword"
        else
            token, token_type = token, "identifier"
        end
    else
        error("Invalid command in line " * string(program.n_line) *". " * program.token)
    end
    program.token = token
    program.token_type = token_type
    return (token, token_type)
end

function Base.pop!(program::Program)
    token = program.token
    advance!(program)
    return token
end

function next_token(program::Program)
    p = Program(program.target, program.source, program.line, program.n_line, program.position, program.token, program.token_type)
    advance!(p)
    return p.token
end

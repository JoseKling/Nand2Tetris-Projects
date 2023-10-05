mutable struct Program
    const source::String
    const read_path::String
    const write_path::String
    position::Int
    token::Union{Char, String, Nothing}
    token_type::Union{String, Nothing}

    function Program(source, read_path, write_path, position, token, token_type)
        new(source, read_path, write_path, position, token, token_type)
    end

    function Program(path::String)
        if path[end-4:end] != ".jack"
            error("Invalid file extension.")
        end
        read_path = path
        write_path = read_path[1:end-5] * ".xml"
        source = ""
        in_comment = false
        open(read_path, "r") do file
            while !eof(file)
                line = readline(file)
                end_line = length(line)
                position = 1
                while position <= end_line
                    if in_comment
                        comment_end = findnext("*/", line, position)
                        if comment_end !== nothing
                            in_comment = false
                            position = comment_end[2] + 1
                        else
                            position = end_line + 1
                        end
                    else 
                        line_comment = findnext("//", line, position)
                        block_comment = findnext("/*", line, position)
                        if (line_comment !== nothing) && (block_comment !== nothing)
                            if line_comment[1] < block_comment[1]
                                if position != line_comment[1]
                                    source = source * line[position : line_comment[1] - 1] * ' '
                                end
                                position = end_line + 1
                            else
                                if position != block_comment[1]
                                    source = source * line[position : block_comment[1] -1] * ' '
                                end
                                position = block_comment[2] + 1
                                in_comment = true
                            end
                        elseif (line_comment !== nothing) && (block_comment === nothing)
                            if position != line_comment[1]
                                source = source * line[1 : line_comment[1] - 1] * ' '
                            end
                            position = end_line + 1
                        elseif (line_comment === nothing) && (block_comment !== nothing)
                            if position != block_comment[1]
                                source = source * line[position : block_comment[1] - 1] * ' '
                            end
                            position = block_comment[2] + 1
                            in_comment = true
                        else
                            source = source * line[position : end] * ' '
                            position = end_line + 1
                        end
                    end
                end
            end
        end
        new(source[findfirst(x -> !(x in [' ', '\t', '\n']), source) : end], read_path, write_path, 1, nothing, nothing)
    end
end

function has_tokens(program::Program)
    return program.position <= length(program.source) 
end

function advance!(program::Program)
    if program.source[program.position] in ['{','}','(',')','[',']','.',',',';','+','-','*','/','&','|','<','>','=','~']
        if program.source[program.position] == '<'
            token, token_type = "&lt;", "symbol"
        elseif program.source[program.position] == '>'
            token, token_type = "&gt;", "symbol"
        elseif program.source[program.position] == '&'
            token, token_type = "&amp;", "symbol"
        else
            token, token_type = program.source[program.position], "symbol"
        end
        program.position += 1
    elseif program.source[program.position] == '"'
        idx = findnext('"', program.source, program.position + 1)
        if idx === nothing
            error("Program ended while reading a string.")
        end
        token, token_type = program.source[program.position + 1 : idx - 1], "stringConstant"
        program.position = idx + 1
    elseif isdigit(program.source[program.position])
        idx = findnext(!isdigit, program.source, program.position)
        token, token_type = program.source[program.position : idx - 1], "integerConstant"
        program.position = idx
    elseif program.source[program.position] == '_' || isletter(program.source[program.position]) 
        idx = findnext(x -> !isnumeric(x) && !isletter(x) && x!='_', program.source, program.position)
        token = program.source[program.position : idx-1]
        program.position = idx
        if token in ["class", "constructor", "function", "method", "field", "static", "var", "int", "char", "boolean", "void", "true", "false", "null", "this", "let", "do", "if", "else", "while", "return"]
            token, token_type = token, "keyword"
        else
            token, token_type = token, "identifier"
        end
    else
        error("Invalid command.")
    end
    while (program.position <= length(program.source)) && (program.source[program.position] in [' ', '\t', '\n']) 
        program.position += 1
    end
    program.token = token
    program.token_type = token_type
end

function next_token(program::Program)
    p = Program(program.source, program.read_path, program.write_path, program.position, program.token, program.token_type)
    advance!(p)
    return p.token
end

function string(program::Program)
    return "<" * program.token_type * "> " * program.token * " </" * program.token_type * ">"
end

function print_lines(program::Program, tabs::Int, n_lines::Int)
    output = ""
    for _ in 1:n_lines
        output *= tab(tabs) * string(program) * '\n'
        advance!(program)
    end
    return output
end

ops = ['+', '-', '*', '/', "&amp;", '|', "&lt;", "&gt;", '=']
unaryOps = ['-', '~']

function tokenizer(path)
    if path[end-4:end] != ".jack"
        if path[end] != '/'
            path = path * '/'
        end 
        file_names = readdir(path)
        filter!(x -> x[end-4:end] == ".jack", file_names)
        file_names = path .* file_names
    else
        file_names = path;
    end
    for file_name in file_names
        program = Program(file_name)
        touch(program.write_path)
        open(program.write_path, "w") do xml_file
            write(xml_file, "<tokens>\n")
            while has_tokens(program)
                advance!(program)
                if program.token !== nothing
                    write(xml_file, string(program) * '\n')
                end
            end
            write(xml_file, "</tokens>")
        end
    end
end

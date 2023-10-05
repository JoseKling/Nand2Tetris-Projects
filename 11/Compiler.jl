includet("Tokenizer.jl")
includet("Globals.jl")
includet("Statements.jl")
includet("Expressions.jl")
includet("Structures.jl")

function compiler()
    compiler(pwd())
end

function compiler(path::String)
    if path[end-4:end] != ".jack"
        if path[end] != '/'
            path = path * '/'
        end 
        file_names = readdir(path)
        filter!(x -> x[end-4:end] == ".jack", file_names)
        file_names = path .* file_names
    else
        file_names = [path];
    end
    for file_name ∈ file_names
        program = Program(file_name)
        try
            advance!(program)
            class(program)
        finally
            close(program.target)
        end
    end
end

function next_idx(kind::String, ST::Dict{String, Tuple{String, String, Int}})
    next = 0
    for val in values(ST)
         next += (1 * (val[2] == kind))
    end
    return next
end

function push(program::Program)
    var = var_info(program)
    return write(program.target, "push " * var[2] * " " * repr(var[3]) * '\n')
end

function pop(program::Program)
    var_info = var_info(program)
    return write(program.target, "pop " * var_info[2] * " " * repr(var_info[3]) * "\n")
end

function var_info(program::Program)
    var_name = pop!(program)
    if var_name ∈ keys(ST_routine)
        return ST_routine[var_name]
    else
        return  ST_class[var_name]
    end
end
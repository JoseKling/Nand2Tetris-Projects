function analyzer()
    analyzer(pwd())
end

function analyzer(path::String)
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
    for file_name in file_names
        program = Program(file_name)
        touch(program.write_path)
        tabs = 0
        open(program.write_path, "w") do compiled
            advance!(program)
            write(compiled, class_comp(program, tabs))
        end
    end
end

function tab(n::Int)
    return "  "^n
end
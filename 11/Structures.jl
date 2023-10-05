function class(program::Program)
    empty!(ST_class)
    advance!(program) # class
    ST_class["class"] = (pop!(program), "class", 0) # className
    advance!(program) # {
    while program.token ∈  ["static", "field", "constructor", "function", "method"]
        if program.token ∈ ["static", "field"]
            classVarDec(program)
        else
            subroutineDec(program)
        end
    end
    advance!(program) # }
end

function classVarDec(program::Program)
    kind = pop!(program) # static|field
    kind = (kind == "field") ? "this" : kind
    type = pop!(program) # type
    ST_class[pop!(program)] = (type, kind, next_idx(kind, ST_class)) # varName
    while program.token == ','
        advance!(program) # ,
        ST_class[pop!(program)] = (type, kind, next_idx(kind, ST_class)) # varName
    end
    advance!(program) # ;
end

function subroutineDec(program::Program)
    empty!(ST_routine)
    function_type = pop!(program) # constructor|method|function
    function_kind = pop!(program) # type|void
    function_name = pop!(program) # subroutineName
    advance!(program) # (
    parametersList(program)
    advance!(program) # )
    advance!(program) # { |subroutineBody
    n_local = 0
    while program.token == "var" 
        n_local += varDec(program)
    end
    if function_type == "constructor"
        write(program.target, "function " * ST_class["class"][1] * '.' * function_name * ' ' * string(n_local) * '\n')
        write(program.target, "push constant " * string(next_idx("this", ST_class)) * '\n')
        write(program.target, "call Memory.alloc 1\npop pointer 0\n")
    elseif function_type == "method"
        write(program.target, "function " * ST_class["class"][1] * '.' * function_name * ' ' * string(n_local) * '\n')
        ST_routine["this"] = (ST_class["class"][1], "argument", 0)
        write(program.target, "push argument 0\npop pointer 0\n")
    else # function
        write(program.target, "function " * ST_class["class"][1] * '.' * function_name * ' ' * string(n_local) * '\n')
    end
    statements(program)
    advance!(program) # }
end

function parametersList(program::Program)
    if program.token != ')'
        kind = "argument"
        type = pop!(program) # type
        ST_routine[pop!(program)] = (type, kind, next_idx(kind, ST_routine)) # varName 
        while program.token == ','
            advance!(program) # ,
            type = pop!(program) # type
            ST_routine[pop!(program)] = (type, kind, next_idx(kind, ST_routine)) # varName
        end
    end
end

function varDec(program::Program)
    kind = "local"
    advance!(program) # var
    type = pop!(program) # type
    ST_routine[pop!(program)] = (type, kind, next_idx(kind, ST_routine)) # varName
    n_local = 1
    while program.token == ','
        advance!(program) # ,
        ST_routine[pop!(program)] = (type, kind, next_idx(kind, ST_routine)) # varName
        n_local += 1
    end
    advance!(program) # ;
    return n_local
end
function expression(program::Program)
    term(program)
    while program.token ∈ keys(ops)
        op = ops[pop!(program)] # op
        term(program)
        write(program.target, op * '\n')
    end
end

function subroutineCall(program::Program)
    is_method = 0
    routine_name = pop!(program) # subroutineName|className|varName 
    if program.token == '.'
        if routine_name ∈ union(keys(ST_routine), keys(ST_class))
            is_method = 1
            if routine_name ∈ keys(ST_routine)
                var = ST_routine[routine_name]
            else
                var = ST_class[routine_name]
            end
            write(program.target, "push " * var[2] * " " * repr(var[3]) * '\n')
            routine_name = var[1]
        end
        routine_name *= pop!(program) # .
        routine_name *= pop!(program) # subroutineName
    else
        routine_name = ST_class["class"][1] * '.' * routine_name
        is_method = 1
        write(program.target, "push pointer 0\n")
    end
    advance!(program) # (
    n_exps = expressionList(program)
    advance!(program) # )
    write(program.target, "call " * routine_name * ' ' * string(n_exps + is_method) * '\n')
end

function expressionList(program::Program)
    n_exps = 0
    if program.token != ')'
        expression(program)
        n_exps += 1
        while program.token == ','
            advance!(program) # ,
            n_exps += 1
            expression(program)
        end
    end
    return n_exps
end

function term(program::Program)
    if program.token == '('
        advance!(program) # (
        expression(program)
        advance!(program) # )
    elseif program.token_type == "symbol"
        op = unaryOps[pop!(program)] # unaryOp
        term(program)
        write(program.target, op * '\n')
    elseif program.token_type == "integerConstant" 
        write(program.target, "push constant " * pop!(program) * '\n')
    elseif program.token_type == "stringConstant"
        n_chars = length(program.token)
        write(program.target, "push constant " * string(n_chars) * '\n')
        write(program.target, "call String.new 1\n")
        for i in 1:n_chars
            write(program.target, "push constant " * string(Int(program.token[i])) * '\n')
            write(program.target, "call String.appendChar 2\n")
        end
        advance!(program)
    else
        next = next_token(program)
        if next ∈ ['.', '(']
            subroutineCall(program)
        elseif next == '['
            push(program) # varName
            advance!(program) # [
            expression(program)
            advance!(program) # ]
            write(program.target, "add\npop pointer 1\npush that 0\n")
        else
            if program.token_type == "keyword"
                kw = pop!(program)   
                if (kw == "false") || (kw == "null")
                    write(program.target, "push constant 0\n")
                elseif kw == "true"
                    write(program.target, "push constant 1\nneg\n")
                else
                    write(program.target, "push pointer 0\n")
                end
            else
                push(program) # varName
            end
        end
    end
end
function statements(program::Program)
    while program.token ∈ ["let", "if", "while", "do", "return"]
        if program.token == "let"
            letStatement(program)      
        elseif program.token == "if"
            ifStatement(program)      
        elseif program.token == "while"
            whileStatement(program)      
        elseif program.token == "do"
            doStatement(program)      
        elseif program.token == "return"
            returnStatement(program)
        end 
    end
end

function letStatement(program::Program)
    advance!(program) # let
    var = var_info(program) # varName
    if program.token == '['
        write(program.target, "push " * var[2] * ' ' * repr(var[3]) * '\n')
        advance!(program) # [
        expression(program)
        advance!(program) # ]
        write(program.target, "add\n")
        advance!(program) # =
        expression(program)
        write(program.target, "pop temp 0\npop pointer 1\npush temp 0\npop that 0\n")
    else 
        advance!(program) # =
        expression(program)
        write(program.target, "pop " * var[2] * " " * repr(var[3]) * '\n')
    end
    advance!(program) # ;
end

function ifStatement(program::Program)
    advance!(program) # if
    advance!(program) # (
    expression(program)
    L1 = "IF" * string(program.n_line) * ".TRUE"
    L2 = "IF" * string(program.n_line) * ".FALSE"
    write(program.target, "not\nif-goto " * L1 * '\n')
    advance!(program) # )
    advance!(program) # {
    statements(program)
    advance!(program) # }
    if program.token == "else"
        write(program.target, "goto " * L2 * '\n')
        write(program.target, "label " * L1 * '\n')
        advance!(program) # else
        advance!(program) # {
        statements(program)
        write(program.target, "label " * L2 * '\n')
        advance!(program) # }
    else
        write(program.target, "label " * L1 * '\n')
    end
end

function whileStatement(program::Program)
    advance!(program) # while 
    advance!(program) # (
    L1 = "WHILE" * string(program.n_line) * ".TRUE"
    L2 = "WHILE" * string(program.n_line) * ".FALSE"
    write(program.target, "label " * L1 * '\n')
    expression(program)
    write(program.target, "not\nif-goto " * L2 * '\n')
    advance!(program) # )
    advance!(program) # }
    statements(program)
    write(program.target, "goto " * L1 * '\n')
    write(program.target, "label " * L2 * '\n')
    advance!(program) # }
end

function doStatement(program::Program)
    advance!(program) # do
    subroutineCall(program)
    write(program.target, "pop temp 0\n")
    advance!(program) # ;
end

function returnStatement(program::Program)
    advance!(program) # return
    if program.token == ';'
        write(program.target, "push constant 0\n")
    else
        expression(program)
    end
    write(program.target, "return\n")
    advance!(program) # ;
end
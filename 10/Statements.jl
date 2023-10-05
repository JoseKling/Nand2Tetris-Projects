function statements(program::Program, tabs::Int)
    output = tab(tabs) * "<statements>\n"
    tabs += 1
    while program.token in ["let", "if", "while", "do", "return"]
        if program.token == "let"
            output *= letStatement(program, tabs)      
        elseif program.token == "if"
            output *= ifStatement(program, tabs)      
        elseif program.token == "while"
            output *= whileStatement(program, tabs)      
        elseif program.token == "do"
            output *= doStatement(program, tabs)      
        elseif program.token == "return"
            output *= returnStatement(program, tabs)      
        end 
    end
    tabs -= 1
    output *= tab(tabs) * "</statements>\n"
    return output
end

function letStatement(program::Program, tabs::Int)
    output = tab(tabs) * "<letStatement>\n"
    tabs += 1
    output *= print_lines(program, tabs, 2) # let varName
    if program.token == '['
        output *= print_lines(program, tabs, 1) # [
        output *= expression(program, tabs)
        output *= print_lines(program, tabs, 1) # ]
    end
    output *= print_lines(program, tabs, 1) # =
    output *= expression(program, tabs)
    output *= print_lines(program, tabs, 1) # ;
    tabs -= 1
    output *= tab(tabs) * "</letStatement>\n"
    return output 
end

function ifStatement(program::Program, tabs::Int)
    output = tab(tabs) * "<ifStatement>\n"
    tabs += 1
    output *= print_lines(program, tabs, 2) # if (
    output *= expression(program, tabs)
    output *= print_lines(program, tabs, 2) # ) {
    output *= statements(program, tabs)
    output *= print_lines(program, tabs, 1) # }
    if program.token == "else"
        output *= print_lines(program, tabs, 2) # else {
        tabs += 1
        output *= statements(program, tabs)
        tabs -= 1
        output *= print_lines(program, tabs, 1) # }
    end
    tabs -= 1
    output *= ('\t'^tabs) * "</ifStatement>\n"
    return output
end

function whileStatement(program::Program, tabs::Int)
    output = tab(tabs) * "<whileStatement>\n"
    tabs += 1
    output *= print_lines(program, tabs, 2) # while (
    tabs += 1
    output *= expression(program, tabs)
    tabs -= 1
    output *= print_lines(program, tabs, 2) # ) {
    tabs += 1
    output *= statements(program, tabs)
    tabs -= 1
    output *= print_lines(program, tabs, 1) # }
    tabs -= 1
    output *= tab(tabs) * "</whileStatement>\n"
    return output
end

function doStatement(program::Program, tabs)
    output = tab(tabs) * "<doStatement>\n"
    tabs += 1
    output *= print_lines(program, tabs, 1) # do
    output *= subroutineCall(program, tabs)
    output *= print_lines(program, tabs, 1) # ;
    tabs -= 1
    output *= tab(tabs) * "</doStatement>\n"
    return output
end

function returnStatement(program::Program, tabs::Int)
    output = tab(tabs) * "<returnStatement>\n"
    tabs += 1
    output *= print_lines(program, tabs, 1) # return
    if program.token != ';'
        output *= expression(program, tabs)
    end
    output *= print_lines(program, tabs, 1) # ;
    tabs -= 1
    output *= tab(tabs) * "</returnStatement>\n"
    return output
end
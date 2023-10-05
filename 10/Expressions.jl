function expression(program::Program, tabs::Int)
    output = tab(tabs) * "<expression>\n"
    tabs += 1
    output *= term(program, tabs)
    while program.token in ops
        output *= print_lines(program, tabs, 1) #op 
        output *= term(program, tabs)
    end
    tabs -= 1
    output *= tab(tabs) * "</expression>\n"
    return output
end

function subroutineCall(program::Program, tabs::Int)
    #output = tab(tabs) * "<subroutineCall>\n"
    #tabs += 1
    output = print_lines(program, tabs, 1) # subroutineName|className|varName
    if program.token == '.'
        output *= print_lines(program, tabs, 2) # . subroutineName
    end
    output *= print_lines(program, tabs, 1) # (
    output *= expressionList(program, tabs)
    output *= print_lines(program, tabs, 1) # )
    #tabs -= 1
    #output *= tab(tabs) * "</subroutineCall>\n"
    return output
end

function expressionList(program::Program, tabs::Int)
    output = tab(tabs) * "<expressionList>\n"
    if program.token != ')'
        tabs += 1
        output *= expression(program, tabs)
        while program.token == ','
            output *= print_lines(program, tabs, 1) # ,
            output *= expression(program, tabs)
        end
        tabs -= 1
    end
    output *= tab(tabs) * "</expressionList>\n"
    return output
end

function term(program::Program, tabs::Int)
    output = tab(tabs) * "<term>\n"
    tabs += 1
    if program.token == '('
        output *= print_lines(program, tabs, 1) # (
        output *= expression(program, tabs)
        output *= print_lines(program, tabs, 1) # )
    elseif program.token_type == "symbol"
        output *= print_lines(program, tabs, 1) # unaryOp
        output *= term(program, tabs)
    elseif program.token_type in ["integerConstant", "stringConstant", "keywordConstant"] 
        output *= print_lines(program, tabs, 1) # integerConstant|stringConstant|keywordConstant|varName|subroutineCall
    else
        next = next_token(program)
        if next in ['.', '(']
            output *= subroutineCall(program, tabs)
        elseif next == '['
            output *= print_lines(program, tabs, 2) # varName [
            output *= expression(program, tabs)
            output *= print_lines(program, tabs, 1) # ]
        else
            output *= print_lines(program, tabs, 1) # varName
        end
    end
    tabs -= 1
    output *= tab(tabs) * "</term>\n"
    return output
end
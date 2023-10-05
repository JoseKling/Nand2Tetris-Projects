function class_comp(program::Program, tabs::Int)
    output = tab(tabs) * "<class>\n"
    tabs += 1
    output *= print_lines(program, tabs, 3) # class className {
    while program.token in ["static", "field", "constructor", "function", "method"]
        if program.token in ["static", "field"]
            output *= classVarDec(program, tabs)
        else
            output *= subroutineDec(program, tabs)
        end
    end
    output *= tab(tabs) * string(program) * '\n' # }
    tabs -= 1
    output *= tab(tabs) * "</class>\n"
    return output
end

function classVarDec(program::Program, tabs::Int)
    output = tab(tabs) * "<classVarDec>\n"
    tabs += 1
    output *= print_lines(program, tabs, 3) # static|field type varName
    while program.token == ','
        output *= print_lines(program, tabs, 2) # , varName
    end
    output *= print_lines(program, tabs, 1) # ;
    tabs -= 1
    output *= tab(tabs) * "</classVarDec>\n"
    return output
end

function subroutineDec(program::Program, tabs::Int)
    output = tab(tabs) * "<subroutineDec>\n"
    tabs += 1
    output *= print_lines(program, tabs, 4) # constructor|function|method void|type subroutineName (
    output *= parametersList(program, tabs)
    output *= print_lines(program, tabs, 1) # )
    output *= subroutineBody(program, tabs)
    tabs -= 1
    output *= tab(tabs) * "</subroutineDec>\n"
    return output
end

function parametersList(program::Program, tabs::Int)
    output = tab(tabs) * "<parametersList>\n"
    tabs += 1
    if program.token != ')'
        output *= print_lines(program, tabs, 2) # type varName
        while program.token == ','
            output *= print_lines(program, tabs, 3) # , type varName
        end
    end
    tabs -= 1
    output *= tab(tabs) * "</parametersList>\n"
    return output
end

function subroutineBody(program::Program, tabs::Int)
    output = tab(tabs) * "</subroutineBody>\n"
    tabs += 1
    output *= print_lines(program, tabs, 1) # {
    while program.token == "var" 
        output *= varDec(program, tabs)
    end
    output *= statements(program, tabs)
    output *= print_lines(program, tabs, 1) # }
    tabs -= 1
    output *= tab(tabs) * "</subroutineBody>\n"
    return output
end

function varDec(program::Program, tabs::Int)
    output = tab(tabs) * "<varDec>\n"
    tabs += 1
    output *= print_lines(program, tabs, 3) # var type varName
    while program.token == ','
        output *= print_lines(program, tabs, 2) # , varName
    end
    output *= print_lines(program, tabs, 1) # ;
    tabs -= 1
    output *= tab(tabs) * "</varDec>\n"
    return output
end
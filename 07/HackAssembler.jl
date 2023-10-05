function HackAssembler(file_name)
    if findfirst('.', file_name) === nothing
        write_name = file_name * ".asm"
    else
        write_name = file_name[1:end-findfirst('.', file_name[end:-1:1])] * ".asm"
    end
    touch(write_name)
    open(file_name, "r") do vm_file
        open(write_name, "w") do asm_file
            line_number = 1
            while !eof(vm_file)
                line = readline(vm_file)
                cmd = parser(line)
                if cmd !== nothing
                    asm_cmd = vm2asm(cmd, write_name, line_number)
                    write(asm_file, asm_cmd)
                end
                line_number += 1
            end
            write(asm_file, "//Program end\n(END)\n@END\n0;JMP\n")
        end
    end
    return nothing
end


function parser(line)
    start = findfirst(!isspace, line)
    if (start === nothing) || (line[start: start+1] == "//")
        return nothing
    end
    cmd = String[]
    while start !== nothing
        next = findfirst(isspace, line[start:end]) 
        if next === nothing
            append!(cmd, [line[start:end]])
            start = nothing
        else
            append!(cmd, [line[start:start+next-2]])
            start += next + findfirst(!isspace, line[start+next:end]) - 1
        end
    end
    return cmd
end

function vm2asm(cmd, file_name, line_number)
    static_name = split(file_name, "/")[end]
    static_name = static_name[1:end-4]
    asm_cmd = "//"
    for token in cmd
        asm_cmd = asm_cmd * " " * token
    end
    asm_cmd = asm_cmd * "\n"

    # PUSH commands
    if cmd[1] == "push"
        if !all(isdigit, cmd[3])
            error("Line " * string(line_number) * ": Number expected after segment. Got " * cmd[3] * " instead.")
        end
        if cmd[2] == "constant"
            next = "@" * cmd[3] * "\nD=A\n"            
        elseif cmd[2] == "local"
            next = "@" * cmd[3] * "\nD=A\n@LCL\nA=D+M\nD=M\n"            
        elseif cmd[2] == "argument"
            next = "@" * cmd[3] * "\nD=A\n@ARG\nA=D+M\nD=M\n"            
        elseif cmd[2] == "this"
            next = "@" * cmd[3] * "\nD=A\n@THIS\nA=D+M\nD=M\n"            
        elseif cmd[2] == "that"
            next = "@" * cmd[3] * "\nD=A\n@THAT\nA=D+M\nD=M\n"            
        elseif cmd[2] == "static"
            next = "@" * static_name * "." * cmd[3] * "\nD=M\n"            
        elseif cmd[2] == "pointer"
            if cmd[3] == "0"
                next = "@THIS\nD=M\n"            
            elseif cmd[3] == "1"
                next = "@THAT\nD=M\n"            
            else
                error("Line " * string(line_number) * ": Expected 0 or 1 after 'pointer'. Got " * cmd[3] * " instead.")
            end
        elseif cmd[2] == "temp"
            next = "@" * cmd[3] * "\nD=A\n@R5\nD=D+A\n"            
        else
            error("Line " * string(line_number) * ": Invalid segment: " * cmd[2])
        end
        next = next * "@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    
    # POP commands
    elseif cmd[1] == "pop"
        if !all(isdigit, cmd[3])
            error("Line " * string(line_number) * ": Number expected after segment. Got " * cmd[3] * " instead.")
        end
        if cmd[2] == "argument"
            next = "@ARG\nD=M\n@" * cmd[3] * "\nD=D+A\n@R13\nM=D\n"
        elseif cmd[2] == "local"
            next = "@LCL\nD=M\n@" * cmd[3] * "\nD=D+A\n@R13\nM=D\n"
        elseif cmd[2] == "static"
            next = "@" * static_name * "." * cmd[3] * "\nD=A\n@R13\nM=D\n"
        elseif cmd[2] == "this"
            next = "@THIS\nD=M\n@" * cmd[3] * "\nD=D+A\n@R13\nM=D\n"
        elseif cmd[2] == "that"
            next = "@THAT\nD=M\n@" * cmd[3] * "\nD=D+A\n@R13\nM=D\n"
        elseif cmd[2] == "pointer"
            if cmd[3] == "0"
                next = "@THIS\nD=A\n@R13\nM=D\n"            
            elseif cmd[3] == "1"
                next = "@THAT\nD=A\n@R13\nM=D\n"            
            else
                error("Line " * string(line_number) * ": Expected 0 or 1 after 'pointer'. Got " * cmd[3] * " instead.")
            end
        elseif cmd[2] == "temp"
            next = "@R5\nD=A\n@" * cmd[3] * "\nD=D+A\n@R13\nM=D\n"
        end
        next = next * "@SP\nM=M-1\nA=M\nD=M\n@R13\nA=M\nM=D\n"

    # ALGEBRAIC AND LOGIC commands
    elseif cmd[1] == "add"
        next = "@SP\nM=M-1\nA=M\nD=M\nA=A-1\nM=M+D\n"
    elseif cmd[1] == "sub"
        next = "@SP\nM=M-1\nA=M\nD=M\nA=A-1\nM=M-D\n"
    elseif cmd[1] == "neg"
        next = "@SP\nA=M-1\nM=-M\n"
    elseif cmd[1] == "eq"
        next = "@SP\nM=M-1\nA=M\nD=M\n@R13\nM=D\n@SP\nA=M-1\nD=M\n@R13\nD=M-D\n"
        next = next * "@TRUE" * string(line_number) * "\nD;JEQ\n"
        next = next * "@SP\nA=M-1\nM=0\n@DONE"*string(line_number)*"\n0;JMP\n"
        next = next * "(TRUE"*string(line_number)*")\n@SP\nA=M-1\nM=-1\n"
        next = next * "(DONE"*string(line_number)*")\n"
    elseif cmd[1] == "gt"
        next = "@SP\nM=M-1\nA=M\nD=M\n@R13\nM=D\n@SP\nA=M-1\nD=M\n@R13\nD=D-M\n"
        next = next * "@TRUE" * string(line_number) * "\nD;JGT\n"
        next = next * "@SP\nA=M-1\nM=0\n@DONE"*string(line_number)*"\n0;JMP\n"
        next = next * "(TRUE"*string(line_number)*")\n@SP\nA=M-1\nM=-1\n"
        next = next * "(DONE"*string(line_number)*")\n"
    elseif cmd[1] == "lt"
        next = "@SP\nM=M-1\nA=M\nD=M\n@R13\nM=D\n@SP\nA=M-1\nD=M\n@R13\nD=M-D\n"
        next = next * "@TRUE" * string(line_number) * "\nD;JGT\n"
        next = next * "@SP\nA=M-1\nM=0\n@DONE"*string(line_number)*"\n0;JMP\n"
        next = next * "(TRUE"*string(line_number)*")\n@SP\nA=M-1\nM=-1\n"
        next = next * "(DONE"*string(line_number)*")\n"
    elseif cmd[1] == "and"
        next = "@SP\nM=M-1\nA=M\nD=M\nA=A-1\nM=M&D\n"
    elseif cmd[1] == "or"
        next = "@SP\nM=M-1\nA=M\nD=M\nA=A-1\nM=M|D\n"
    elseif cmd[1] == "not"
        next = "@SP\nA=M-1\nM=!M\n"
    else
        error("Line " * string(line_number) * ": Not a valid command.")
    end
    asm_cmd = asm_cmd * next
end
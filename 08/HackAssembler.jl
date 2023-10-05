function HackAssembler()
    return HackAssembler(pwd())
end

function HackAssembler(folder_name::String)
    asm_name = split(folder_name, "/")[end-1]
    asm_name = folder_name * asm_name * ".asm"
    file_names = readdir(folder_name)
    filter!(x-> (x[end-2:end] == ".vm"), file_names)
    line_number = 0 
    touch(asm_name)
    open(asm_name, "w") do asm_file
        write(asm_file, "// Initialize Stack\n@256\nD=A\n@SP\nM=D\n")
        sys_init = vm2asm(["call"; "Sys.init"; "0"], asm_name, line_number)
        write(asm_file, sys_init)
    end
    line_number += 1
    for file_name in file_names
        open(folder_name * file_name, "r") do vm_file
            open(asm_name, "a") do asm_file
                while !eof(vm_file)
                    line = readline(vm_file)
                    cmd = split(line)
                    if (!isempty(cmd)) && (cmd[1] != "//")
                        asm_cmd = vm2asm(cmd, file_name, line_number)
                        write(asm_file, asm_cmd)
                    end
                    line_number += 1
                end
            end
        end
    end
    open(asm_name, "a") do asm_file
        write(asm_file, "// Program end\n(END)\n@END\n0;JMP\n")
    end

    open(asm_name, "r") do asm_file
        LN = 0
        touch(asm_name * ".LN")
        open(asm_name * ".LN", "w") do LN_file
            while !eof(asm_file)
                line = readline(asm_file)
                next = line
                if (line[1:2] != "//") && (line[1] != '(')
                    next = next * "        // " * string(LN)
                    LN += 1
                end
                write(LN_file, next * "\n")
            end
        end
    end

    return nothing
end

function vm2asm(cmd, file_name, line_number)
    asm_cmd = "//"
    i = 1
    while (i <= length(cmd)) && (cmd[i] != "//")
        asm_cmd = asm_cmd * " " * cmd[i]
        i += 1
    end
    asm_cmd = asm_cmd * "\n"
    if cmd[1] == "push"
        next = write_push(cmd, line_number, file_name)
    elseif cmd[1] == "pop"
        next = write_pop(cmd, line_number, file_name)
    elseif cmd[1] == "label"
        next = "(" * cmd[2] * ")\n"
    elseif cmd[1] == "goto"
        next = "@" * cmd[2] * "\n0;JMP\n"
    elseif cmd[1] == "if-goto"
        next = "@SP\nM=M-1\nA=M\nD=M\n@" * cmd[2] * "\nD+1;JEQ\n"
    elseif cmd[1] == "function"
        next = write_function(cmd)
    elseif cmd[1] == "call"
        next = write_call(cmd, line_number)
    elseif cmd[1] == "return"
        next = write_return()
    else
        next = write_alglog(cmd, line_number)
    end
    asm_cmd = asm_cmd * next
end

function write_push(cmd, line_number, file_name)
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
        next = "@" * file_name[1:end-3] * "." * cmd[3] * "\nD=M\n"            
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
    return next * "@SP\nA=M\nM=D\n@SP\nM=M+1\n"
end

function write_pop(cmd, line_number, file_name)
    if !all(isdigit, cmd[3])
        error("Line " * string(line_number) * ": Number expected after segment. Got " * cmd[3] * " instead.")
    end
    if cmd[2] == "argument"
        next = "@ARG\nD=M\n@" * cmd[3] * "\nD=D+A\n@R13\nM=D\n"
    elseif cmd[2] == "local"
        next = "@LCL\nD=M\n@" * cmd[3] * "\nD=D+A\n@R13\nM=D\n"
    elseif cmd[2] == "static"
        next = "@" * file_name[1:end-3] * "." * cmd[3] * "\nD=A\n@R13\nM=D\n"
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
    return next * "@SP\nM=M-1\nA=M\nD=M\n@R13\nA=M\nM=D\n"
end

function write_alglog(cmd, line_number)
    if cmd[1] == "add"
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
    return next
end

function write_function(cmd)
    next = "(" * cmd[2] * ")\n"
    nVars = parse(Int, cmd[3])
    if nVars > 0
        next = next * "@SP\nA=M\n"
        for i in 1:nVars
            next = next * "M=0\nA=A+1\n"
        end
        next = next * "D=A\n@SP\nM=D\n"
    end
    return next
end

function write_call(cmd, line_number)
    next = "@"* (split(cmd[2], ".")[1]) * "\$ret." * string(line_number) * "\nD=A\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    next = next * "@LCL\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    next = next * "@ARG\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    next = next * "@THIS\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    next = next * "@THAT\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    next = next * "@SP\nD=M\n@5\nD=D-A\n@" * cmd[3] * "\nD=D-A\n@ARG\nM=D\n"
    next = next * "@SP\nD=M\n@LCL\nM=D\n"
    next = next * "@" * cmd[2] * "\n0;JMP\n"
    next = next * "(" * (split(cmd[2], ".")[1]) * "\$ret." * string(line_number) * ")\n"
    return next
end

function write_return()
    next = "@LCL\nD=M\n@5\nA=D-A\nD=M\n@R13\nM=D\n"
    next = next * "@SP\nA=M-1\nD=M\n@ARG\nA=M\nM=D\n@ARG\nD=M\n@SP\nM=D+1\n"
    next = next * "@LCL\nM=M-1\nA=M\nD=M\n@THAT\nM=D\n"
    next = next * "@LCL\nM=M-1\nA=M\nD=M\n@THIS\nM=D\n"
    next = next * "@LCL\nM=M-1\nA=M\nD=M\n@ARG\nM=D\n"
    next = next * "@LCL\nM=M-1\nA=M\nD=M\n@LCL\nM=D\n"
    next = next * "@R13\nA=M\n0;JMP\n"
    return next
end

function HackAssemblerNoSys(file_name::String)
    asm_name = file_name[1:end-3] * ".asm"
    touch(asm_name)
    open(file_name, "r") do vm_file
        line_number = 1
        open(asm_name, "w") do asm_file
            while !eof(vm_file)
                line = readline(vm_file)
                cmd = split(line)
                if (!isempty(cmd)) && (cmd[1] != "//")
                    asm_cmd = vm2asm(cmd, asm_name, line_number)
                    write(asm_file, asm_cmd)
                end
                line_number += 1
            end
        end
    end
    open(asm_name, "a") do asm_file
        write(asm_file, "// Program end\n(END)\n@END\n0;JMP\n")
    end
    return nothing
end
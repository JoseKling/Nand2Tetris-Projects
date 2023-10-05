global ST_class = Dict{String, Tuple{String, String, Int}}()
global ST_routine = Dict{String, Tuple{String, String, Int}}()
global ops = Dict('+' => "add", 
           '-' => "sub", 
           '*' => "call Math.multiply 2", 
           '/' => "call Math.divide 2", 
           '&' => "and", 
           '|' => "or", 
           '>' => "gt",
           '<' => "lt", 
           '=' => "eq")
global unaryOps = Dict('-'=>"neg",
                '~'=>"not")

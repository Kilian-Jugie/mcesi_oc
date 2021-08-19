local stdlib = {}

function stdlib.strsplit(inputstr, sep)
    local ret={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(ret, str)
    end
    return ret
end

return stdlib
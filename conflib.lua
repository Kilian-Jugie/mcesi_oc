local conflib = {}
local component = require("component")
package.loaded.fslib = nil
local fslib = require("fslib")
local fs = component.filesystem
package.loaded.stdlib = nil
local std = require("stdlib")
local internal = {}

conflib.tokens = {}
conflib.conf = {}
conflib.parse = {}

conflib.tokens.separator = "="
conflib.conf.trim = true

conflib.conftype = {
    int = 1,
    float = 2,
    bool = 3,
    string = 4
}

conflib.parse.codes = {
    success = 0,
    file_not_found = 1,
    separator_not_found = 2
}

conflib.parse.codes_str = {
    [conflib.parse.codes.success] = "success",
    [conflib.parse.codes.file_not_found] = "file not found",
    [conflib.parse.codes.separator_not_found] = "separator not found"
}

-- From http://lua-users.org/wiki/StringTrim
-- Has low performance when lot of spaces but very efficient in our case
--- @param s string
--- @return string
function internal.low_trim(s)
    return s:match'^%s*(.*%S)' or ''
end

--- @param line string
--- @return integer,string,string
function internal.parse_line(line)
    local sepIndex = string.find(line, conflib.tokens.separator)
    if sepIndex == nil then return conflib.parse.codes.separator_not_found, nil end
    local name = string.sub(line, 0, sepIndex-1)
    local value = string.sub(line, sepIndex+1)
    if conflib.conf.trim then
        name = internal.low_trim(name)
        value = internal.low_trim(value)
    end
    return conflib.parse.codes.success,name,value

end

--- @param error integer
--- @return string
function conflib.parse_error_to_str(error)
    return conflib.parse.codes_str[error]
end

--- @param file string
--- @return integer,table
function conflib.parse_file(file)
    local ret = {}
    if not fs.exists(file) then
        return conflib.parse.codes.file_not_found, nil
    end
    local f = io.open(file)
    local c,n,v -- Is this an optimization in lua ?
    for line in f:lines() do
        c,n,v = internal.parse_line(line)
        if c ~= conflib.parse.codes.success then return c, nil end
        ret[n] = v
    end
    f:close()
    return conflib.parse.codes.success, ret
end

return conflib
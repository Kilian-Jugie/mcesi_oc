local fslib = {}
local component = require("component")
local fs = component.filesystem

fslib.chunk_size = 32

function fslib.read_file(filepath)
    local f = fs.open(filepath)
    local content, chunk
    while chunk ~= nil do
        content = content..fs.read(f, fslib.chunk_size)
    end
    fs.close(f)
end

return fslib
local ksyslib = require("ksyslib")
-- Used components:
--   Filesystem (nocheck, should exists in any conditions)
local component = require("component")
local conflib = require("conflib")
local fs = component.filesystem
local ksys = {}

ksys.return_codes = {
    success = 0,
    restart_required = 3,
    not_installed = 2,
    config_error = 1
}

function ksys.start(conf)
    io.write("Starting "..conf["name"].."...\n")
    
end

function ksys.init()
    if not ksys.is_installed() then
        -- TODO: detect in non standard path
        io.write("ksys not detected on system. Would you like to install ? y/(n) ")
        local c = io.read()
        io.write("\n")
        if c == "y" then
            ksys.install()
            io.write("Please ensure configuration at "..ksyslib.filepath.conf.." is correct and restart ksys\n")
            return ksys.return_codes.restart_required
        else
            io.write("ksys not detected... exiting\n")
            return ksys.return_codes.not_installed
        end
    end
    local code, conf = conflib.parse(ksyslib.filepath.conf)
    if code ~= conflib.parse.codes.success then
        io.write("An error occured during file parsing: "..conflib.parse_error_to_str(code).."\n")
        return ksys.return_codes.config_error
    end
    return ksys.start(conf)
end

function ksys.is_installed()
    return fs.exists(ksyslib.filepath.conf)
end

function ksys.uninstall()
    fs.remove(ksyslib.filepath.conf)
end

function ksys.install()
    io.write("installing ksys...")
    local fconf = fs.open(ksyslib.filepath.conf)
    fs.write(fconf, ksyslib.default.conf)
    fs.close(fconf)
end

return ksys.init()

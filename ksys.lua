package.loaded.stdlib = nil
local stdlib = require "stdlib"
package.loaded.ksyslib = nil
local ksyslib = require "ksyslib"
-- Used components:
--   Filesystem (nocheck, should exists in any conditions)
local component = require "component"
package.loaded.conflib = nil
local conflib = require "conflib"
local fs = component.filesystem
local ksys = {}

ksys.return_codes = {
    success = 0,
    restart_required = 3,
    not_installed = 2,
    config_error = 1
}

ksys.callbacks = {}
ksys.modules = {}

function ksys.load_modules(path)
    local objs, mod = fs.list(path), nil
    for _, value in pairs(objs) do
        if ~fs.isDirectory(value) then
            mod = require(value)
            ksys.modules[mod.name] = mod
            mod.initialize()
            mod.register_callbacks(ksys.callbacks)
        end
    end
end

local function help(_, _)
    for key, value in pairs(ksys.callbacks) do
        io.write(key.."\t")
        if value.help ~= nil then
            io.write(value.help)
        end
        io.write("\n")
    end
    return ksyslib.callbacks.return_codes.success
end

local function exit(_, _)
    return ksyslib.callbacks.return_codes.exit_required
end

function ksys.start(conf)
    io.write("Starting "..conf["hostname"].."...\n")
    io.write("Loading modules")
    ksys.load_modules(ksyslib.path.modules)

    -- We load our callbacks in last to avoid any override
    ksys.callbacks["help"].callback = help
    ksys.callbacks["help"].help = "Show help window"
    ksys.callbacks["exit"].callback = exit
    ksys.callbacks["exit"].help = "Stop ksys"
    ksys.callbacks["uninstall"].callback = ksys.uninstall
    ksys.callbacks["uninstall"].help = "Uninstall ksys"

    io.write("ksys ready. Type 'help' for help and 'exit' to stop ksys")
    local shouldStop = false
    local inp, parsed, c = "", {}, 0
    while ~shouldStop do
        io.write("> ")
        inp = io.read()
        parsed = stdlib.strsplit(inp, " ")
        if ksys.callbacks[parsed[1]] ~= nil then
            c = ksys.callbacks[parsed[1]].callback(inp, parsed)
        else
            io.write("Invalid input. Type 'help' for a list of commands...")
        end
        if c == ksyslib.callbacks.return_codes.exit_required then
            shouldStop = true
        end
    end
    return ksys.return_codes.success
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
    local code, conf = conflib.parse_file(ksyslib.filepath.conf)
    if code ~= conflib.parse.codes.success then
        io.write("An error occured during file parsing: "..conflib.parse_error_to_str(code).."\n")
        return ksys.return_codes.config_error
    end
    return ksys.start(conf)
end

function ksys.is_installed()
    return fs.exists(ksyslib.filepath.conf)
end

function ksys.uninstall(_,_)
    fs.remove(ksyslib.filepath.conf)
    fs.remove(ksyslib.path.conf)
    fs.remove(ksyslib.path.modules.."/*")
    fs.remove(ksyslib.path.modules)
end

function ksys.install()
    io.write("Installing ksys...\n")
    fs.makeDirectory(ksyslib.path.conf)
    fs.makeDirectory(ksyslib.path.modules)
    local fconf = io.open(ksyslib.filepath.conf, "w")
    fconf:write(ksyslib.default.conf)
    fconf:close()
    io.write("Installation done\n")
end

return ksys.init()

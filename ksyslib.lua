local ksys = {}
ksys.filepath = {}
ksys.default = {}
ksys.path = {}

ksys.path.conf = "/etc/ksys"
ksys.path.modules = "./modules"
ksys.filepath.conf = ksys.path.conf.."/ksys.conf"
ksys.default.conf = "hostname = unamed"

ksys.callbacks = {}
ksys.callbacks.return_codes = {
    success = 0,
    restart_required = 1,
    exit_required = 2
    
}

return ksys
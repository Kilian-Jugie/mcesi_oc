local ksys = {}
ksys.filepath = {}
ksys.default = {}
ksys.path = {}

ksys.path.conf = "/etc/ksys"
ksys.filepath.conf = ksys.path.conf.."/ksys.conf"
ksys.default.conf = "hostname = unamed"

return ksys
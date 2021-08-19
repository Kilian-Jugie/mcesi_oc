local ksys = {}
ksys.net = {}
ksys.net.server = {}
ksys.net.client = {}
ksys.net.protocols = {  }

ksys.net.protocols.ksys.port = 3008
ksys.net.protocols.echo.port = 7
ksys.net.protocols.dns.port = 53

local component = require("component")
function ksys.net.client.send(addr, protocol, data)
    return component.modem.send(addr, protocol.port, data)
end

function ksys.net.client.broadcast(protocol, data)
    return component.modem.broadcast(protocol.port, data)
end

return ksys
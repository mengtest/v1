local client = require "client"
local socket = require "skynet.socket"
local log = require "log"

function client.read_message(self)
	local fd=self.fd
	if socket.invalid(fd) then return end
	local s=socket.read(fd,2)
	if not s then return end
	local len=string.unpack(">H",s)
	return socket.read(fd,len),len
end


function client.send_message(self, t, data)
	local msg=client.pack(t, data)
	local fd=self.fd
	socket.write(fd, msg)
end

function client.start(self,on_warning)
	socket.start(self.fd)
	socket.warning(self.fd,on_warning)
end

return client

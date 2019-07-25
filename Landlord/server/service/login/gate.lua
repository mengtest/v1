local skynet = require "skynet"
local socket = require "skynet.socket"
local socketdriver=require "skynet.socketdriver"
local service = require "service"
local cluster = require "skynet.cluster"
local log = require "log"

local gate = {}
local data = { socket = {} }
local authlist ={}
local auth_index = 0


local function auth_socket(auth,fd,addr)
	return skynet.call(auth, "lua", "auth" , fd, addr)
end

local function new_socket(fd, addr)
	data.socket[fd] = "[AUTH]"
	auth_index=auth_index+1
	if auth_index>#authlist then
		auth_index=1
	end
	local auth=authlist[auth_index]
	log(string.format("accept %d(%s) dispatch [:%08x]",fd,addr,auth))
	local ok,err=auth_socket(auth,fd,addr)
	if not ok then
		log(err)
	end
	data.socket[fd] = nil
	socketdriver.close(fd)
end

function gate.open(ip, port, auth)
	assert(data.fd == nil, "Already open")
	authlist=auth
	data.fd = socket.listen(ip, port)
	data.ip = ip
	data.port = port
	socket.start(data.fd, new_socket)
	log("open %s:%d",ip, port)
end

function gate.close()
	assert(data.fd)
	log("close %s:%d", data.ip, data.port)
	socket.close(data.fd)
	data.fd = nil
	data.ip = nil
	data.port = nil
end

service.init {
	command = gate,
	info = data,
	init=function()
	end,
	release=function()
		if data.fd then
			gate.close()
		end
	end
}

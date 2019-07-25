local skynet = require "skynet"
local gateserver = require "snax.gateserver"
local netpack = require "skynet.netpack"
local circ_queue = require "circ_queue"
local log = require "log"


local watchdog

local connection = {}	-- fd -> connection : { fd , client, agent , ip, mode, timestamp, pktcount}
local forwarding = {}	-- agent -> connection

local pktspeed
local timeout

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local handler = {}
local CMD = {}

local queue
local function checktimeout()
	while true do
		local now=skynet.now()
		while true do
			local fd=queue.top()
			if not fd then break end
			local c=connection[fd]
			if c then
				if c.time_message+timeout>now then
					break
				end
				CMD.kick(0,fd)
				log("kick %d timeout",fd)
			end
			queue.pop()
		end
		skynet.sleep(100)
	end
end

function handler.open(source, conf)
	watchdog = conf.watchdog or source
	timeout=conf.timeout
	pktspeed=conf.pktspeed
	if timeout then
		queue=circ_queue()
		skynet.fork(checktimeout)
	end
end

function handler.message(fd, msg, sz)
	-- recv a package, forward it
	local c = connection[fd]
	local now=skynet.now()
	c.time_message=now
	if pktspeed then
		if c.last_speedcheck+100<now then
			c.last_speedcheck=now
			if c.pktcount>pktspeed then
				c.pktmax=c.pktmax+1
				if c.pktmax > 3 then
					CMD.kick(0,fd)
					log("kick %d so much message",fd)
					return
				else
					log("want kick %d so much message %d",fd,c.pktcount)
				end				
			else
				c.pktmax=0
			end
			c.pktcount=0
		else
			c.pktcount=c.pktcount+1
			-- if c.pktcount>pktspeed then
			-- 	c.pktmax=c.pktmax+1
			-- 	if c.pktmax > 3 then
			-- 		CMD.kick(0,fd)
			-- 		log("kick %d so much message",fd)
			-- 		return
			-- 	end
			-- end
		end	
	end
	local agent = c.agent
	if agent then
		skynet.redirect(agent, c.client, "client", fd, msg, sz)
	else
		skynet.send(watchdog, "lua", "socket", "data", fd, netpack.tostring(msg, sz), sz)
	end
end

function handler.connect(fd, addr)
	local now=skynet.now()
	local c = {
		fd = fd,
		ip = addr,
		timestamp=now,
		time_message=now,
		last_speedcheck=0,
		pktcount=0,
		pktmax=0
	}
	if timeout then
		-- 15秒连接无消息超时
		c.time_message = c.time_message - timeout + 1500
		queue.push(fd)
	end
	connection[fd] = c
	skynet.send(watchdog, "lua", "socket", "open", fd, addr)
end

local function unforward(c)
	if c.agent then
		forwarding[c.agent] = nil
		c.agent = nil
		c.client = nil
	end
end

local function close_fd(fd)
	local c = connection[fd]
	if c then
		unforward(c)
		connection[fd] = nil
	end
end

function handler.disconnect(fd)
	close_fd(fd)
	skynet.send(watchdog, "lua", "socket", "close", fd)
end

function handler.error(fd, msg)
	close_fd(fd)
	skynet.send(watchdog, "lua", "socket", "error", fd, msg)
end

function handler.warning(fd, size)
	skynet.send(watchdog, "lua", "socket", "warning", fd, size)
end

function CMD.forward(source, fd, client, address)
	local c = connection[fd]
	if c then
		unforward(c)
		c.client = client or 0
		c.agent = address or source
		forwarding[c.agent] = c
		gateserver.openclient(fd)
	end
	return c
end

function CMD.accept(source, fd)
	local c = assert(connection[fd])
	unforward(c)
	gateserver.openclient(fd)
end

function CMD.kick(source, fd)
	gateserver.closeclient(fd)
end

function handler.command(cmd, source, ...)
	local f = assert(CMD[cmd])
	return f(source, ...)
end

gateserver.start(handler)

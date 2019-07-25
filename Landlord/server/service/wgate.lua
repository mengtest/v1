local skynet = require "skynet"
local socket = require "skynet.socket"
local log=require "log"
local service=require "service"

local mode,requiref = ...

if mode == "agent" then

local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local whandler = require "whandler"
local json=require "rapidjson.c"
require(requiref)

local _M={}

local function response(id, statuscode, bodyfunc, header)
	local ok, err = httpd.write_response(sockethelper.writefunc(id),statuscode, bodyfunc, header)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet.error(string.format("fd = %d, %s", id, err))
	end
end

local function dispatch(id)
	socket.start(id)
	-- limit request body size to 8192 (you can pass nil to unlimit)
	local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
	if code then
		if code ~= 200 then
			response(id, code)
		else
			local args
			local path, query = urllib.parse(url)
			if method=="GET" then
				if query then
					args=urllib.parse_query(query)
				end
			elseif method=="POST" then
				if body~="" then
					args=json.decode(body)
				end
			else
				response(id,405)
			end
			local h=whandler[path]
			if not h then
				response(id,501)
			else
				header={}
				local ok,code,body=xpcall(h,debug.traceback,args,header)
				if ok then
					response(id, code, body,header)
				else
					response(id,500,code)
				end
			end
		end
	else
		if url == sockethelper.socket_error then
			log("socket closed")
		else
			log(url)
		end
	end
	socket.close(id)
end

service.init{
	command=_M,
	dispatch={
		lua=function (session,_, cmd, ...)
			if type(cmd)=="number" then
				if session>0 then
					skynet.retpack(dispatch(cmd))
				else
					dispatch(cmd)
				end
			else
				local f = _M[cmd]
				if f then
					if session>0 then
						skynet.retpack(f(...))
					else
						f(...)
					end
				else
					log("Unknown command : [%s]", cmd)
					if session>0 then
						skynet.response()(false)
					end
				end
			end			
		end
	},
}

else

local _M={}
local agent = {}
local listen_fd

function _M.start_agent(cnt)
	for i=1,math.max(1,cnt) do
		table.insert(agent, skynet.newservice(SERVICE_NAME, "agent",mode))
	end
end

function _M.restart_agent(cnt)
	local new_agent={}
	for i=1,math.max(1,cnt) do
		table.insert(new_agent, skynet.newservice(SERVICE_NAME, "agent"))
	end
	agent,new_agent=new_agent,agent
	skynet.sleep(100)
	while #new_agent>0 do
		skynet.call(table.remove(new_agent),"lua","release")
	end
end

function _M.release()
	if listen_fd then
		socket.close(listen_fd)
		listen_fd=nil
	end
	while #agent>0 do
		skynet.call(table.remove(agent),"lua","release")
	end
end

function _M.start(ip,port,cnt)
	_M.start_agent(cnt)
	listen_fd= socket.listen(ip, port)
	log("Listen web %s:%d",ip, port)
	local balance=1
	socket.start(listen_fd , function(id, addr)
		log("%s connected, pass it to agent :%08x", addr, agent[balance])
		skynet.send(agent[balance], "lua", id)
		balance = balance + 1
		if balance > #agent then
			balance = 1
		end
	end)
end

service.init{
	command=_M,
}

end

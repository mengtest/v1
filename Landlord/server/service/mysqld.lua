local skynet = require "skynet"
local service = require "service"
local mysql=require 'skynet.db.mysql'

local con
local opt
local last
local fincnt=0
local allcnt=0
local errcnt=0
local _M={}

local function ret(f,sql,d,...)
	if f then
		f(sql,d)
	end
	return ...
end

local function check_ping()
	while con do
		local now=skynet.now()
		local nextti=last+opt.ping*100-now
		if nextti>0 then
			skynet.sleep(nextti)
		else
			last=now
			local o,e=pcall(mysql.ping,con)
			if not o then
				skynet.error(e)
			end
		end
	end
end

local function inner_execute(call,sql,...)
	--skynet.error(sql)
	last=skynet.now()
	allcnt=allcnt+1
	local o,d=pcall(call,con,sql,...)
	fincnt=fincnt+1
	if not o then
		errcnt=errcnt+1
		error(string.format("[%s]%s",tostring(d),sql))
	end
	if d.mulitresultset then
		return d,table.unpack(d)
	else
		return d,d
	end
end

local function error_check(sql,d)
	if d.errno then
		error(string.format("[(%s)%s]%s",d.errno,d.err,sql))
	end
end

function _M.query(sql)
	return ret(error_check,sql,inner_execute(mysql.query,sql))
end

function _M.safe_query(sql)
	return ret(nil,sql,inner_execute(mysql.query,sql))
end

function _M.stmt(sql,...)
	return ret(error_check,sql,inner_execute(mysql.stmt_query,sql,...))
end

function _M.start(o)
	opt=o
	con=mysql.connect(opt)
	last=skynet.now()
	skynet.fork(check_ping)
	return true
end

function _M.info()
	return allcnt,fincnt,errcnt
end

local function release()
	if con then
		while (allcnt-fincnt)>0 do
			skynet.sleep(10)
		end
		mysql.disconnect(con)
		con=nil
	end
end

service.init {
	command = _M,
	release=release,
}

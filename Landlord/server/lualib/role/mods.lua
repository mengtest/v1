local C=require 'mysql.cache'
local skynet=require 'skynet'
local MODS={}
local VEC={}
local util=require 'util'

local traceback=debug.traceback

local function call(f,...)
	for i,name in ipairs(VEC) do
		local mod = MODS[name]
		local call = mod[f]
		if call then
			call(...)
		end
	end
end

local function reg(name,mod)
	if not MODS[name] then
		table.insert(VEC, name)
	end

	MODS[name] = mod
end

local _M={}

function _M.load(self)
	local rid,db=self.rid,self.proxy
	C.init("t_mod_",rid,db)
	call('load',self)
end

function _M.unload(self)
	call('unload',self)
	C.unload(self.rid)
end

function _M.enter(self)
	call('enter',self)
end

function _M.leave(self)
	call('leave',self)
end

function _M.timeout(self, init)
	call('timeout',self, init)
end

function _M.reenter(self, init)
	call('reenter',self, init)
end

function _M.ondayrefresh(self)
	call("ondayrefresh", self);
end

function _M.load_offline(self,mods)
	local rid,db=self.rid,self.proxy
	C.init("t_mod_",rid,db)
	for _,v in ipairs(mods) do
		local mod = MODS[v]
		if mod and mod.load then
			mod.load(self, true)
		end
	end
end

function _M.unload_offline(self,mods)
	for _,v in ipairs(mods) do
		local mod = MODS[v]
		if mod and mod.unload then
			mod.unload(self, true)
		end
	end
	C.unload(self.rid)
end

setmetatable(_M,{__call=function(t,n,m)
	reg(n,m)
end})

return _M

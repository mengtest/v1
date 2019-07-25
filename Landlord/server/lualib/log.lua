local logger = require "print.c"
local util = require "util"
local log = {}

function log.format(fmt, ...)
	return string.format(fmt, ...)
end

local function get_module_info(level)
	local module_info = ""
	local info = debug.getinfo(level)
	if info ~= nil and info.short_src ~= nil and info.currentline ~= nil then
		module_info = string.format("%s:%d", info.short_src, info.currentline)
	end
	module_info = module_info.." -- "

	return module_info
end

function log.msg(self, ... )
	local msg = ""
	if select("#", ...) == 1 then
		msg = tostring((...))
	else
		msg = self.format(...)
	end
	msg = get_module_info(4)..msg
	return msg
end

function log.__call( self, ...)
	local msg = self.msg(self, ...)
	logger.print(0,msg)
end

function log.error( self, ... )
	local msg = self.msg(self, ...)
	logger.print(1,msg)
end

function log.warn( self, ... )
	local msg = self.msg(self, ...)
	logger.print(2,msg)
end

function log.debug( self, ... )
	local msg = self.msg(self, ...)
	logger.print(3,msg)
end

function log.info( self, ... )
	local msg = self.msg(self, ...)
	logger.print(4,msg)
end

function log.dump( self, ...)
	local msg = util.dump(...)
	logger.print(0,msg)
end

return setmetatable(log, log)

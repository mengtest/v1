local core = require "sproto.core"

local loader = {}

function loader.register(filename, index)
	local f = assert(io.open(filename), "Can't open sproto file")
	local data = f:read "a"
	f:close()
	local parser = require "sprotoparser"
	local sp = core.newproto(parser.parse(data))
	core.saveproto(sp, index)
end

function loader.save(bin, index)
	local sp = core.newproto(bin)
	core.saveproto(sp, index)
end

function loader.load(index)
	local sp = core.loadproto(index)
	--  no __gc in metatable
	local sproto = require "sproto"
	return sproto.sharenew(sp)
end

return loader


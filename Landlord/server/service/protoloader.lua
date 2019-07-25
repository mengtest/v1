local lfs = require("lfs")
local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local service = require "service"
local log = require "log"

local loader = {}
local data = {}
local index={}

local function load(name)
	local sub = ""
	local pos = string.find(name, '*')
	if pos then
		sub = string.sub(name,pos+1)
		name = "(.+)"..sub
	end
	local path = 'proto'
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local filename = path.. '/' ..file
			local attr = lfs.attributes(filename)
			if attr.mode == "directory" then
				-- 目录不做处理
			else
				local m=string.match(file,name)
				if m then
					m = m .. sub
					local f = assert(io.open(filename), "Can't open " .. file)
					local t = f:read "a"
					f:close()
					data[m] = t
					table.insert(index,m)
					log("load proto [%s]", m)
				end
			end
		end
	end
	table.sort( index, function(a,b)
		return string.byte( a, 1, 1) > string.byte( b, 1, 1)
	end )
end

function loader.load(list)
	for i, name in ipairs(list) do
		load(name)
	end
end

function loader.index(names, solt)
	local ret = ""
	if type(names) == "string" then
		local pos = string.find(names, '*')
		if pos then
			local sub = string.sub(names,pos+1)
			local tmp = "(.+)"..sub
			for _, name in ipairs(index) do
				local m=string.match(name,tmp)
				if m then
					ret = ret .."\n".. data[name]
				end
			end
		else
			ret = ret .. data[names]
		end
	else
		for _, name in ipairs(names) do
			ret = ret .. data[name]
		end
	end
	-- local f = io.open(solt,"w")
	-- f:write(ret)
	-- f:close()
	return sprotoparser.parse(ret,solt)
end

service.init {
	command = loader,
	info = data
}

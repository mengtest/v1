

local G_require=require

local mem={}
local loaded={}
local path={}
function require(f)
	table.insert(path,f)
	
	collectgarbage("collect")
	local before=collectgarbage("count")
	if not loaded[f] then
		loaded[f]=G_require(f)
	end
	collectgarbage("collect")
	local last=collectgarbage("count")
	print("require",before,last,last-before,table.concat(path,"|"))
	table.remove(path)
	return loaded[f]
end

local function init_all()
	local funcs = init_func
	init_func = nil
	if funcs then
		for _,f in ipairs(funcs) do
			collectgarbage("collect")
			local before=collectgarbage("count")
			f()
			collectgarbage("collect")
			local last=collectgarbage("count")
			local info=debug.getinfo(f)
			local src=info.short_src
			local line=info.linedefined
			print("skynet.init",before,last,last-before,string.format("\"%s\"--[[%s:%d]]",v,src,line))
		end
	end
end

local skynet=require "skynet"

local start=skynet.start
skynet.start=function(start_func)
	collectgarbage("collect")
	local before=collectgarbage("count")
	start(function()
		start_func()
		collectgarbage("collect")
		local last=collectgarbage("count")
		print("skynet.start",before,last,last-before)
	end)
end

local function getupvalue(func,name)
	for i=1,math.maxinteger do
		local nm,value=debug.getupvalue(func,i)
		if not nm then break end
		if nm==name then return value,i,name end
	end
	assert("not found upvalue "..name)
end

local init_template=getupvalue(skynet.pcall,"init_template")
local init_all,upidx,upname=getupvalue(init_template,"init_all")
local init_func=getupvalue(init_all,"init_func")

local function init_all()
	local funcs = init_func
	init_func = nil
	if funcs then
		for _,f in ipairs(funcs) do
			collectgarbage("collect")
			local before=collectgarbage("count")
			f()
			collectgarbage("collect")
			local last=collectgarbage("count")
			local info=debug.getinfo(f)
			local src=info.short_src
			local line=info.linedefined
			print("skynet.init",before,last,last-before,string.format("\"%s\"--[[%s:%d]]",v,src,line))
		end
	end
end
debug.setupvalue(init_template,upidx,init_all)
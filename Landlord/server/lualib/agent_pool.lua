
local skynet = require "skynet"
local queue = require "skynet.queue"


local insert = table.insert
local remove = table.remove


local _locker = queue()

local _pool_ctx  
local _handle_info

local _M = {}

function _M.init(cap,count,file)
	assert(_pool_ctx == nil)

	_pool_ctx = {pool = {},
				 cap = cap,		--服务数量
				 count = count,	--服务容纳数量
				 file = file, 	--服务启动文件
				 next = nil}	--下一个_pool_ctx的引用

	_handle_info = {}

	for i = 0,_pool_ctx.count do
		_pool_ctx.pool[i] = {}
	end
	
	for i = 1,_pool_ctx.cap do
		local handle = skynet.newservice(_pool_ctx.file)
		_pool_ctx.pool[0][handle] = 0
	end
end

local function try_pop()
	for i = 0,_pool_ctx.count - 1 do
		while true do
			local handle,_ = next(_pool_ctx.pool[i])
			if handle == nil then
				break
			end
			_pool_ctx.pool[i][handle] = nil
			_pool_ctx.pool[i+1][handle] = 0
			_handle_info[handle] = {pool = _pool_ctx,index = i + 1}
			return handle
		end
	end
	return
end

local function expand(cap)
	if _pool_ctx.cap == cap then
		return
	end
	
	local add = cap - _pool_ctx.cap
	for i = 1,add do
		local handle = skynet.newservice(_pool_ctx.file)
		_pool_ctx.pool[0][handle] = 0
	end
	_pool_ctx.cap = cap
end

--必须地加lock
function _M.pop()
	local handle = try_pop()
	if handle ~= nil then
		return handle
	end
	while handle == nil do
		_locker(expand,_pool_ctx.cap + 5)
		handle = try_pop()
	end
	return handle
end

function _M.push(handle)
	assert(handle ~= nil)

	local hi = _handle_info[handle]
	assert(hi ~= nil)

	local index = hi.index
	assert(index ~= 0,index)

	local pool_ctx = hi.pool
	assert(pool_ctx ~= nil)

	pool_ctx.pool[index][handle] = nil
	pool_ctx.pool[index - 1][handle] = 0
	if index - 1 == 0 then
		_handle_info[handle] = nil
	else
		_handle_info[handle] = {pool = pool_ctx,index = index - 1}
	end
end

--新启动agent池,后进入的玩家全都用新的,用来整个热更新的,以防上面的reload出问题
function _M.new()
	assert(_pool_ctx ~= nil)
	local new_pool = {pool = {},
				 	  cap = _pool_ctx.cap,
					  count = _pool_ctx.count,
				      file = _pool_ctx.file,
				 	  next = _pool_ctx}

	for i = 0,new_pool.count do
		new_pool.pool[i] = {}
	end
	
	for i = 1,new_pool.cap do
		local handle = skynet.newservice(new_pool.file)
		new_pool.pool[0][handle] = 0
	end
	_pool_ctx = new_pool
end

local function forearch_agent(func,...)
	local has_earch = {}
	local pool_ctx = _pool_ctx
	while pool_ctx ~= nil do
		for i = 0,pool_ctx.count do
			for handle,_ in pairs(pool_ctx.pool[i]) do
				if has_earch[handle] == nil then
					has_earch[handle] = 0
					func(handle,i,...)
				end
			end
		end
		pool_ctx = pool_ctx.next
	end
end

--在原来的agent热更单个文件
function _M.reload(file)
	forearch_agent(function (handle,cnt)
		skynet.call(handle,"lua","reload",file)
	end)
end

--agent广播
function _M.broadcast(name,...)
	forearch_agent(function (handle,cnt,...)
		skynet.send(handle,"lua",name,nil,...)
	end,...)
end

--agent停服
function _M.stop()
	forearch_agent(function (handle,cnt)
		skynet.call(handle,"lua","stop")
	end)
end

--返回agent的玩家数量
function _M.dump()
	local result = {}
	forearch_agent(function (handle,cnt)
		result[skynet.address(handle)] = cnt
	end)
	return result
end

--统计agent的消息时间消耗
function _M.report()
	local result = {}
	local list = {}
	forearch_agent(function (handle,cnt)
		local r = skynet.call(handle,"game","report") 
		table.insert(list,r)
	end)

	for _,info in pairs(list) do
		for cmd,detail in pairs(info) do
			local resultInfo = result[cmd]
			if resultInfo == nil then
				resultInfo = {count = 0,max = 0,total = 0}
				result[cmd] = resultInfo
			end
			resultInfo.count = resultInfo.count + detail.count
			resultInfo.total = resultInfo.total + detail.total
			if resultInfo.max == 0 or resultInfo.max < detail.max then
				resultInfo.max = detail.max
			end
		end
	end
	
	return result
end

--统计agent的消息流量
function _M.flow()
	local result = {}
	local list = {}
	forearch_agent(function (handle,cnt)
		local r = skynet.call(handle,"game","flow") 
		table.insert(list,r)
	end)

	for _,info in pairs(list) do
		for cmd,detail in pairs(info) do
			local flowInfo = result[cmd]
			if flowInfo == nil then
				flowInfo = {count = 0,flow = 0}
				result[cmd] = flowInfo
			end
			flowInfo.count = flowInfo.count + detail.count
			flowInfo.flow = flowInfo.flow + detail.flow
		end
	end
	
	return result
end

function _M.getpool()
	return _pool_ctx
end
return _M

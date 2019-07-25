local minheap=require "minheap.c"
local skynet=require "skynet"
local log=require "log"

local heap_add=minheap.add
local heap_top=minheap.top
local heap_pop=minheap.pop

local HEAP=minheap.new()
local cbtable={}
local idtab={}
local IDGEN=1
local handle={}
local MIN_TI=math.huge

local _M={}

local update
local function pollwith_skynet(now)
	local _,min=heap_top(HEAP)
	if min and min<MIN_TI then
		MIN_TI=min
		skynet.timeout(min-now,function()
			if MIN_TI==min then
				MIN_TI=math.huge
				update()
			end
		end)
	end
end

local function safe_call(id)
	local call=idtab[id]
	if call then
		idtab[id]=nil
		local ok,err=xpcall(call,debug.traceback)
		if not ok then log(err) end
	end
end

function update(min)
	local now=skynet.now()
	while true do
		local id=heap_pop(HEAP,now)
		if not id then break end
		safe_call(id)
	end
	pollwith_skynet(now)
end

function _M.add(ti,cb)
	local now=skynet.now()
	local expire=now+ti
	return _M.addexpire(expire,cb)
end

function _M.addexpire(expire,cb)
	local id=IDGEN
	IDGEN=IDGEN+1
	idtab[id]=cb
	heap_add(HEAP,id,expire)
	pollwith_skynet(skynet.now())
	return id
end

function _M.del(id)
	local cb=idtab[id]
	idtab[id]=nil
	return cb
end

function _M.addloop(ti,cb)
	local h = _M.add(ti, function()
		cb();
		_M.addloop(ti, cb);
	end);
	handle[cb] = h;
	return cb;
end

function _M.delloop(hd)
	local h = handle[hd];
	if not h then return end
	_M.del(h);
	handle[hd] = nil;
end

return _M

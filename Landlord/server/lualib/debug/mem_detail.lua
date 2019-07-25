local TYPEID={
	["nil"]=0,
	number=1,
	string=2,
	table=3,
	["function"]=4,
	thread=5,
	userdata=6,
	boolean=7,
}

local INFO={
	["function"]=function(v)
		local info=debug.getinfo(v)
		local src=info.short_src
		local line=info.linedefined
		return string.format("%s--[[%s:%d]]",v,src,line)
		--return string.format("%s%s--[[%s:%d]]",TYPEID["function"],v,src,line)
	end,
}

local function default_info(v)
	return tostring(v)
	--return TYPEID[type(v)]..tostring(v)
end

local function info(v)
	local call= INFO[type(v)] or default_info
	return call(v)
end

local PROXY={
	["table"]=function(v)
		local ret={}
		for k,v in next,v do
			ret[k]=v
		end
		ret["__metatable"]=getmetatable(v)
		return ret
	end,
	["function"]=function(v)
		local ret={}
		for i=1,math.maxinteger do
			local name,value=debug.getupvalue(v,i)
			if not name then break end
			ret[name]=value
		end
		return ret
	end,
	["userdata"]=function(v)
		local ret={}
		ret["__metatable"]=getmetatable(v)
		return ret
	end,
	["thread"]=function(v)
		local ret={}
		for i=0,math.maxinteger do
			local info=debug.getinfo(v,i,"flnStu")
			if not info then break end
			local key=string.format("%02d_00_00 %s %s(%s:%d)",i,info.what or "nil",info.name,info.short_src,info.currentline)
			ret[key]=info.func
			for j=1,math.maxinteger do
				local name,val=debug.getlocal(v,i,j)
				if not name then break end
				ret[string.format("%02d_%02d_____local %s",i,j,name)]=val
			end
		end
		return ret
	end,
}

local function tblinfo(tbl)
	local ret={}
	for k,v in pairs(tbl) do
		ret[info(k)]=info(v)
	end
	return ret
end

return function (root,...)
	local keys={}

	local function getsub(S,K,...)
		if K==nil then return tblinfo(S) end
		table.insert(keys,K)
		local s
		for k,v in pairs(S) do
			if info(k)==K then
				s=k
				break
			end
			if info(v)==K then
				s=v
				break
			end
		end
		local proxy=PROXY[type(s)]
		if proxy then
			return getsub(proxy(s),...)
		else
			return info(s)
		end
	end
	if not root then
		return keys,getsub{error="root is nil"}
	else
		return keys,getsub(root,...)
	end
end

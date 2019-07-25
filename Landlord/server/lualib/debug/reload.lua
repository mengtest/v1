
local function findloader(name)
	local msg = {}
	for _, loader in ipairs(package.searchers) do
		local f , extra = loader(name)
		local t = type(f)
		if t == "function" then
			return f, extra
		elseif t == "string" then
			table.insert(msg, f)
		end
	end
	error(string.format("module '%s' not found:%s", name, table.concat(msg)))
end

local function find_upvalue(func, name)
	if not func then
		return
	end
	local i = 1
	while true do
		local n,v = debug.getupvalue(func, i)
		if n == nil then
			return
		end
		if n == name then
			return i,v
		end
		i = i + 1
	end
end

local accept_key_type = {
	number = true,
	string = true,
	boolean = true,
	table=true,
}


local function enum_object(value)
	local all = {}
	local path = {}
	local objs = {}
	local skynet=package.loaded["skynet"]
	if skynet then
		objs[skynet]=true
	end
	local REG=debug.getregistry()
	if REG._ctable then
		objs[REG._ctable]=true
		objs[REG._ctables]=true
		objs[REG._proxy]=true

		local datasheet=package.loaded["skynet.datasheet"]
		objs[datasheet]=true
		local _,sheets=find_upvalue(datasheet.query, "sheets")
		for k,v in pairs(sheets) do objs[v]=true end
	end

	local function iterate(value)
		local t = type(value)
		if t == "function" or t == "table" then
			table.insert(all, { value, table.unpack(path) })
			if objs[value] then return end -- already unfold
			objs[value] = true
		else
			return
		end
		local depth = #path + 1
		if t == "function" then
			local info=debug.getinfo(value,"Sln")
			if info.what~="C" then
				local i = 1
				while true do
					local name, v = debug.getupvalue(value, i)
					if name == nil then
						break
					else
						if not name:find("^[_%w]") then
							error("Invalid upvalue : " .. table.concat(path, ".").."."..i)
						end
						local vt = type(v)
						if vt == "function" or vt == "table" then
							path[depth] = name
							path[depth + 1] = i
							iterate(v)
							path[depth] = nil
							path[depth + 1] = nil
						end
					end
					i = i + 1
				end
			end
		else
			for k,v in next,value do
				if not accept_key_type[type(k)] then
					--error("Invalid key : " .. tostring(k) .. " " .. table.concat(path, "."))
				else
					path[depth] = k
					iterate(v)
					path[depth] = nil
				end
			end
		end
	end
	iterate(value)
	return all
end

local function find_object(mod, name, id , ...)
	if mod == nil or name == nil then
		return mod
	end
	local t = type(mod)
	if t == "table" then
		return find_object(rawget(mod,name) , id , ...)
	else
		assert(t == "function")
		local i = 1
		while true do
			local n, value = debug.getupvalue(mod, i)
			if n == nil then
				return
			end
			if n == name then
				return find_object(value, ...)
			end
			i = i + 1
		end
	end
end

local function match_objects(objects, old_module, map,nochange)
	for _, item in ipairs(objects) do
		local obj = item[1]
		local ok, old_one = pcall(find_object,old_module, table.unpack(item, 2))
		if not ok then
			local current = { table.unpack(item, 2) }
			error ( "type mismatch : " .. table.concat(current, ",") )
		end
		if old_one == nil then
			map[obj] = map[obj] or false
		elseif type(old_one) ~= type(obj) then
			local current = { table.unpack(item, 2) }
			error ( "Not a table : " .. table.concat(current, ",") )
		end
		if map[obj] and map[obj] ~= old_one and obj~=old_one then
			local current = { table.unpack(item, 2) }
			error ( "Ambiguity table : " .. table.concat(current, ",") )
		end
		if obj~=old_one then
			map[obj] = old_one
			if print then print("MATCH", old_one, table.unpack(item,2)) end
		end
	end
end

local function find_upvalue(func, name)
	if not func then
		return
	end
	local i = 1
	while true do
		local n,v = debug.getupvalue(func, i)
		if n == nil then
			return
		end
		if n == name then
			return i,v
		end
		i = i + 1
	end
end

local function match_upvalues(map, upvalues)
	for new_one , old_one in pairs(map) do
		if type(new_one) == "function" then
			local i = 1
			while true do
				local name, value = debug.getupvalue(new_one, i)
				if name ==  nil then
					break
				end
				local old_index,old_value = find_upvalue(old_one, name)
				local id = debug.upvalueid(new_one, i)
				if not upvalues[id] and old_index then
					if value~=old_value then
						upvalues[id] = {
							func = old_one,
							index = old_index,
							oldid = debug.upvalueid(old_one, old_index),
							value=value,
							old_value=old_value,
						}
					end
				elseif old_index then
					local oldid = debug.upvalueid(old_one, old_index)
					if oldid ~= upvalues[id].oldid then
						error (string.format("Ambiguity upvalue : %s .%s",tostring(new_one),name))
					end
				end
				i = i + 1
			end
		end
	end
end

local function patch_funcs(upvalues, map)
	for value in pairs(map) do
		if type(value) == "function" then
			local i = 1
			while true do
				local name,_ = debug.getupvalue(value, i)
				if name == nil then
					break
				end
				local id = debug.upvalueid(value, i)
				local uv = upvalues[id]
				if uv then
					debug.upvaluejoin(value, i, uv.func, uv.index)
				end
				i = i + 1
			end
		end
	end
end

local function set_object(v, mod, name, tmore, fmore, ...)
	if mod == nil then
		return false
	end
	if type(mod) == "table" then
		if not tmore then	-- no more
			mod[name] = v
			return true
		end
		return set_object(v, mod[name], tmore, fmore, ...)
	else
		local i = 1
		while true do
			local n, value = debug.getupvalue(mod, i)
			if n == nil then
				return false
			end
			if n == name then
				if not fmore then
					debug.setupvalue(mod, i, v)
					return true
				end
				return set_object(v, value, fmore, ...)	-- skip tmore (id)
			end
			i = i + 1
		end
	end
end

local function merge_objects(mod_name,data)
	if data.old_module then
		local map = data.map
		patch_funcs(data.upvalues, map)
		for new_one, old_one in pairs(map) do
			if type(new_one) == "table" and old_one then
				-- merge new_one into old_one
				if print then print("COPY", old_one) end
				for k,v in pairs(new_one) do
					if type(v) ~= "table" or	-- copy values not a table
						old_one[k] == nil then	-- copy new object
						old_one[k] = v
					end
				end
			end
		end
		--local nochange=data.nochange
		--for _, item in ipairs(data.objects) do
		--	local v = item[1]
		--	if not map[v] and not nochange[v] then
		--		-- insert new object
		--		local ok = set_object(v, data.old_module, table.unpack(item,2))
		--		if print then print("MOVE", mod_name, table.concat(item,".",2),ok) end
		--	end
		--end
	else
		debug.getregistry()._LOADED[mod_name] = data.module.module
	end
end

local function update_funcs(map)
	local root = debug.getregistry()
	local co = coroutine.running()
	local exclude = { [map] = true , [co] = true }
	local getmetatable = debug.getmetatable
	local getinfo = debug.getinfo
	local getlocal = debug.getlocal
	local setlocal = debug.setlocal
	local getupvalue = debug.getupvalue
	local setupvalue = debug.setupvalue
	local getuservalue = debug.getuservalue
	local setuservalue = debug.setuservalue
	local type = type
	local next = next
	local rawset = rawset

	exclude[exclude] = true


	local update_funcs_

	local function update_funcs_frame(co,level)
		local info = getinfo(co, level+1, "f")
		if info == nil then
			return
		end
		local f = info.func
		info = nil
		update_funcs_(f)
		local i = 1
		while true do
			local name, v = getlocal(co, level+1, i)
			if name == nil then
				if i > 0 then
					i = -1
				else
					break
				end
			end
			local nv = map[v]
			if nv then
				setlocal(co, level+1, i, nv)
				update_funcs_(nv)
			else
				update_funcs_(v)
			end
			if i > 0 then
				i = i + 1
			else
				i = i - 1
			end
		end
		return update_funcs_frame(co, level+1)
	end

	function update_funcs_(root)	-- local function
		if exclude[root] then
			return
		end
		local t = type(root)
		if t == "table" then
			exclude[root] = true
			local mt = getmetatable(root)
			if mt then update_funcs_(mt) end
			local tmp
			for k,v in next, root do
				local nv = map[v]
				if nv then
					rawset(root,k,nv)
					update_funcs_(nv)
				else
					update_funcs_(v)
				end
				local nk = map[k]
				if nk then
					if tmp == nil then
						tmp = {}
					end
					tmp[k] = nk
				else
					update_funcs_(k)
				end
			end
			if tmp then
				for k,v in next, tmp do
					root[k], root[v] = nil, root[k]
					update_funcs_(v)
				end
				tmp = nil
			end
		elseif t == "userdata" then
			exclude[root] = true
			local mt = getmetatable(root)
			if mt then update_funcs_(mt) end
			local uv = getuservalue(root)
			if uv then
				local tmp = map[uv]
				if tmp then
					setuservalue(root, tmp)
					update_funcs_(tmp)
				else
					update_funcs_(uv)
				end
			end
		elseif t == "thread" then
			exclude[root] = true
			update_funcs_frame(root,2)
		elseif t == "function" then
			exclude[root] = true
			local i = 1
			while true do
				local name, v = getupvalue(root, i)
				if name == nil then
					break
				else
					local nv = map[v]
					if nv then
						setupvalue(root, i, nv)
						update_funcs_(nv)
					else
						update_funcs_(v)
					end
				end
				i=i+1
			end
		end
	end

	-- nil, number, boolean, string, thread, function, lightuserdata may have metatable
	for _,v in pairs { nil, 0, true, "", co, update_funcs, debug.upvalueid(update_funcs,1) } do
		local mt = getmetatable(v)
		if mt then update_funcs_(mt) end
	end

	update_funcs_frame(co, 2)
	update_funcs_(root)
end

return function(name)
	local loader, arg = findloader(name)
	local ret = loader(name, arg) or true
	local objs=enum_object(ret)
	local old_module = debug.getregistry()._LOADED[name]
	local result = {
		map = {},
		upvalues = {},
		old_module = old_module,
		module = ret ,
		objects = objs,
		nochange={},
	}
	match_objects(objs, old_module, result.map, result.nochange)
	match_upvalues(result.map, result.upvalues)
	merge_objects(name,result)
	local func_map = {}
	for k,v in pairs(result.map) do
		if type(k) == "function" then
			func_map[v] = k
		end
	end
	update_funcs(func_map)
	return true
end

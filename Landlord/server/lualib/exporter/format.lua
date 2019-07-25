local next=next
local pairs=pairs
local insert=table.insert
local format=string.format
local assert=assert

local function buildflag(node,flag)
	if flag then
		return "node=\""..node.."\","..flag
	else
		return "node=\""..node.."\""
	end
end

local function deal_content(ret,name,node,typestr,content)
	local _typestr,val,flag=content[1],content[2],content[3]
	assert(typestr==_typestr)
	if type(val)=="table" then
		for i,_content in ipairs(content) do
			if i~=1 then
				local _val,_flag=_content[1],_content[2]
				insert(ret,format("%s{%s} %s\n",name,buildflag(node,_flag),_val))
			end
		end
	else
		insert(ret,format("%s{%s} %s\n",name,buildflag(node,flag),val))
	end
end

return function(datas)
	local ret={}

	local node_info={}
	for node in pairs(datas) do
		local node_type,node_id=string.match(node,"(.+)_([%d]+)")
		local node_list=node_info[node_type]
		if not node_list then
			node_list={}
			node_info[node_type]=node_list
		end
		node_list[node]=node_id
	end
	for node_type,node_list in pairs(node_info) do
		insert(ret,format("# TYPE z_node_type gauge\n",node_type))
		for node,node_id in pairs(node_list) do
			insert(ret,format("z_node_%s{node=\"%s\"} %d\n",node_type,node,node_id))
		end
	end
	while true do
		local node,data=next(datas)
		if not node then break end
		datas[node]=nil
		for name,content in pairs(data) do
			local typestr=content[1]
			insert(ret,format("# TYPE %s %s\n",name,typestr))
			deal_content(ret,name,node,typestr,content)
			for _node,_data in pairs(datas) do
				local _content=_data[name]
				if _content then
					_data[name]=nil
					deal_content(ret,name,_node,typestr,_content)
				end
			end
		end
	end
	local idx=1
	return function()
		local s=ret[idx]
		idx=idx+1
		return s
	end
end

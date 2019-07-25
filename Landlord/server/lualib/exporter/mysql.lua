local skynet=require "skynet"

local dbmgr
skynet.init(function()
	dbmgr=skynet.uniqueservice("dbmgr")
end)

return function(D)
	local ret=skynet.call(dbmgr,"lua","stat")
	D.z_db_thread_total={"counter"}
	D.z_db_query_total={"counter"}
	D.z_db_finish_total={"counter"}
	D.z_db_error_total={"counter"}
	for db,info in pairs(ret) do
		local flag="db=\""..db.."\""
		table.insert(D.z_db_thread_total,{info[1],flag})
		table.insert(D.z_db_query_total,{info[2],flag})
		table.insert(D.z_db_finish_total,{info[3],flag})
		table.insert(D.z_db_error_total,{info[4],flag})
	end
end

local io=require "io"
require 'util'
local log = require "log"
local con 

local can_drop_table=true
local can_drop_proc=true
local can_drop_func=true
local can_drop_field=true

local ignore = {}

local field_attrs={"field","type","collation","null","key","default","extra","comment","the_index"}
local index_field_attrs={"table", "non_unique", "key_name","seq_in_index","column_name","collation","sub_part","packed","null","index_type","the_index","comment"}

local function is_ignore(tname)
	for k,v in pairs(ignore) do
		local s = string.find(tname,v)
		if s then
			return true
		end
	end
	return false
end

local function encode_column(lines, attrs)
	local linetbl={}
	for _, key in ipairs(attrs) do
		local v = lines[key]
		if v then
			table.insert(linetbl,string.format("%s='%s'", key, v))
		end
	end
	return table.concat(linetbl,'\t')
end

local function decode_column(linestr)
	local ret={}
	for k,v in string.gmatch(linestr,"(%S+)='(.-)'") do
		ret[k]=v
	end
	return ret
end

local function encode_table_column(ret, attrs)
	local strtbl={}
	local last
	for i,v in ipairs(ret) do
		table.insert(strtbl,encode_column(v, attrs))
	end
	return table.concat(strtbl,"\n")
end

local function decode_table_column(tbls)
	local ret={}
	for k,v in pairs(tbls) do
		local r=decode_column(v)
		table.insert(ret,r)
	end
	return ret
end

local function decode_table_index(tbls)
	local ret={}
	for k,v in pairs(tbls) do
		local r=decode_column(v)
		local old = ret[r.key_name]
		if old then
			old.column_name = old.column_name..','..r.column_name
		else
			ret[r.key_name] = r
		end
	end
	return ret
end

local function WriteFile(name,str)
	local file=assert(io.open(name,"w"))
	file:write(str)
	file:close()
end

local function ReadFile(name)
	local file=assert(io.open(name,"r"))
	local str=file:read("*a")
	file:close()
	return str
end

local function ReadFileLines(name)
	local file=assert(io.open(name,"r"))
	local ret={}
	while file and true do
		local line=file:read("*l")
		if not line then break end
		table.insert(ret,line)
	end
	file:close()
	return ret
end

local function Showtables(db)
	local ret={}
	local sqlret=assert(con:query("show tables;"))
	for k,v in ipairs(sqlret) do
		for key,value in pairs(v) do
			if not is_ignore(value) then
				table.insert(ret,value)
			end
		end
	end
	return ret
end

local function ShowDatabase(db)
	local sqlret=assert(con:query("select database()"))
	return sqlret[1]["database()"]
end

local function ShowProcedures(db)
	local dbname=ShowDatabase(db)
	local sqlret=assert(con:query(string.format("select name,type from mysql.proc where db='%s'",dbname)))
	local ret,func={},{}
	for k,v in pairs(sqlret) do
		local name,type=v.name,v.type
		if type=='PROCEDURE' then
			table.insert(ret,name);
		else
			table.insert(func,name)
		end
	end
	return ret,func
end

local function ShowColumn(db,tbl)
	local ret={}
	local sqlret=assert(con:query(string.format("show full columns from %s",tbl)))
	for k,v in ipairs(sqlret) do
		local c={}
		for _k,v in pairs(v) do
			c[string.lower(_k)]=v
		end
		c.the_index=tostring(k)
		for _, key in ipairs(field_attrs) do
			if c[key] == nil then c[key] = "__NULL__" end
		end
		table.insert(ret,c)
	end
	return ret
end

local function ShowIndexCombin(db,tbl)
	local ret={}
	local sqlret=assert(con:query(string.format("show index from %s",tbl)))
	for k,v in ipairs(sqlret) do
		local c={}
		for _k,v in pairs(v) do
			c[string.lower(_k)]=v
		end
		local old = ret[c.key_name]
		if old then
			old.column_name = old.column_name..','..c.column_name
		else
			ret[c.key_name] = c
		end
	end
	return ret
end

local function ShowIndex(db,tbl)
	local ret={}
	local sqlret=assert(con:query(string.format("show index from %s",tbl)))
	for k,v in ipairs(sqlret) do
		local c={}
		for _k,v in pairs(v) do
			c[string.lower(_k)]=v
		end
		table.insert(ret,c)
	end
	return ret
end

local function ShowCreateTable(db,tbl)
	local sqlret=assert(con:query(string.format("show create table %s",tbl)))
	local str=sqlret[1]["Create Table"]
	str=string.gsub(str," AUTO_INCREMENT=%d*" , "")
	str=string.gsub(str," USING BTREE","USING HASH")
	str=string.gsub(str," ROW_FORMAT=DYNAMIC","")
	str=string.gsub(str," ROW_FORMAT=FIXED","")
	str=string.gsub(str," ROW_FORMAT=COMPACT","")
	str=string.gsub(str,"ENGINE=%w*","ENGINE=InnoDB")
	return str
end

local function ShowCreateProcedure(db,proc)
	local sqlret=assert(con:query(string.format("show create procedure %s",proc)))
	local str=sqlret[1]["Create Procedure"]
	str=string.gsub(str, "CREATE(.*)PROCEDURE", "CREATE PROCEDURE")
	--str=string.format("DROP PROCEDURE IF EXISTS `%s`;\nDELIMITER $$\n%s\n$$\nDELIMITER ;",proc,str)
	return str
end

local function ShowCreateFunction(db,proc)
	local sqlret=assert(con:query(string.format("show create function %s",proc)))
	local str=sqlret[1]["Create Function"]
	str=string.gsub(str, "CREATE(.*)FUNCTION", "CREATE FUNCTION")
	--str=string.format("DROP PROCEDURE IF EXISTS `%s`;\nDELIMITER $$\n%s\n$$\nDELIMITER ;",proc,str)
	return str
end

local function DumpDbTable(db)
	local ret=Showtables(db)
	local all={}
	for _,tbl in ipairs(ret) do
		local info=ShowColumn(db,tbl)
		local str=encode_table_column(info, field_attrs)
		WriteFile("dump/"..db..".table."..tbl,str)
		WriteFile("dump/create/"..db..".table."..tbl,ShowCreateTable(db,tbl))
		log(string.format('DumpDbTable %s',tbl))
		table.insert(all,tbl)
	end
	WriteFile("dump/"..db..".table.list",table.concat(all,'\n'))
end

local function DumpDbProc(db)
	local ret,func=ShowProcedures(db)
	local all,allfunc={},{}
	for _,k in ipairs(ret) do
		local str=ShowCreateProcedure(db,k)
		WriteFile("dump/"..db..".proc."..k,str)
		log(string.format('DumpDbTable proc %s',k))
		table.insert(all,k)
	end
	for _,k in ipairs(func) do
		local str=ShowCreateFunction(db,k)
		WriteFile("dump/"..db..".func."..k,str)
		log(string.format('DumpDbProc func %s',k))
		table.insert(allfunc,k)
	end

	WriteFile("dump/"..db..".proc.list",table.concat(all,'\n'))
	WriteFile("dump/"..db..".func.list",table.concat(allfunc,'\n'))
end

local function DumpDbIndex(db)
	local ret=Showtables(db)
	local all={}
	for _,tbl in ipairs(ret) do
		local info=ShowIndex(db,tbl)
		local str=encode_table_column(info, index_field_attrs)
		WriteFile("dump/"..db..".index."..tbl,str)
		log(string.format('DumpDbTable %s',tbl))
		table.insert(all,tbl)
	end
end
local function ReadDbProc(db)
	local ret,func=ShowProcedures(db)
	local all,allfunc={},{}
	for _,k in ipairs(ret) do
		all[k]=ShowCreateProcedure(db,k)
	end
	for _,k in ipairs(func) do
		allfunc[k]=ShowCreateFunction(db,k)
	end
	return all,allfunc
end

local function LoadDbProc(db)
	local ret=ReadFileLines("dump/"..db..".proc.list")
	local retfunc=ReadFileLines("dump/"..db..".func.list")
	local all,allfunc={},{}
	for i,p in pairs(ret) do
		log(p)
		local sql=ReadFile("dump/"..db..".proc."..p)
		all[p]=sql
	end
	for i,p in pairs(retfunc) do
		local sql=ReadFile("dump/"..db..".func."..p)
		allfunc[p]=sql
	end
	return all,allfunc
end

local function LoadDbData(db)
	local ret=ReadFileLines("dump/"..db..".data.list")
	local all={}
	for i,p in pairs(ret) do
		table.insert(all,'delete from '..p)
		table.insert(all,ReadFile("dump/"..db..".data."..p))
	end
	return all
end

local function ReadDbTable(db)
	local ret=Showtables(db)
	local all={}
	for _,tbl in ipairs(ret) do
		all[tbl]=ShowColumn(db,tbl)
	end
	return all
end

local function LoadDbTable(db)
	local ret=ReadFileLines("dump/"..db..".table.list")
	local rettbl={}
	for i,tbl in pairs(ret) do
		local tblstrs=ReadFileLines("dump/"..db..".table."..tbl)
		rettbl[tbl]=decode_table_column(tblstrs)
	end
	return rettbl
end

local function ReadDbIndex(db)
	local ret=Showtables(db)
	local all={}
	for _,tbl in ipairs(ret) do
		local r = ShowIndexCombin(db,tbl)
		all[tbl]=r
	end
	return all
end

local function LoadDbIndex(db)
	local ret=ReadFileLines("dump/"..db..".table.list")
	local rettbl={}
	for i,tbl in pairs(ret) do
		local tblstrs=ReadFileLines("dump/"..db..".index."..tbl)
		rettbl[tbl]=decode_table_index(tblstrs)
	end
	return rettbl
end

local function getfield(set,name)
	for k,v in pairs(set) do
		if v.field==name then
			return v
		end
	end
end

local function addfield(set,tbl,v)
	local null=""
	local default=""
	if v.null=="NO" then
		null="NOT NULL"
	end
	if v.default=="__NULL__" then
		if v.null~="NO" then
			default="DEFAULT NULL"
		end
	else
		default=string.format("DEFAULT '%s'",v.default)
	end
	local collate=""
	if v.collation~="" and v.collation~="__NULL__" then
		collate=string.format("COLLATE '%s'",v.collation)
	end
	local cmt=""
	if v.comment~="" then
		cmt=string.format("COMMENT '%s'",v.comment)
	end
	local pos='FIRST'
	if tonumber(v.the_index)>1 then
		pos=string.format("AFTER `%s`",set[v.the_index-1].field)
	end
	return string.format("alter table `%s` add column `%s` %s %s %s %s %s %s %s",tbl,v.field,string.lower(v.type),null,default,cmt,collate,string.lower(v.extra or ''),pos)
end

local function delfield(tbl,v)
	return string.format("alter table `%s` drop column `%s`",tbl,v.field)
end

local function chgfield(set,tbl,v)
	local null=""
	local default=""
	if v.null=="NO" then
		null="NOT NULL"
	end
	if v.default=="__NULL__" then
		if v.null~="NO" then
			default="DEFAULT NULL"
		end
	else
		default=string.format("DEFAULT '%s'",v.default)
	end
	local collate=""
	if v.collation~="" and v.collation~="__NULL__" then
		collate=string.format("COLLATE '%s'",v.collation)
	end
	local cmt=""
	if v.comment~="" then
		cmt=string.format("COMMENT '%s'",v.comment)
	end
	local pos='FIRST'
	if tonumber(v.the_index)>1 then
		pos=string.format("AFTER `%s`",set[v.the_index-1].field)
	end
	return string.format("alter table `%s` change column `%s` `%s` %s %s %s %s %s %s %s",tbl,v.field,v.field,string.lower(v.type),null,default or '',cmt,collate,string.lower(v.extra or ''),pos)
end

local function compare_field(l,r)
	if r==l then return true end
	assert(l.field==r.field)
	for k,v in pairs(l) do
		local key=string.lower(k)
		if key~='key' then
			if string.lower(r[k])~=string.lower(v) then
				return false
			end
		end
	end
	return true
end

local function compare_field_index(l,r)
	if r==l then return true end
	assert(l.field==r.field)
	for k,v in pairs(l) do
		local key=string.lower(k)
		if key~='cardinality' then
			if string.lower(r[k])~=string.lower(v) then
				return false
			end
		end
	end
	return true
end

local function re_the_index(set)
	for k,v in ipairs(set) do
		v.the_index=tostring(k)
	end
end

local function CompareTable(name,left,right)
	local add,del,chg,br={},{},{},true
	while true do
		br=true
		for k,v in ipairs(right) do
			local lv=getfield(left,v.field)
			if not lv then
				table.insert(del,delfield(name,v))
				table.remove(right,k)
				br=false
				break
			end
		end
		re_the_index(right)
		if br then break end
	end
	while true do
		br=true
		for k,v in ipairs(left) do
			local rv=getfield(right,v.field)
			if not rv then
				table.insert(add,addfield(left,name,v))
				table.insert(right,k,v)
				br=false
				break
			else
				if not compare_field(v,rv) then
					table.insert(chg,chgfield(left,name,v))
					table.remove(right,rv.the_index)
					table.insert(right,k,v)
					br=false
					break
				end
			end
		end
		re_the_index(right)
		if br then break end
	end
	return add,del,chg
end

local dorp_proc="DROP PROCEDURE IF EXISTS `%s`"
local dorp_func="DROP FUNCTION IF EXISTS `%s`"
local function CompareDBProc(db,ret)
	local new,newfunc=LoadDbProc(db)
	local old,oldfunc=ReadDbProc(db)
	for k,v in pairs(new) do
		if v~=old[k] then
			table.insert(ret,string.format(dorp_proc,k))
			table.insert(ret,v)
		end
	end
	for k,v in pairs(old) do
		if not new[k] and can_drop_proc then
			table.insert(ret,string.format(dorp_proc,k))
		end
	end
	for k,v in pairs(newfunc) do
		if v~=oldfunc[k] then
			table.insert(ret,string.format(dorp_func,k))
			table.insert(ret,v)
		end
	end
	for k,v in pairs(oldfunc) do
		if not newfunc[k] and can_drop_func then
			table.insert(ret,string.format(dorp_func,k))
		end
	end
end

local function LoadCreateTable(db,name)
	local sql=ReadFile("dump/create/"..db..".table."..name)
	return sql
end

local drop_table="DROP TABLE IF EXISTS `%s`"
local function CompareDBTable(db,ret)
	local new=LoadDbTable(db)
	local old=ReadDbTable(db)
	for k,v in pairs(new) do
		if old[k] then
			local add,del,chg=CompareTable(k,v,old[k])
			for k,v in pairs(add) do table.insert(ret,v) end
			for k,v in pairs(chg) do table.insert(ret,v) end
			if can_drop_field then for k,v in pairs(del) do table.insert(ret,v)	end end
		else
			local v=LoadCreateTable(db,k)
			table.insert(ret,v)
		end
	end
	for k,v in pairs(old) do
		if not new[k] and can_drop_table then
			table.insert(ret,string.format(drop_table,k))
		end
	end
end

local non_unique_type = {['0']='unique index', ['1']='index',['2'] = 'fulltext'}
local function getIndexStr(v)
	local indexStr, newIndexStr
	if v.key_name == 'PRIMARY' then
		indexStr = 'PRIMARY key'
		newIndexStr = 'PRIMARY key'
	else
		indexStr = 'index '..v.key_name
		newIndexStr = assert(non_unique_type[tostring(v.non_unique)])..' '..v.key_name
	end
	return indexStr, newIndexStr
end

local function CompareDBIndex(db,ret)
	local new=LoadDbIndex(db)
	local old=ReadDbIndex(db)
	for tableName, n in pairs(new) do
		local o = old[tableName]
		for key, v in pairs(n) do
			if o and o[key] then
				if not compare_field_index(v,o[key]) then
					local indexStr, newIndexStr = getIndexStr(v)
					table.insert(ret,string.format("alter table %s drop %s, add %s using %s (%s);",
					tableName, indexStr, newIndexStr, v.index_type, v.column_name))
				end
				o[key] = nil
			else
				local indexStr, newIndexStr = getIndexStr(v)
				table.insert(ret,string.format("alter table %s add %s using %s (%s);",
				tableName, newIndexStr, v.index_type,v.column_name))
			end
		end
		for key, v in pairs(o or {}) do
			local indexStr, newIndexStr = getIndexStr(v)
			table.insert(ret,string.format("alter table %s drop %s;",
			tableName, indexStr))
		end
	end
end

local function check_flag(list)
	for _,db in pairs(list) do
		con:query("create table if not exists t_mysqlauto (name varchar(50) not null default '' comment '',primary key (name)) engine=innodb default charset=utf8")
		con:query('delete from t_mysqlauto')
	end
	for _,db in pairs(list) do
		con:query(string.format("insert t_mysqlauto(name)values('%s')",db))
	end
	local ret={}
	for _,db in pairs(list) do
		ret[db]={}
		local data=con:query('select name from t_mysqlauto')
		for _,v in pairs(data) do
			table.insert(ret[db],v.name)
		end
	end
	return ret
end

local function create_helper(db)
	return {
		dump=function()
			log(string.format("%s dump start--------------------------", db))
		    DumpDbTable(db)
		    DumpDbProc(db)
			DumpDbIndex(db)
			log(string.format("%s dump end--------------------------", db))
		end,
		cmp=function()
			log(string.format("%s cmp start--------------------------", db))
		    local ret={}
		    CompareDBTable(db,ret)
		    CompareDBProc(db,ret)
		    for k,v in pairs(ret) do
				log(v)
		    end
			log(string.format("%s cmp end--------------------------", db))
		end,
		fix=function()
			log(string.format("%s fix start--------------------------", db))
		    local ret={}
		    CompareDBTable(db,ret)
			CompareDBProc(db,ret)
			for k,v in pairs(ret) do
				log(v)
				assert(con:query(v))
			end

			ret = {}
			CompareDBIndex(db,ret)
			for k,v in pairs(ret) do
				log(v)
				assert(con:query(v))
			end

			--local data=LoadDbData(db)
		    --for k,v in ipairs(data) do
		        --print('load data '..v,LOG_MAIN)
				--assert(con:query(v))
		    --end
			log(string.format("%s fix end--------------------------", db))
		end
	}
end

local function createopt_and_check(list)
	local check=check_flag(list)
	local opt={}
	for _,db in pairs(list) do
		opt[db]=create_helper(db)
	end
	return opt,check
end

local _M = {}
function _M.ignore( t )
	table.insert(ignore,t)
end
function _M.dump(con1, list)
	con = con1
	local opt,check=createopt_and_check(list)
	for db,call in pairs(opt) do
		assert(#check[db]==1,string.format('dump database [%s] must live alone but [%s]',db,table.concat(check[db],',')))
		call.dump()
	end
end

function _M.fix(con1, list)
	con = con1
	local opt,check=createopt_and_check(list)
	for db,call in pairs(opt) do
		can_drop_table=true
		can_drop_field=true
		if io.open('ScriptDB/FORBIDDEN_DROP_TABLE') then
			can_drop_table=false 
			can_drop_field=false
		end
		can_drop_func=true
		can_drop_proc=true
		if #check[db]>1 then
			log(string.format("[%s] no drop (table,func,proc) for [%s]",db,table.concat(check[db],',')))
			can_drop_table=false
			can_drop_func=false
			can_drop_proc=false
		end
		call.fix()
	end
end
return _M

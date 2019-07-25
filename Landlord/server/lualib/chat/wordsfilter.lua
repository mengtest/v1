local wordsfilter=require "wordsfilter"


local PATH_CFG,PATH_ADD,PATH_DEL=1,2,3
local CFG={
    chat={"cfg/chatfilter.csv"},
	role={"cfg/namefilter.csv"}
}
CFG.def=CFG.chat
CFG.role=CFG.role

local IDX_FILTER,IDX_PATH,IDX_ADD,IDX_DEL,IDX_CACHE_CHECK,IDX_CACHE_GRUB=1,2,3,4,5,6,7

local function newFilter(path)
    local filter=wordsfilter:new()
    for w in io.lines(path[1]) do
        w=string.gsub(w,'\n','')
        w=string.gsub(w,'\r','')
        if not filter:get(w) then filter:add(w) end
    end
    local add,del={},{}
--    local f=io.open(path[2],'r')
--    if f then
--        for w in io.lines(path[2]) do
--            w=string.gsub(w,'\n','')
--            w=string.gsub(w,'\r','')
--            if not filter:get(w) then
--                assert(filter:add(w))
--                add[w]=true
--            end
--        end
--    end
--    local f=io.open(path[3],'r')
--    if f then
--        for w in io.lines(path[2]) do
--            w=string.gsub(w,'\n','')
--            w=string.gsub(w,'\r','')
--            if not filter:get(w) then
--                assert(filter:del(w))
--            end
--            add[w]=nil
--            del[w]=true
--        end
--    end
--
    return filter,add,del
end

local _M={}
local FILTERS={}
function _M.loadFilter(cfg)
	cfg=cfg or CFG
    local files={}
    for name,p in pairs(cfg) do
        if not files[p] then
            local filter,add,del=newFilter(p)
            files[p]={filter,p,add,del,setmetatable({},{__mode='kv'}),setmetatable({},{__mode='kv'})}
        end
        FILTERS[name]=files[p]
    end
end

--local FILTERS=loadFilter(CFG)

local function saveTable(p,t)
    local d={}
    for w in pairs(t) do table.insert(d,w) end
    local f=assert(io.open(p,'w'))
    f:write(table.concat(d,'\n'))
    f:close()
end

local function appendWord(nm,w)
    local filter=FILTERS[nm]
    if not filter then return nil,"DO_NOT_DEFINE_THE_FILTER" end
    local filter,path,adds,dels=filter[IDX_FILTER],filter[IDX_PATH],filter[IDX_ADD],filter[IDX_DEL]
    if filter:get(w) then return true end
    local ok,msg=filter:add(w)
    if not ok then return ok,msg end
    if dels[w] then
        dels[w]=nil
        saveTable(path[PATH_DEL],dels)
    else
        adds[w]=true
        saveTable(path[PATH_ADD],adds)
    end
    return true
end

local function delWord(nm,w)
    local filter=FILTERS[nm]
    if not filter then return nil,"DO_NOT_DEFINE_THE_FILTER" end
    local filter,path,adds,dels=filter[IDX_FILTER],filter[IDX_PATH],filter[IDX_ADD],filter[IDX_DEL]
    filter:del(w)
    if adds[w] then
        adds[w]=nil
        saveTable(path[PATH_ADD],adds)
    else
        dels[w]=true
        saveTable(path[PATH_DEL],dels)
    end
    return true
end


local function checkWord(nm,w)
    local filter=FILTERS[nm]
    if not filter then return nil,"DO_NOT_DEFINE_THE_FILTER" end
    local filter,cache=filter[IDX_FILTER],filter[IDX_CACHE_CHECK]
    local ret=cache[w]
    if ret~=nil then return ret end
    local ret,msg=filter:check(w)
    assert(not msg)
    cache[w]=ret
    return ret
end

local function grubWord(nm,w)
    local filter=FILTERS[nm]
    if not filter then return nil,"DO_NOT_DEFINE_THE_FILTER" end
    local filter,cache=filter[IDX_FILTER],filter[IDX_CACHE_GRUB]
    local ret=cache[w]
    if ret~=nil then return ret end
    local ret,msg=filter:grub(w)
    --print("grubWord",w,ret,msg)
    assert(ret)
    cache[w]=ret
    return ret
end

local function listWord(nm)
    local filter=FILTERS[nm]
    if not filter then return nil,"DO_NOT_DEFINE_THE_FILTER" end
    local filter=filter[IDX_FILTER]
    return filter:list()
end

local function filters()
    for k,v in pairs(FILTERS) do
        print(k,unpack(v))
    end
end

function _M.WordsFilter_CheckWords(str)
    return checkWord('def',str)
end

function _M.WordsFilter_CheckName(str)
	if(checkWord('role',str) and checkWord('def',str))then
		return true
	end
end

function _M.WordsFilter_GrubWords(str)
    return grubWord('chat',str)
end

function _M.AppendWordsFilter(str,nm)
    return appendWord(nm or 'def',str)
end

function _M.RemoveWordsFilter(str,nm)
    return delWord(nm or 'def',str)
end

function _M.GrubWordsFilter(str,nm)
    return grubWord(nm or 'def',str)
end

function _M.CheckWordsFilter(str,nm)
    return checkWord(nm or 'def',str)
end

function _M.ListWordsFilter(nm)
    return listWord(nm or 'def')
end
return _M


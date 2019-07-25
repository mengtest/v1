local core=require "memhelp.c"
local ext=require "ext.c"
local PID=core.pid()

local _M=setmetatable({},{__index=core})
function _M.jemalloc(R)
	local allocated,active,mapped,metadata,used_memory,memory_block=core.jemalloc()
	R.allocated=allocated		--
	R.active=active		--
	R.mapped=mapped		--
	R.metadata=metadata		--
	R.memory=used_memory		--
	R.block=memory_block		--
end

local cache={}
local function filecache(name)
	local file=cache[name]
	if file then
		file:seek("set",0)
	else
		file=assert(io.open(name))
		cache[name]=file
	end
	return file
end

function _M.system_proc_statm(R)
	local file=filecache(string.format("/proc/%d/statm",PID))
	local str=file:read("*a")
	local size,resident,share,trs,lrs,drs,dt=
		str:match("(%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+)")

	R.size=tonumber(size)				--vmsize/4
	R.resident=tonumber(resident)		--vmrss/4
	R.share=tonumber(share)			--shared pages
	R.trs=tonumber(trs)					--vmexe/4	text(code)
	R.drs=tonumber(drs)				--(vmdata+vmstk)/4
end

function _M.system_stat(R)
	local file=filecache("/proc/stat")
	local line=file:read("*l")
	local utime,ntime,stime,itime,iowtime,irqtime,sirqtime=
		line:match("cpu  (%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+)")

	utime=tonumber(utime)		--user
	ntime=tonumber(ntime)		--nice
	stime=tonumber(stime)		--system
	itime=tonumber(itime)			--idle
	iowtime=tonumber(iowtime)		--iowait
	irqtime=tonumber(irqtime)		--irq
	sirqtime=tonumber(sirqtime)		--softirq

	R.alltime_cpu=utime+ntime+stime+itime+iowtime+irqtime+sirqtime
	while true do
		line=file:read("*l")
		if not line then break end
		local cpuid
		cpuid,utime,ntime,stime,itime,iowtime,irqtime,sirqtime=
			line:match("cpu(%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+)")
		cpuid=tonumber(cpuid)
		if not cpuid then break end
		utime=tonumber(utime)		--user
		ntime=tonumber(ntime)		--nice
		stime=tonumber(stime)		--system
		itime=tonumber(itime)			--idle
		iowtime=tonumber(iowtime)	--iowait
		irqtime=tonumber(irqtime)		--irq
		sirqtime=tonumber(sirqtime)	--softirq
		R["alltime_"..cpuid]=utime+ntime+stime+itime+iowtime+irqtime+sirqtime
	end
end

function _M.system_proc_stat(R)
	local file=filecache(string.format("/proc/%d/stat",PID))
	local content=file:read("*a")
	local info=ext.split_string(content," ")

	local utime=tonumber(info[14])
	local stime=tonumber(info[15])
	local cutime=tonumber(info[16])
	local cstime=tonumber(info[17])
	local starttime=tonumber(info[22])
	local vsize=tonumber(info[23])
	local rss=tonumber(info[24])

	R.alltime_proc=utime+stime+cutime+cstime
	R.vsize=vsize
	R.rss=rss
end

function _M.system_thread_stat(R)
	local lfs=require "lfs"
	for name in lfs.dir(string.format("/proc/%d/task/",PID)) do
		if name~="." and name~=".." then
			local file=filecache(string.format("/proc/%d/task/%s/stat",PID,name))
			local content=file:read("*a")
			local info=ext.split_string(content," ")

			local utime=tonumber(info[14])
			local stime=tonumber(info[15])
			local cutime=tonumber(info[16])
			local cstime=tonumber(info[17])
			R["thr"..name]=utime+stime
		end
	end
end

function _M.proc_netdev_stat(R)
	local file=filecache(string.format("/proc/%d/net/dev",PID))
	file:read("*l")
	file:read("*l")
	local netdev={}
	while true do
		local line=file:read("*l")
		if not line then break end

		local rface,content=ext.splitrow_string(line,":")
		rface=rface:match("^%s*(.-)%s*$")
		local rbytes,rpackets,rerrs,rdrop,rfifo,rframe,rcompressed,rmulticast
		,tbytes,tpackets,terrs,tdrop,tfifo,tcolls,tcarrier,tcompressed=ext.splitrow_string(content," ",1)

		netdev[rface]={
			rbytes=tonumber(rbytes),
			rpackets=tonumber(rpackets),
			rerrs=tonumber(rerrs),
			rdrop=tonumber(rdrop),
			tbytes=tonumber(tbytes),
			tpackets=tonumber(tpackets),
			terrs=tonumber(terrs),
			tdrop=tonumber(tdrop),
		}
	end
	R.netdev=netdev
end

return _M

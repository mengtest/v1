local skynet=require "skynet"
local memhelp=require "debug.memhelp"
local PAGESIZE=memhelp.pagesize()
local PROCESSORS=memhelp.processors()

local cpu_all_start
local cpu_proc_start

return function(D)
	local R={}
	memhelp.jemalloc(R)
	memhelp.system_stat(R)
	memhelp.system_proc_statm(R)
	memhelp.system_proc_stat(R)
	--memhelp.system_thread_stat(R)
	memhelp.proc_netdev_stat(R)

	if not cpu_all_start then cpu_all_start=R.alltime_cpu end
	if not cpu_proc_start then cpu_proc_start=R.alltime_proc end
	local cpu_all=math.max(1,R.alltime_cpu-cpu_all_start)
	local cpu_proc=R.alltime_proc-cpu_proc_start
	D.z_up={"gauge",1}
	D.z_uptime={"counter",skynet.now()}
	D.z_cpunum_total={"counter",PROCESSORS}
	D.z_cpu_total={"counter",cpu_proc}
	D.z_cpuall_total={"counter",cpu_all}
	D.z_skynetcmem_bytes={"gauge",R.memory}
	D.z_skynetcblock_bytes={"gauge",R.block}
	D.z_jeallocated_bytes={"gauge",R.allocated}
	D.z_jeactive_bytes={"gauge",R.active}
	D.z_jemapped_bytes={"gauge",R.mapped}
	D.z_jemetadata_bytes={"gauge",R.metadata}
	D.z_memsize_bytes={"gauge",R.size*PAGESIZE}
	D.z_memresident_bytes={"gauge",R.resident*PAGESIZE}
	D.z_memshare_bytes={"gauge",R.share*PAGESIZE}
	D.z_memtrs_bytes={"gauge",R.trs*PAGESIZE}
	D.z_memdrs_bytes={"gauge",R.drs*PAGESIZE}
	D.z_net_rbytes={"counter"}
	D.z_net_rpackets={"counter"}
	D.z_net_rerrs={"counter"}
	D.z_net_rdrop={"counter"}
	D.z_net_tbytes={"counter"}
	D.z_net_tpackets={"counter"}
	D.z_net_terrs={"counter"}
	D.z_net_tdrop={"counter"}
	for face,dev in pairs(R.netdev) do
		local flag="face=\""..face.."\""
		table.insert(D.z_net_rbytes,{dev.rbytes,flag})
		table.insert(D.z_net_rpackets,{dev.rpackets,flag})
		table.insert(D.z_net_rerrs,{dev.rerrs,flag})
		table.insert(D.z_net_rdrop,{dev.rdrop,flag})
		table.insert(D.z_net_tbytes,{dev.tbytes,flag})
		table.insert(D.z_net_tpackets,{dev.tpackets,flag})
		table.insert(D.z_net_terrs,{dev.terrs,flag})
		table.insert(D.z_net_tdrop,{dev.tdrop,flag})
	end
end

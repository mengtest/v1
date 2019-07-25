#!/bin/sh

function die(){
	echo $1;exit -1;
}

export ROOT=$(cd `dirname $0`; pwd)
export OP_TYPE=0
while getopts "dki:t:h:s:n:m:" arg
do
	case $arg in
		i) export SVR_ID=$OPTARG;;
		t) export SVR_TYPE=$OPTARG;;
		s) export SVR_START=$OPTARG;;
		n) export SVR_NUM=$OPTARG;;
		m) export SVR_MOD=$OPTARG;;
		d) export OP_TYPE=1;;
		k) export OP_TYPE=2;;
		h) export SETTING_HOST=$OPTARG;;
	esac
done

export SETTING_HOST=${SETTING_HOST:-"http://192.168.1.30:6005/a8/mixed/clusters/"}

[ -z "$SVR_ID" ] && die "expected SVR_ID"
[ -z "$SVR_TYPE" ] && die "expected SVR_TYPE"

SVR_NAME="$SVR_TYPE"_"$SVR_ID"

export LOGPATH=$ROOT"/run/log/"
export PIDFILE=$ROOT"/run/"$SVR_NAME".pid"
export OUTPORT=$ROOT"/run/"$SVR_NAME".debugport"

[ -z "$SVR_ID" ] && die "expected SVR_ID"
if [ $OP_TYPE -eq 2 ]; then
	echo "start quit" | nc 127.0.0.1 `cat $OUTPORT` -v -i1
	# while [ -f $PIDFILE ]; do
	# 	sleep 1
	# done
	while true; do
		if [ -f $PIDFILE ]; then
			ps -fe|grep `cat $PIDFILE`|grep -v grep
			if [ $? -ne 0 ]; then
				exit 0 
			else
				sleep 1
			fi
		else
			exit 0
		fi
	done
fi

export LOGGER=""
export DAEMON=""

[ $OP_TYPE -eq 1 ] && export LOGGER=$LOGPATH$SVR_NAME".log"
[ $OP_TYPE -eq 1 ] && export DAEMON=$PIDFILE

$ROOT/skynet/skynet $ROOT/run/config.$SVR_TYPE $SVR_ID

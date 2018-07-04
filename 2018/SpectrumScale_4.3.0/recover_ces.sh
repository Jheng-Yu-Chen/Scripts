#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/lpp/mmfs/bin

CES_ADDRS=$(mmces address list  | grep `hostname` | awk '{print $1}')
HOST=`hostname`

function recover_ces(){
	ADDRESS="$1"
	NIC=`ip a | grep $ADDRESS | awk '{print $8}'`
	ifconfig $NIC del $ADDRESS
	case $ADDRESS in
		"1.1.1.196")
			HOSTNAME="bra24"
		;;
		"1.1.1.197")
			HOSTNAME="bra25"
		;;
		"1.1.1.198")
			HOSTNAME="bra26"
		;;
	esac
	sleep 1
	echo "ssh $HOSTNAME ifup ens5f0"
	sleep 3
	ssh $HOSTNAME ifup ens5f0 
	echo "mmces address move --ces-ip $ADDRESS --ces-node $HOSTNAME"
	mmces address move --ces-ip $ADDRESS --ces-node $HOSTNAME 

	echo "Done"
}

for ADDR in $CES_ADDRS
do
	case $HOST in
		"bra24")
			if [ "$ADDR" == "1.1.1.196" ]; then
				echo "$ADDR is good!"
			else
				recover_ces $ADDR
			fi
		;;
		"bra25")
                        if [ "$ADDR" == "1.1.1.197" ]; then
                                echo "$ADDR is good!"
                        else
                                recover_ces $ADDR
                        fi
		;;
		"bra26")
                        if [ "$ADDR" == "1.1.1.198" ]; then
                                echo "$ADDR is good!"
                        else
                                recover_ces $ADDR
                        fi
		;;
	esac
done

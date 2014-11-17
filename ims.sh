for p in `seq 10`
	echo "Round "$p
	ruby uas-tcp.rb > test.log &
	ruby uac-tcp.rb &


# create a new simulator
set ns [new Simulator]

# open trace and NAM trace file in write mode
set tf [open out.tr w]
$ns trace-all $tf
set nf [open out.nam w]
$ns namtrace-all $nf

# create 4 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# create duplex links between nodes
$ns duplex-link $n0 $n2 2Mb 1ms DropTail
$ns duplex-link $n1 $n2 2Mb 1ms DropTail
$ns duplex-link $n2 $n3 2Mb 1ms DropTail

# set n0 and n1 as tcp source
set tcp0 [new Agent/TCP]
set tcp1 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
$ns attach-agent $n1 $tcp1

# set n3 as tcp destination for n0 and n1
set TCPS0_3 [new Agent/TCPSink]
set TCPS1_3 [new Agent/TCPSink]
$ns attach-agent $n3 $TCPS0_3
$ns attach-agent $n3 $TCPS1_3

# set ftp over tcp0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

#set telnet over tcp1
set tel1 [new Application/Telnet]
$tel1 attach-agent $tcp1

# connect source to destination
$ns connect $tcp0 $TCPS0_3
$ns connect $tcp1 $TCPS1_3

proc finish { } {
	global ns nf tf
	$ns flush-trace
	exec nam out.nam &
	close $tf
	close $nf

	set fCount 0
	set tCount 0
	set tf [open out.tr r]
	while {[gets $tf line] != -1} {
		if { [string match "*tcp*0.0*3.0*" $line] } {
			set fCount [expr $fCount + 1]
		}
		if { [string match "*tcp*1.0*3.1*" $line] } {
			set tCount [expr $tCount + 1]
		}
	}
	puts "No of FTP packets: $fCount"
	puts "No of TELNET packets: $tCount"
	exit 0
}

# schedule events
$ns at 0.01 "$ftp0 start"
$ns at 0.01 "$tel1 start"
$ns at 1.01 "$ftp0 stop"
$ns at 1.01 "$tel1 stop"
$ns at 5.0 "finish"
$ns run

######################## output ################################
# akshat@pop-os:~/Desktop/NP Lab/B2 (FTP & TELNET)$ ns lab2.tcl 
# No of FTP packets: 1536
# No of TELNET packets: 12
################################################################
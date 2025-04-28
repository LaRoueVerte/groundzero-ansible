#!/usr/bin/perl 
my $cmd = 'curl -A "mozilla/4.0 (compatible; cURL 7.10.5-pre2; Linux 2.4.20)" -m 12 -s -L -k -b /tmp/bbapache_cookiejar.curl -c /tmp/bbapache_cookiejar.curl -H "Pragma: no-cache" -H "Cache-control: no-cache" -H "Connection: close" "http://localhost/server-status?auto"';
my $server_status = qx($cmd);
my $server_status = qx($cmd);
#
my($total_accesses,$total_kbytes,$cpuload,$uptime, $reqpersec,$bytespersec,$bytesperreq,$busyservers, $idleservers, $scoreboard);
#
$total_accesses = $1 if ($server_status =~ /Total\ Accesses:\ ([\d|\.]+)/ig)||0;
$total_kbytes = $1 if ($server_status =~ /Total\ kBytes:\ ([\d|\.]+)/gi);
$cpuload = $1 if ($server_status =~ /CPULoad:\ ([\d|\.]+)/gi);
$uptime = $1 if ($server_status =~ /Uptime:\ ([\d|\.]+)/gi);
$reqpersec = $1 if ($server_status =~ /ReqPerSec:\ ([\d|\.]+)/gi);
$bytespersec = $1 if ($server_status =~ /BytesPerSec:\ ([\d|\.]+)/gi);
$bytesperreq = $1 if ($server_status =~ /BytesPerReq:\ ([\d|\.]+)/gi);
$busyservers = $1 if ($server_status =~ /BusyWorkers:\ ([\d|\.]+)/gi);
$idleservers = $1 if ($server_status =~ /IdleWorkers:\ ([\d|\.]+)/gi);
$scoreboard = $1 if ($server_status =~ /Scoreboard:\ ([A-Z_]+)/gi);

open (FD, ">/tmp/apacheStatus/server_status.out");
print FD $server_status;
close FD;

open (FD, ">/tmp/apacheStatus/total_accesses.out");
print FD $total_accesses;
close FD;

open (FD, ">/tmp/apacheStatus/total_kbytes.out");
print FD $total_kbytes;
close FD;

open (FD, ">/tmp/apacheStatus/cpuload.out");
print FD $cpuload;
close FD;

open (FD, ">/tmp/apacheStatus/uptime.out");
print FD $uptime;
close FD;

open (FD, ">/tmp/apacheStatus/reqpersec.out");
print FD $reqpersec;
close FD;

open (FD, ">/tmp/apacheStatus/bytespersec.out");
print FD $bytespersec;
close FD;

open (FD, ">/tmp/apacheStatus/bytesperreq.out");
print FD $bytesperreq;
close FD;

open (FD, ">/tmp/apacheStatus/busyservers.out");
print FD $busyservers;
close FD;

open (FD, ">/tmp/apacheStatus/idleservers.out");
print FD $idleservers;
close FD;

open (FD, ">/tmp/apacheStatus/scoreboard.out");
print FD $scoreboard;
close FD;

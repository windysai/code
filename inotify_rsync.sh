#!/bin/bash
# date: 2017-7-17
# function: rsync 37.138 to 104.131.145.38

if [ ! -f /etc/rsyncd_udo.passwd ]; then
	echo "rsync321" > /etc/rsyncd_udo.passwd
	/bin/chmod 600 /etc/rsyncd_udo.passwd
fi

log=/usr/local/inotify/logs/rsync_inotify_mark.log
src="/home/ljy/rsync_inotify_trans/"
user=rsync
host="104.131.145.38"
module="windysai"

Inotifywait="/usr/local/inotify/bin/inotifywait"
Rsync="/usr/bin/rsync"


$Inotifywait -mrq -e 'close_write,modify,delete,create,attrib,moved_to' --timefmt '%Y-%m-%d %H:%M' --format '%T %f %e'  $src | while read DATE TIME DIR FILE;do
	 FILECHANGE=${DIR}${FILE};

	 $Rsync -avzP --password-file=/etc/rsyncd_udo.passwd $src $user@$host::$module 
	echo "At ${TIME} on ${DATE}, file $FILECHANGE was backed up via rsync" >> $log
done 


#!/bin/bash
# toolsched.d v0.17 by Con Kolivas <kernel@kolivas.org>

# Check we're only calling this as a symbolic link
if [[ ! -h $0 ]]; then
	echo "Calling toolsched.d directly, aborting!"
	echo "toolsched should only be called as a symbolic link."
	echo "Make sure you only have one copy of toolsched in your PATH."
	exit 1
fi

# cmd is the application we're trying to call
cmd=`basename $0`
# scriptcmd should resolve to this actual script
scriptcmd=`which $cmd 2>&1`

#find the command we're trying to run
for i in `which -a $cmd 2>&1`
do
	if [[ $i != $scriptcmd ]]; then
		command=$i;
		break
	fi
done

# Break out if command doesn't exist
if [[ ! -n $command ]]; then
	echo "$cmd: command not found"
	exit 1
fi

# Check for presence of schedtool in path.
# If not found just execute command
schedtool=`which schedtool 2>&1`
if [[ ! -n $schedtool ]]; then
	exec $command "$@"
	exit_status=$?
	exit $exit_status
fi

# make this script SCHED_IDLEPRIO thus if it succeeds the command will also
# run SCHED_IDLEPRIO.
$schedtool -D $$ >/dev/null 2>&1

# if it fails to set SCHED_IDLEPRIO try SCHED_BATCH
if [[ $? -ne 0 ]]; then
	$schedtool -B $$ >/dev/null 2>&1
fi

# run the command, returning its exit status
exec $command "$@"
exit_status=$?
exit $exit_status

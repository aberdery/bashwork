#!/bin/bash

################################################################################
#                                                                              #
# Script Name Here                                                             #
#                                                                              #
################################################################################
source my_bash_lib

##################################
#                                #
# Default values                 #
#                                #
##################################

##################################
#                                #
# Internal functions             #
#                                #
##################################
usage()
{
    cat <<EOF

USAGE:
	$0 -hq -d <level> ...

	-h: print this help and exit
	-d <level>: debug verbosity levels (1:info (default), 2:warning, 3:debug)
	-q: set quiet output
EOF
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#
# SCRIPT BEGINS HERE
#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Parse args
d_given=0
while getopts ":hqd:" OPTION; do
	case $OPTION in
	h)
		usage
		exit 0
		;;
	d)
		d_given=1
		if [[ $OPTARG = -* ]]; then
			((OPTIND--))
		        continue
		fi
		d_given=2
		DBG=$OPTARG
		if [ ! -z "${DBG##*[!0-9]*}" ]; then
			disp "Debug activated with level $OPTARG"
		else
			error "-$OPTION expects a number"
			usage
			exit 1
		fi
		;;
	q)
		QUIET="yes"
		;;
	:)
		error "Option -$OPTARG expects an argument."
		usage
		exit 1
		;;
	\?)
		error "Invalid option: -$OPTARG"
		exit 1

	esac
done

# Check args
[ $d_given -eq 1 ] && error "Option -d expects an argument." && usage && exit 1

# Now args are parsed/checked, let's get remaining parameters
shift $((OPTIND-1)) # can now do something wth $@
OPTION_REMAINDER="$@"
dbg_debug "Remaining arg(s): $OPTION_REMAINDER"




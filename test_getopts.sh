#!/bin/bash

###################################################################################
#                                                                                 #
# Script Name Here:                                                               #
#                                                                                 #
###################################################################################
source my_bash_lib

##################################
#                                #
# Some default values            #
#                                #
##################################
DBG=1

##################################
#                                #
# Some internal script functions #
#                                #
##################################
usage()
{
    cat <<EOF

USAGE:
	$0 -hdq -a <argname> ...

	-h: print this help and exit
	-d <level>: debug verbosity levels (1:info (default), 2:warning, 3:debug)
	-q: set quiet output
	-a <argname>

EOF
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#
# SCRIPT BEGINS HERE
#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a_given=0
d_given=0
while getopts ":hqd:a:" OPTION; do
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
			error "-$OPTION requires a number"
			usage
			exit 1
		fi
		;;
	q)
		QUIET="yes"
		;;
	a)
		a_given=1
		if [[ $OPTARG = -* ]]; then
			((OPTIND--))
		        continue
		fi
		a_given=2
		MAIN_ARG=$OPTARG
		;;
	:)
		error "Option -$OPTARG requires an argument."
		usage
		exit 1
		;;
	\?)
		error "Invalid option: -$OPTARG"
		exit 1

	esac
done

[ $a_given -eq 1 ] && error "Option -a requires an argument." && usage && exit 1
[ $d_given -eq 1 ] && error "Option -d requires an argument." && usage && exit 1

# Now args are parsed, let's get remaining parameters
shift $((OPTIND-1)) # can now do something wth $@
OPTION_REMAINDER="$@"

dbg_warn "This prog is a template !"
dbg_debug "Main argument: ${MAIN_ARG}"
dbg_info "Remaining arg(s): $OPTION_REMAINDER"


#!/bin/bash

################################################################################
#                                                                              #
# Script Name Here                                                             #
#                                                                              #
################################################################################
# source: http://doc.ubuntu-fr.org/nettoyer_ubuntu#supprimer_les_logiciels_orphelins
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
	$0 -o <clean_option>

	-h: print this help and exit
	-d <level>: debug verbosity levels (1:info (default), 2:warning, 3:debug)
	-q: set quiet output
	-o <clean_option>:
	  1: clean unused
	  2: display unused kernel modules
	  3: clean unused kernel modules
          4: clean all
        -a: clean all

EOF
}

clean_unused()
{
    # autoclean
    sudo apt-get autoclean
    # clean
    sudo apt-get clean
    # autoremove
    sudo apt-get autoremove
    # purge residual
    residual=$(COLUMNS=200 dpkg -l | grep "^rc" | tr -s ' ' | cut -d ' ' -f 2)
    if [ -n "${residual}" ]; then
        sudo dpkg --purge $residual
    else
        disp "No residual"
    fi
    # purge orphans
    orphans=$(deborphan)
    if [ -n "${orphans}" ]; then
        sudo apt-get purge $orphans
    else
        disp "No orphan"
    fi
}

display_unused_kernel()
{
    unused_k=$(dpkg -l | awk '{print $2}' |                             \
        grep -E "linux-(image|headers)-$(uname -r | cut -d- -f1).*" |   \
        grep -v $(uname -r | sed -r -e 's:-[a-z]+.*::'))
    if [ -n "${unused_k}" ]; then
        echo ${unused_k}
        return 1
    else
        disp "No unused kernel modules"
        return 0
    fi
}

clean_unused_kernel()
{
    unused_k="$(display_unused_kernel)"
    if [ $? -eq 1 ]; then
        echo ${unused_k}
        sudo apt-get purge ${unused_k}
    else
        disp "Unused kernel modules not found"
    fi
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#
# SCRIPT BEGINS HERE
#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Parse args
CLEAN=1
d_given=0
while getopts ":hqad:o:" OPTION; do
    case $OPTION in
        h)
            usage
            exit 0
            ;;
        a)
            CLEAN=4
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
                dbg_info "Debug activated with level $OPTARG"
            else
                error "-$OPTION expects a number"
                usage
                exit 1
            fi
            ;;
        o)
            CLEAN=$OPTARG;;
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

case $CLEAN in
    1)
        dbg_debug "option 1"
        clean_unused
        ;;
    2)
        dbg_debug "option 2"
        display_unused_kernel
        ;;
    3)
        dbg_debug "option 3"
        clean_unused_kernel
        ;;
    4)
        dbg_debug "option 4"
        clean_unused
        clean_unused_kernel
        ;;
esac





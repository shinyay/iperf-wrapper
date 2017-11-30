#!/bin/sh

# ##################################################
#
PROGNAME=$(basename $0)
VERSION="1.0.0"
#
# HISTORY:
#
# * 17/11/30 - v1.0.0  - First Creation
#
###################################################

PORT=5201
OMIT_TIME=5
INITIAL_LENGTH=8
RECURRENCE=3

function mainScript() {
  echo "iperf3 -c ${SERVER_ADDRESS} -p ${PORT} -t ${TRANSMIT_TIME} -V -O ${OMIT_TIME} -P ${PARALLEL_NUMBER} -l ${LENGTH_BUFFER}"
  OUTPUT_LOG=result_${PARALLEL_NUMBER}_${LENGTH_BUFFER}_`date +%y%m%d-%H%M%S`.out
  iperf3 -c ${SERVER_ADDRESS} -p ${PORT} -t ${TRANSMIT_TIME} -V -O ${OMIT_TIME} -P ${PARALLEL_NUMBER} -l ${LENGTH_BUFFER}> ${OUTPUT_LOG}
}

function callMainScript() {
  COUNT=0
  LENGTH_BUFFER=$INITIAL_LENGTH
  while [[ $COUNT -lt $RECURRENCE ]]; do
    #echo $LENGTH_BUFFER
    mainScript
    LENGTH_BUFFER=$(( LENGTH_BUFFER*2 ))
    COUNT=$(( COUNT+1 ))
  done
}

function usage() {
    cat <<EOF
$(basename ${0}) is a tool for ...
Usage:
    $(basename ${0}) -c <SERVER_ADDRESS> -t <TRANSMIT_TIME> -P <PARALLEL_NUMBER>
Options:
    -c, --client      connect server address
    -t, --time        time in seconds transmit
    -P, --parallel    number of parallel client
    -p, --port        connect port
 
    -v, --version     print $(basename ${0}) ${VERSION}
    -h, --help        print help
EOF
}

# Check Arguments
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

# Handle Options
for OPT in "$@"
do
  case "$OPT" in
    '-v'|'--version' )
      echo "$(basename ${0}) ${VERSION}"
      exit 0
      ;;
    '-h'|'--help' )
      usage
      exit 0
      ;;
    '-d'|'--debug' )
      set -x
      ;;
    '-c'|'--client' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      SERVER_ADDRESS="$2"
      shift 2
      ;;
    '-t'|'--time' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      TRANSMIT_TIME="$2"
      shift 2
      ;;
    '-P'|'--parallel' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      PARALLEL_NUMBER="$2"
      shift 2
      ;;
    '-p'|'--port' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      PORT="$2"
      shift 2
      ;;
    -*)
      echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
      exit 1
      ;;
    *)
      if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
        param+=( "$1" )
        shift 1
      fi
      ;;
  esac
done

callMainScript

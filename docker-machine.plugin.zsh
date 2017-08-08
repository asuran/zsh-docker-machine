declare -A DMACHINE_PROJECT_CONFIG

source $(dirname $0)/functions.sh

function _validate_command() {
  local command_list=(start stop pause restart switch status env config)

  for command in $command_list; do
    if [ "$command" = "$1" ]; then
      return 0
    fi
  done

  return 1
}

function _validate_machine() {
  local machine_list=($(dm ls | awk '(NR!=1) {print $1}'))

  for machine in $machine_list; do
    if [ "$machine" = "$1" ]; then
      return 0
    fi
  done

  return 1
}

function dmachine() {
  local CURRENT_DIR=$(pwd)

  # set command
  _validate_command $1
  if [ $? -gt 0 ]; then
    usage
    exit 1
  fi
  local COMMAND=$1
  shift

  #set options
  while [ $# -gt 0 ]; do
    case $1 in
      -o|--open-in-phpstorm)
        PHPSTORM=1
        shift
        ;;
      -w|--change-working-directory)
        CHDIR=1
        shift
        ;;
      -e|--with-env)
        WITH_ENV=1
        shift
        ;;
      -d|--with-dns)
        WITH_DNS=1
        shift
        ;;
      --debug)
        DEBUG=1
        shift
        ;;
      *)
        _validate_machine $1

        if [ $? -gt 0 ]; then
          usage
          exit 1
        fi

        local MACHINE=$1
        shift
        ;;
    esac
  done

  local STATUS=$(dm ls | awk -v name=$MACHINE '($1 == name) {print $4}')

  if [ "$DEBUG" = 1 ]; then
    echo 'DUBUG:'
    echo 'command: '$COMMAND
    echo 'machine: '$MACHINE
    echo 'status: '$STATUS
  fi

  case $COMMAND in
    "start")
      case $STATUS in
        "Stopped")
          _start_dm $MACHINE
          ;;
        "Paused")
          _resume_dm $MACHINE
          ;;
        "Saved")
          _start_via_vboxmanage $MACHINE
          ;;
        "Running")
          echo '"'$MACHINE'" is already running'
          ;;
      esac
      ;;

    "stop")
      case $STATUS in
        "Stopped")
          echo '"'$MACHINE'" is already stopped'
          ;;
        "Paused"|"Running")
          _stop_dm $MACHINE
          ;;
      esac
      ;;

    "pause")
      case $STATUS in
        "Stopped"|"Paused")
          echo '"'$MACHINE'" is not running'
          ;;
        "Running")
           _save_state $MACHINE
          ;;
      esac
      ;;

    "restart")
      case $STATUS in
        "Stopped"|"Paused")
          echo '"'$MACHINE'" is not running'
          ;;
        "Running")
          _stop_dm $MACHINE
          ;;
      esac

      _start_dm $MACHINE
      ;;

    "switch")
      _pause_running
      case $STATUS in
        "Stopped")
          _start_dm $MACHINE
          ;;
        "Paused")
          _resume_dm $MACHINE
          ;;
        "Saved")
          _start_via_vboxmanage $MACHINE
          ;;
        "Running")
          echo '"'$MACHINE'" is already running'
          ;;
      esac
      ;;

      _env $MACHINE

    "status")
      echo '"'$MACHINE'" is '$STATUS
      ;;

    "env")
      _env $MACHINE
      ;;
    # "config")
    #     _load_config $CURRENT_DIR
    #     for k in "${(@k)DMACHINE_PROJECT_CONFIG}"
    #     do
    #       echo $k:${DMACHINE_PROJECT_CONFIG[$k]}
    #     done
    #   ;;
    *)
      usage
      ;;
  esac
}

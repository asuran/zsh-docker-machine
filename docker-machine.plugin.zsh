source $(dirname $0)/functions.sh

# Flags
WITH_ENV=0
WITH_DNS=0
DEBUG=0

function dmachine() {
  local CURRENT_DIR=$(pwd)

  # Parse arguments
  while [ $# -gt 0 ]; do
    case $1 in
      start|stop|pause|restart|switch|state|env|config)
        local COMMAND=$1
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
        local MACHINE=$1
        shift
        _validate_machine $MACHINE
        if [ $? -gt 0 ]; then
          echo 'Machine "'$MACHINE'" not does not exists"'
          usage
          exit 1
        fi
        ;;
    esac
  done

  local STATE=$(docker-machine ls --filter name=$MACHINE --format {{.State}})

  if [ "$DEBUG" = 1 ]; then
    echo 'DUBUG:'
    echo 'Command: '$COMMAND
    echo 'Machine name: '$MACHINE
    echo 'Machine state: '$STATE
    echo '--with-env='$WITH_ENV
    echo '--with-dns='$WITH_DNS
  fi

  case $COMMAND in
    "start")
      case $STATE in
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

      if [ $WITH_ENV ]; then
        _env $MACHINE
      fi
      ;;

    "stop")
      case $STATE in
        "Stopped")
          echo '"'$MACHINE'" is already stopped'
          ;;
        "Paused"|"Running")
          _stop_dm $MACHINE
          ;;
      esac
      ;;

    "pause")
      case $STATE in
        "Stopped"|"Paused")
          echo '"'$MACHINE'" is not running'
          ;;
        "Running")
           _save_state $MACHINE
          ;;
      esac
      ;;

    "restart")
      case $STATE in
        "Stopped"|"Paused")
          echo '"'$MACHINE'" is not running'
          ;;
        "Running")
          _stop_dm $MACHINE
          ;;
      esac

      _start_dm $MACHINE
      if [ $WITH_ENV ]; then
        _env $MACHINE
      fi
      ;;

    "switch")
      _pause_running
      case $STATE in
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
      _env $MACHINE
      ;;

    "state")
      echo '"'$MACHINE'" is '$STATE
      ;;

    "env")
      _env $MACHINE
      ;;
    *)
      usage
      ;;
  esac
}

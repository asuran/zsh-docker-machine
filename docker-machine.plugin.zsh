declare -A DMACHINE_PROJECT_CONFIG

source $(dirname $0)/functions.sh

function dmachine() {
  local ACTION_NAME=$1
  local MACHINE_NAME=$2

  local CURRENT_DIR=$(pwd)

  MACHINE_STATUS=$(dm ls | awk -v name=$MACHINE_NAME '($1 == name) {print $4}')

  case $ACTION_NAME in
    "start")
      case $MACHINE_STATUS in
        "Stopped")
          _start_dm $MACHINE_NAME
          ;;
        "Paused")
          _resume_dm $MACHINE_NAME
          ;;
        "Saved")
          _start_via_vboxmanage $MACHINE_NAME
          ;;
        "Running")
          echo '"'$MACHINE_NAME'" is already running'
          ;;
      esac
      ;;

    "stop")
      case $MACHINE_STATUS in
        "Stopped")
          echo 'Machine with name "'$MACHINE_NAME'" is already stopped'
          ;;
          "Paused")
          _stop_dm $MACHINE_NAME
          ;;
        "Running")
          _stop_dm $MACHINE_NAME
          ;;
      esac
      ;;

    "pause")
      case $MACHINE_STATUS in
        "Stopped")
          echo 'Machine with name "'$MACHINE_NAME'" is not running'
          ;;
        "Paused")
          echo 'Machine with name "'$MACHINE_NAME'" is already paused'
          ;;
        "Running")
           _save_state $MACHINE_NAME
          ;;
      esac
      ;;

    "restart")
      case $MACHINE_STATUS in
        "Stopped")
          echo 'Machine with name "'$MACHINE_NAME'" is not running'
          ;;
        "Paused")
          echo 'Machine with name "'$MACHINE_NAME'" is not running'
          ;;
        "Running")
          echo 'Machine with name "'$MACHINE_NAME'" is not running'
          _stop_dm $MACHINE_NAME
          _start_dm $MACHINE_NAME
          ;;
      esac
      ;;

    "switch")
      _pause_running
      case $MACHINE_STATUS in
        "Stopped")
          _start_dm $MACHINE_NAME
          ;;
        "Paused")
          _resume_dm $MACHINE_NAME
          ;;
        "Saved")
          _start_via_vboxmanage $MACHINE_NAME
          ;;
        "Running")
          echo 'Machine with name "'$MACHINE_NAME'" is already running'
          ;;
      esac
      ;;

    "status")
      echo 'Machine with name "'$MACHINE_NAME'" is '$MACHINE_STATUS
      ;;

    "env")
      _env $MACHINE_NAME
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

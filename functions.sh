usage() {
  echo "Usage:"
  echo "dmachine <start|stop|pause|restart|switch|env> <machine_name>"
  echo "dmachine -h"
  return 1
}

_start_dns() {
  ps -ax | grep -q "[d]ocker-machine-dns"

  echo "Checking if DNS is runnning..."
  if [ $? -eq 1 ]; then
    echo "Running DNS..."
    docker-machine-dns &
  fi
  echo "DNS is running."
}

_start_dm() {
  machine=$1
  docker-machine start $machine
  docker-machine regenerate-certs -f $machine
  docker-machine-nfs $machine
}

_stop_dm() {
  machine=$1
  docker-machine stop $machine
}

_resume_dm() {
  machine=$1
  VboxManage startvm $machine --type headless
}

_start_via_vboxmanage() {
  machine=$1
  VboxManage startvm $machine --type headless
}

_pause_dm() {
  machine=$1
  echo 'Pausing '$machine
  VBoxManage controlvm $machine pause
}

_save_state() {
  machine=$1
  echo 'Waiting for VM "'$machine'" to save state...'
  VBoxManage controlvm $machine savestate
}

_env() {
  machine=$1
  docker-machine env $machine
  eval $(docker-machine env $machine)
}


_pause_running() {
  runningMachines=($(dm ls | awk '(NR!=1 && $4=="Running") {print $1}'))
  for machine in $runningMachines; do
    _save_state $machine;
  done
}

# _load_config() {
#   directory=$1
#   declare -A DMACHINE_PROJECT_CONFIG
#   while read name value
#   do
#       DMACHINE_PROJECT_CONFIG[$name]="$value"
#   done < $directory/.dmachine
# }

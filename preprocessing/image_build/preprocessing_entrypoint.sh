#!/bin/bash

# Simplifying preprocessing workflow. Runs user specified actions with basic interface.

# Handle quitting the script.
handle_signal() {
  echo -e "\nSignal received. Exiting..."
  exit 0
}

# Driving the script.
run_script() {
  local script=$1
  local descrip=$2

  echo "$descrip ($script)..."
  bash $script

  if [ $? -eq 0 ]; then
    echo "$descrip: COMPLETE"
  else
    echo "$descrip: ERROR"
    activate_shell=true
  fi
}

# Trap SIGTSTP (Ctrl-Z) and SIGINT (Ctrl-C)
trap handle_signal SIGTSTP SIGINT

# Shell activates at end if error occurs or manual access requested.
activate_shell=false

while true; do
  # Prompt the user for input
  echo -e "\n\nEnter:\n'a' to generate grid (driver_grid.gaea.sh)\n'b' to create initial conditions (chgres_cube.sh)\n'c' to run both (driver_grid.gaea.sh then chgres_cube.sh)\n'd' for manual access\nPress Ctrl-Z or Ctrl-C to quit."
  read -r user_input
  user_input=$(echo $user_input | tr '[:upper:]' '[:lower:]')

  case $user_input in
    'a')
      run_script /workdir/driver_scripts/driver_grid.gaea.sh "Generating grid"
      break
      ;;
    'b')
      run_script /workdir/driver_scripts/chgres_cube.sh "Creating initial conditions"
      break
      ;;
    'c')
      run_script /workdir/driver_scripts/driver_grid.gaea.sh "Generating grid"
      run_script /workdir/driver_scripts/chgres_cube.sh "Creating initial conditions"
      break
      ;;
    'd')
      echo "Entering manual access..."
      activate_shell=true
      break
      ;;
    *)
      echo "Invalid input. Please try again."
      ;;
  esac
done

if [ "$activate_shell" = true ]; then
  echo "Activating bash shell..."
  exec bash
fi
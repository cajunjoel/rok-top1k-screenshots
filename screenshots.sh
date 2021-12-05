#!/usr/bin/env bash
#
# Blah blah blah
#
cd `dirname "$0"`

source settings.sh 
source functions.sh

ONE=NO
START=1
VERBOSE=""
HELP=""
GOVERNOR_NAME=""
GOVERNOR_LIST=()
COMMAND_LINE=()

# Parse the command line
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
      -s|--start)
      START="$2"
      shift # past argument
      shift # past value
      ;;

      -o|--one)
      ONE=YES
      shift # past argument
      ;;

      -v|--verbose)
      VERBOSE=YES
      shift # past argument
      ;;

      -h|--help)
      HELP=YES
      shift # past argument
      ;;

      *)    # unknown option
      COMMAND_LINE+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done
set -- "${COMMAND_LINE[@]}" # restore positional parameters

# Show the help because we asked for it, but nothing else happens
if [[ "$HELP" == "YES" ]]; then
  show_usage
  exit 0;
fi

# Make sure we have a place to save the screenshots
SAVE_PATH=${COMMAND_LINE[0]}
if [[ -z "$SAVE_PATH" ]]; then
  SAVE_PATH=`date +"./screenshots-output-%Y-%m-%d"`
fi
if [[ ! -d "$SAVE_PATH" ]]; then
  log "Creating directory: ${SAVE_PATH}"
  mkdir $SAVE_PATH
fi

# Debugging info
log "Saving screenshots to: ${SAVE_PATH}"
if [[ "$ONE" != "YES" ]]; then
  log "Starting at index: ${START}"
else 
  log "Capturing only one Governor"
fi;

# Change to the directory for the images, 'scrot' uses PWD to save
cd $SAVE_PATH
select_window "$WINDOW_NAME"

if [[ "$ONE" == "YES" ]]; then
  # capture the info for exactly one governor, but do nothing else.
  capture_governor ${G4[0]} ${G4[1]}
  xdotool mousemove --screen 0 ${G4[0]} ${G4[1]}

else 
  # The first four governors are special
  if [[ "$START" -eq "1" ]]; then
    capture_governor ${G1[0]} ${G1[1]}
    START=$((START+1))
  fi
  if [[ "$START" -eq "2" ]]; then
    capture_governor ${G2[0]} ${G2[1]}
    START=$((START+1))
  fi
  if [[ "$START" -eq "3" ]]; then
    capture_governor ${G3[0]} ${G3[1]}
    START=$((START+1))
  fi
  if [[ "$START" -eq "4" ]]; then
    capture_governor ${G4[0]} ${G4[1]}
    START=$((START+1))
  fi

  # The next 994 governors are not special.
  #
  # The list of the top 1000 automatically scrolls
  # by one each time a governor's information is
  # opened.
  #
  # Therefore we can repeat this until we are done 
  # with number 998
  while [[ $START -le "998" ]]; do
    capture_governor ${G4[0]} ${G4[1]}
    START=$((START+1))
    echo -n "$START..."
  done 

  # The last two governors are special because the
  # list of the top 1000 governors doesn't scroll.
  capture_governor ${G999[0]} ${G999[1]}
  capture_governor ${G1000[0]} ${G1000[1]}

fi

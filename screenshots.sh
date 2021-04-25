#!/usr/bin/env bash
#
# Blah blah blah
#
. settings.sh 
. functions.sh

# Parse the command line
POSITIONAL=()
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
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Show the help because we asked for it, but nothing else happens
if [[ "$HELP" == "YES" ]]; then
  show_usage
  exit 0;
fi


# Make sure we have a place to save the screenshots
SAVE_PATH=${POSITIONAL[0]}
if [[ -z "$SAVE_PATH" ]]; then
  SAVE_PATH="./screenshots-output"
fi
if [[ ! -d "$SAVE_PATH" ]]; then
  if [[ "$VERBOSE" == "YES" ]]; then
    echo "Creating directory: ${SAVE_PATH}"
  fi
  mkdir $SAVE_PATH
fi

# If we didn't provide an index into the top 1000 governors, we
# start at the beginning
if [[ -z "$START" ]]; then
  START=1
fi

# Debugging info
if [[ "$VERBOSE" == "YES" ]]; then
  echo "Saving screenshots to: ${SAVE_PATH}"
  if [[ "$ONE" != "YES" ]]; then
    echo "Starting at index: ${START}"
  else 
    echo "Capturing only one Governor"
  fi;
fi

# capture the info for exactly one governor, but do nothing else.
cd $SAVE_PATH
select_window "$WINDOW_NAME"

if [[ "$ONE" == "YES" ]]; then
  # Screencap only one governor
  capture_governor ${G1[0]} ${G1[1]}

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
  done 

  # The last two governors are special because the
  # list of the top 1000 governors doesn't scroll.
  capture_governor ${G999[0]} ${G999[1]}
  capture_governor ${G1000[0]} ${G1000[1]}

fi

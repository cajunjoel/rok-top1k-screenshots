function show_usage {
  echo "Usage: screenshot.sh [OPTIONS] [PATH]"
  echo "" 
  echo "Automate RoK screen captures using Vysor, xclip and scrot."
  echo "Uses the top 1000 power list to get governor information."
  echo ""
  echo "OPTIONS:"
  echo "  -s, --start      Using the Top 1000 Governor Power list,"
  echo "                   start taking screenshots at this number."
  echo "                   (Assumes the Top 1000 is already open.)"
  echo "  -o, --one        Take screenshots for exactly one governor."
  echo "                   (Assumes the governor profile is already open)"
  echo ""
  echo "PATH is the location in which to save the screenshots. Three"
  echo "screenshots are saved for each player using the player's name"
  echo "as the filename. The default path is \"screenshots-output\"."
  echo ""
  echo "The \"settings.sh\" file must be configured for your display and"
  echo "RoK screen sharing tool. "
}

function log {
  if [[ "$VERBOSE" == "YES" ]]; then
    echo "$1"
  fi
}
function take_screenshot {
  if [[ -e "$1" ]]; then
    /bin/rm "$1"
  fi
  /usr/bin/scrot "$1"
}

function click_mouse {
  xdotool mousemove --screen 0 $1 $2 
  xdotool click 1
  sleep 0.5
}

function copy_name {
  
  # Set the clipboard to something invalud
  echo "no-governor" | xclip -i

  # Click top copy the governor name to the clipboard
  click_mouse ${GOVNAME[0]} ${GOVNAME[1]}
  GOVERNOR_NAME=$(xclip -o)
  WAIT=0
  FAILSAFE=0
  # Keep trying until we have a governor name
  while [[ "$GOVERNOR_NAME" == "no-governor" ]]; do
    sleep 0.25
    GOVERNOR_NAME=$(xclip -o)
    WAIT=$((WAIT+1))
    FAILSAFE=$((FAILSAFE+1))
    # If after 1 second, we still don't have a name, click again
    if [[ "$WAIT" == "4" ]]; then
      log "Didn't get governor name after 1 second, clicking again."
      click_mouse ${GOVNAME[0]} ${GOVNAME[1]}
      WAIT=0
    fi
    # Failsafe: after 5 seconds, something horrible went wrong
    if [[ "$FAILSAFE" == "20" ]]; then
      log "Didn't get governor name after 5 second. Triggering Failsafe."
      GOVERNOR_NAME="failsafe-triggered"
      return
    fi
  done
}

function click_and_compare {
  # Grab "before" screenshot
  take_screenshot "temp1.png"

  # Open the governor
  click_mouse $1 $2
  # sleep a long time before getting the second screenshot
  sleep 1

  # Grab "before" screenshot
  take_screenshot "temp2.png"
  sleep .25 

  # Use some image magick (get it??) to determine if the images are different
  IMAGE_CHANGE=$(/usr/bin/compare -metric MAE temp1.png temp2.png null: 2>&1 | cut -f 1 -d ' ' | cut -f 1 -d '.' )
  log "Image Changed by a factor of ${IMAGE_CHANGE}"

  if [[ "$IMAGE_CHANGE" -lt "2000" ]]; then
    CONTINUE=NO
  else
    CONTINUE=YES
  fi
}

function capture_governor {
  CONTINUE=""
  # Open the governor info window, but try to 
  # detect if it actually changed
  click_and_compare $1 $2
  if [[ "$CONTINUE" == "NO" ]]; then
    echo "Trying again for the governor second from the bottom."
    click_and_compare ${G999[0]} ${G999[1]}

    if [[ "$CONTINUE" == "NO" ]]; then
      echo "Trying again for the governor at the bottom." 
      click_and_compare ${G1000[0]} ${G1000[1]}

      if [[ "$CONTINUE" == "NO" ]]; then
        echo "Could not continue. Three governors in a row were unclickable."
        exit
      fi
    fi
  fi

  # Copy the governor name to the clipboard
  copy_name
  log "Using Governor name '$GOVERNOR_NAME'."
  take_screenshot "$GOVERNOR_NAME--1.png"

  # Open More Info
  click_mouse ${MORE[0]} ${MORE[1]} 
  take_screenshot "$GOVERNOR_NAME--2.png"
  sleep 0.5

  # Open Kill Points
  click_mouse ${KPOINTS[0]} ${KPOINTS[1]} 
  take_screenshot "$GOVERNOR_NAME--3.png"
  sleep 0.5
  
  # Close More Info
  click_mouse ${CMORE[0]} ${CMORE[1]}
  sleep 0.5

  # Close Governor Profile
  click_mouse ${CGOV[0]} ${CGOV[1]}
  sleep 0.5
}

function select_window {
  # Select the window 
  WINDOW=$(xdotool search --name "$1")
  if [[ "$?" == "1" ]]; then
    echo "Window with name '$1' could not be found."
    exit 1
  fi

  xdotool windowraise $WINDOW
  xdotool windowfocus --sync $WINDOW
  xdotool windowmove $WINDOW $WIN_X $WIN_Y
  xdotool windowsize $WINDOW $WIN_W $WIN_H
  sleep 0.5

}

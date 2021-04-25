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

function take_screenshot {
  /usr/bin/scrot "$1"
}

function click_mouse {
  xdotool mousemove --screen 0 $1 $2 
  xdotool click 1
  sleep 0.5
}

function copy_name {
  echo "XYZZY" | xclip -i
  click_mouse ${GOVNAME[0]} ${GOVNAME[1]}
  GOV_NAME=$(xclip -o)
  ZZ=0
  while [[ "$GOV_NAME" == "XYZZY" ]]; do
    sleep 0.25
    GOV_NAME=$(xclip -o)
    ZZ=$((ZZ+1))
    if [[ "$ZZ" == "6" ]]; then
      echo "Didn't get governor name, clicking again"
      click_mouse ${GOVNAME[0]} ${GOVNAME[1]}
      ZZ=0
    fi
  done
}

function capture_governor {
  GOV_X=$1
  GOV_Y=$2
  
  # Open the governor
  click_mouse $GOV_X $GOV_Y 

  # Copy the governor name to the clipboard
  copy_name
  take_screenshot "$GOV_NAME--1.png"

  # Open More Info
  click_mouse ${MORE[0]} ${MORE[1]} 
  take_screenshot "$GOV_NAME--2.png"

  # Open Kill Points
  click_mouse ${KPOINTS[0]} ${KPOINTS[1]} 
  take_screenshot "$GOV_NAME--3.png"
  
  click_mouse ${CMORE[0]} ${CMORE[1]}  # Close More Info
  click_mouse ${CGOV[0]} ${CGOV[1]}  # Close Governor
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
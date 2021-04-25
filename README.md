# Rise of Kingdoms - Top 1000 Screenshots

A Bash script to automate collecting the three screenshots for the Top 1000 Governors in power. The screenshots can then be used for whatever nefarious purposes you have, such as OCR to extract the content from the screenshots.

OCR is left as an exercise for the reader.

# Requirements

This script uses Vysor to share the screen from an Android mobile phone. Other tools may be used, but they must run on Linux or in some Linux shell on windows. 

`xdotool` is used to move and resize the window, and to perform mouse clicks.

`xclip` is used to read from the clipboard.

`scrot` is used to capture screenshots. 

# Setup

In the `settings.sh` file you must identify and set window location and size and the XY Coordinates for each of the mouse clicks necessary to load the varioys pages of the Governor's information.

# Usage

`screenshot.sh [OPTIONS] [PATH]`

`PATH` is the location in which to save the screenshots. Three screenshots are saved for each player using the player's name as the filename. The default path is `./screenshots-output`.

## Options

`-s`, `--start`
Using the Top 1000 Governor Power list, start taking  screenshots at this number. (Assumes the Top 1000 is already open.)

`-o`, `--one`
Take screenshots for exactly one governor. (Assumes the governor profile is already open)

## Examples

Capture just one governor's screenshots, placing the screenshots in the default folder

`./screenshot.sh --one`

Start capturing at the 46th governor, placing the screenshots in the default folder

`./screenshot.sh --start 46` 

Save the screenshots to a folder in the user's home directory, print additional information

`./screenshot.sh --verbose ~/RoK-Screenshots` 

# Notes

Once the script is running, it's very hard to stop it due the mouse jumping all over the screen. There are no hotkeys stop it once it's running. Good luck.

If a screenshot file already exists, new filenames with -000 or -001 will be created. Existing screenshots will not be overwritten.

For reliability, the script makes multiple attempts to get the governor's name and copy it to the clipboard. Due to this, if the governor's info page doesn't load because of some error or they don't exist, the script will hang forever.


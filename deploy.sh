#!/bin/bash

#
# Global variables.
#

APP="$(pwd)/app"

if [ -z "$METEOR_SRC" ]; then
  METEOR_SRC="$HOME/.meteor/meteor"
fi

#
# Help and usage info.
#

display_help() {
  cat <<-EOF
  Usage: start [options]
  Options:
    -h|--help|help                Display help
    -browser|--browser|browser    Start in Browser
    -android|--android|android    Start on Android device
    -ios|--ios|ios                Start on iOS device
EOF
  exit 0
}

#
# Start your application.
#

deploy() {
  while true; do
    read -p "Where do you want to start?
    1. browser
    2. android-device
    3. ios-device
[choose #]: " env

    case "$env" in
      "1"|"development"|"dev")
        NODE_ENV="development"
        break;
      ;;
      "2"|"android-device")
        NODE_ENV="android-device"
        break;
      ;;
      "3"|"ios-device")
        NODE_ENV="ios-device"
        break;
      ;;
      *) echo "**** Try again. Use 'ctrl + C' to stop."; echo; ;;
    esac
  done

  eval "cd $APP"
  case "$NODE_ENV" in
    "development")
      browser
    ;;
    "android-device")
      echo "Starting on *Android Device*"
      android_device
    ;;
    "ios-device")
      echo "Starting on *iOS Device*"
      ios_device
    ;;
    *)
      echo
    ;;
  esac
}

browser() {
  cd "$APP"

  echo "Starting App for browser"
  local CMD="$METEOR_SRC run";
  echo "$CMD"; eval "$CMD";
}
android_device() {
  check_platform_installed "android";

  cd "$APP"

  local CMD="$METEOR_SRC run android-device --verbose"

  echo "$CMD"
  read -p "Press [Enter] key to continue..."

  eval ${CMD}
}

ios_device() {
  check_platform_installed "ios";

  cd "$APP";

  #Remove Xcode SharedPrecompiledHeaders before building
  eval "rm -rf /var/folders/*/*/C/com.apple.DeveloperTools/*/Xcode/SharedPrecompiledHeaders/*"
  local CMD="$METEOR_SRC run ios-device --verbose"

  echo "$CMD";
  read -p "Press [Enter] key to continue..."

  eval ${CMD};
}

# remove one platform and add the other 'ios/android'
check_platform_installed() {
  while [ $# -ne 0 ]; do
    case $1 in
      ios)
        eval "$METEOR_SRC remove-platform android"
        eval "$METEOR_SRC add-platform ios"
      ;;
      android)
        eval "$METEOR_SRC remove-platform ios"
        eval "$METEOR_SRC add-platform android"
      ;;
    esac
    shift
  done
}

#
# Handle arguments.
#

if [ $# -eq 0 ]; then
  browser
else
  while [ $# -ne 0 ]; do
    case $1 in
      -h|--help|help)                   display_help ;;
      -browser|--browser|browser)       browser ;;
      -ios|--ios|ios)                   ios_device ;;
      -android|--android|android)       android_device ;;
      *)                                display_help ;;
    esac
    shift
  done

  deploy $1
fi

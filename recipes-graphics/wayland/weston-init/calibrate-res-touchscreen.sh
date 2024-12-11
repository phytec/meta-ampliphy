#!/bin/sh

# Function to round a number to 6 decimal places
round_to_6() {
    printf "%.6f" "$1"
}

# Get display resolution
RESOLUTION_FILE="/sys/class/graphics/fb0/virtual_size"

if [[ -f $RESOLUTION_FILE ]]; then
    RESOLUTION=$(cat $RESOLUTION_FILE)
    if [[ $RESOLUTION =~ ([0-9]+),([0-9]+) ]]; then
        WIDTH=${BASH_REMATCH[1]}
        HEIGHT=${BASH_REMATCH[2]}
    else
        echo "Error: Could not parse resolution from $RESOLUTION_FILE."
        exit 1
    fi
else
    echo "Error: Resolution file $RESOLUTION_FILE not found."
    exit 1
fi

echo "Detected touchscreen resolution: ${WIDTH}x${HEIGHT}"

# Run weston-calibrator and parse its output
echo "Please touch crosshair on the touchscreen to complete calibration process"
CALIB_OUTPUT=$(weston-calibrator 2>&1 | grep 'Calibration values')

if [[ -z "$CALIB_OUTPUT" ]]; then
    echo "Error: Could not find calibration values in weston-calibrator output."
    exit 1
fi

echo "Raw output: $CALIB_OUTPUT"

# Extract calibration values
CALIB_VALUES=($(echo "$CALIB_OUTPUT" | grep -oE '[-0-9.]+'))

if [[ ${#CALIB_VALUES[@]} -ne 6 ]]; then
    echo "Error: Unexpected number of calibration values."
    exit 1
fi

# Assign calibration values
A=${CALIB_VALUES[0]}
B=${CALIB_VALUES[1]}
C=${CALIB_VALUES[2]}  # 3rd value
D=${CALIB_VALUES[3]}
E=${CALIB_VALUES[4]}
F=${CALIB_VALUES[5]}  # 6th value

# Divide 3rd (C) and 6th (F) values by WIDTH and HEIGHT, respectively
C_MODIFIED=$(round_to_6 $(echo "$C / $WIDTH" | bc -l))
F_MODIFIED=$(round_to_6 $(echo "$F / $HEIGHT" | bc -l))

# Write calibration matrix to udev rules file
UDEV_RULES_FILE="/etc/udev/rules.d/res-touchscreen.rules"
CALIB_MATRIX="$A $B $C_MODIFIED $D $E $F_MODIFIED"

echo "Updating calibration matrix in $UDEV_RULES_FILE"

if grep -q 'ENV{LIBINPUT_CALIBRATION_MATRIX}' "$UDEV_RULES_FILE"; then
    sed -i 's|ENV{LIBINPUT_CALIBRATION_MATRIX}="[^"]*"|ENV{LIBINPUT_CALIBRATION_MATRIX}="'"$CALIB_MATRIX"'"|' "$UDEV_RULES_FILE"
else
    echo "Placeholder ENV{LIBINPUT_CALIBRATION_MATRIX} not found in $UDEV_RULES_FILE"
    exit 1
fi

echo "Calibration matrix updated: $CALIB_MATRIX"

# Restart udev to force reload
udevadm control --reload-rules
udevadm trigger

exit 0

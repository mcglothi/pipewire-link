#!/bin/bash

# Define the patterns to match the node names in the output of `pw-link -o` and `pw-link -i`
SOURCE_PATTERN="alsa_input.usb-0c76_USB_PnP_Audio_Device-00.iec958-stereo"
SINK_PATTERN="alsa_output.usb-HiFimeDIY_SA9227_USB_Audio-01.iec958-stereo"

# Function to check and connect ports
check_and_connect_ports() {
    # Use `pw-link -o` to list output ports and grep for the source pattern
    SOURCE_PORTS=$(pw-link -o | grep "$SOURCE_PATTERN")
    # Use `pw-link -i` to list input ports and grep for the sink pattern
    SINK_PORTS=$(pw-link -i | grep "$SINK_PATTERN")

    # Extract the port names for left (FL) and right (FR) channels for both source and sink
    SOURCE_PORT_FL=$(echo "$SOURCE_PORTS" | grep "capture_FL")
    SOURCE_PORT_FR=$(echo "$SOURCE_PORTS" | grep "capture_FR")

    SINK_PORT_FL=$(echo "$SINK_PORTS" | grep "playback_FL")
    SINK_PORT_FR=$(echo "$SINK_PORTS" | grep "playback_FR")

    # Check if we have all necessary ports before proceeding
    if [ -z "$SOURCE_PORT_FL" ] || [ -z "$SOURCE_PORT_FR" ] || [ -z "$SINK_PORT_FL" ] || [ -z "$SINK_PORT_FR" ]; then
        return 1 # Return 1 to indicate failure
    else
        # Connect the left channel
        echo "Connecting left channel:"
        echo "  Source: $SOURCE_PORT_FL"
        echo "  Sink: $SINK_PORT_FL"
        pw-link "$SOURCE_PORT_FL" "$SINK_PORT_FL"

        # Connect the right channel
        echo "Connecting right channel:"
        echo "  Source: $SOURCE_PORT_FR"
        echo "  Sink: $SINK_PORT_FR"
        pw-link "$SOURCE_PORT_FR" "$SINK_PORT_FR"

        echo "Done."
        return 0 # Return 0 to indicate success
    fi
}

# Attempt to check and connect ports with a retry mechanism
RETRY_COUNT=5
RETRY_DELAY=5 # Seconds to wait between retries

for (( attempt=1; attempt<=RETRY_COUNT; attempt++ )); do
    echo "Attempt $attempt of $RETRY_COUNT..."
    if check_and_connect_ports; then
        echo "Successfully established PipeWire link between source and sink."
        exit 0
    else
        echo "Failed to find all necessary ports. Retrying in $RETRY_DELAY seconds..."
        sleep $RETRY_DELAY
    fi
done

echo "Failed to establish PipeWire link after $RETRY_COUNT attempts."
exit 1


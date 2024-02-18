# PipeWire Link Setup

This repository contains a script and a systemd service file designed to automatically establish links between audio sources and sinks using PipeWire on Linux. The script `setup_pipewire_link.sh` automates the connection of specified audio devices, making it easier to manage complex audio routing setups.

## Prerequisites

- PipeWire audio system
- `pw-link` command-line utility
- Basic knowledge of your audio hardware and software configuration

## Installation

1. **Clone the Repository**

    ```bash
    git clone https://github.com/mcglothi/pipewire-link.git
    cd pipewire-link
    ```

2. **Modify the Script (Optional)**

    Before using the script, you may need to modify the `SOURCE_PATTERN` and `SINK_PATTERN` variables in `setup_pipewire_link.sh` to match your audio devices.

    ```bash
    nano setup_pipewire_link.sh
    ```

    Replace `"alsa_input.usb-0c76_USB_PnP_Audio_Device-00.iec958-stereo"` and `"alsa_output.usb-HiFimeDIY_SA9227_USB_Audio-01.iec958-stereo"` with the patterns that match your source and sink devices.

3. **Install the Service**

    Copy `setup_pipewire_link.sh` to a suitable location (e.g., `/usr/local/bin/`) and ensure it is executable:

    ```bash
    sudo cp setup_pipewire_link.sh /usr/local/bin/
    sudo chmod +x /usr/local/bin/setup_pipewire_link.sh
    ```

    Then, install the systemd service file for your user:

    ```bash
    cp pipewire-link.service ~/.config/systemd/user/
    systemctl --user daemon-reload
    systemctl --user enable --now pipewire-link.service
    ```

## Usage

The `pipewire-link.service` will automatically run at login, establishing the specified audio links. You can manually start, stop, or restart the service using systemd:

```bash
systemctl --user start pipewire-link.service
systemctl --user stop pipewire-link.service
systemctl --user restart pipewire-link.service
```

# Customizing the Script
  To adapt the script for your audio devices, you'll need to modify the SOURCE_PATTERN and SINK_PATTERN variables. Use the pw-link -o and pw-link -i commands to list available output and input ports, respectively. Look for the names that correspond to your desired source and sink, and update the script accordingly.

# Troubleshooting
**Service Fails to Start:** 

  If the service fails to start, check the system journal for errors using journalctl --user -u pipewire-link.service. Common issues include incorrect device names or PipeWire not being ready.

**No Audio Link Established:**

  Ensure the patterns in the script accurately match your devices. Use pw-link -o and pw-link -i to verify the device names.

**Script Works Manually but Not at Startup:**

  This might be due to timing issues with device initialization. The script includes a retry mechanism, but you may need to adjust the RETRY_DELAY or RETRY_COUNT if your devices take longer to become available.


# arch-pause-on-audio-dev-disconnect

Pause media when an audio device disconnects on Arch Linux.

## Problem

On Arch Linux, PulseAudio moves the audio to the speakers when headphones disconnect. The media does not stop. This occurs with Bluetooth and wired headphones.

## Solution

A small Python program monitors the PulseAudio sink (audio output) events. A systemd user service starts the program when you log in.

The program pauses all media players with `playerctl` in these conditions:

- A sink is removed. For example, Bluetooth earphones disconnect.
- The active sink port changes from a headphone port to a different port. For example, you unplug wired headphones.

## Requirements

- Arch Linux with PulseAudio (`pulseaudio`, `pulseaudio-bluetooth` for Bluetooth devices)
- `playerctl`
- `python` and `python-pulsectl`
- systemd (user session)

Install the packages:

```sh
sudo pacman -S --needed pulseaudio pulseaudio-bluetooth playerctl python python-pulsectl
```

## Installation

1. Clone the repository.
2. Run the installation script:

   ```sh
   ./install.sh
   ```

The script does these steps:

1. Copies `pa-stop-on-disconnect.sh` to `~/.local/bin/` and makes the file executable.
2. Adds `~/.local/bin` to `PATH` in `~/.bashrc`, if `PATH` does not contain this directory.
3. Copies the service file to `~/.config/systemd/user/`.
4. Enables and starts the service.

## Test

1. Connect your headphones.
2. Start the media.
3. Disconnect the headphones.
4. Make sure that the media pauses.

To see the log, run this command:

```sh
journalctl --user -u pa-stop-on-disconnect -f
```

## Removal

```sh
systemctl --user disable --now pa-stop-on-disconnect.service
rm ~/.local/bin/pa-stop-on-disconnect.sh ~/.config/systemd/user/pa-stop-on-disconnect.service
```

## Limits

- If an application removes a virtual sink, the program also pauses the media.
- Wired detection works only if the port name contains `headphone`. Run `pactl list sinks` to see the port names.
- PipeWire is not tested. `pipewire-pulse` gives a PulseAudio interface, so the program can possibly work.

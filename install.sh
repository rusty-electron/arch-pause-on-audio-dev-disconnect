#!/usr/bin/env bash
# Install the disconnect watcher into ~/.local/bin and enable its systemd user service.
set -euo pipefail
cd "$(dirname "$0")"

bin="$HOME/.local/bin"
unit_dir="$HOME/.config/systemd/user"

for cmd in playerctl python3 systemctl; do
    command -v "$cmd" >/dev/null || { echo "Missing: $cmd" >&2; exit 1; }
done
python3 -c 'import pulsectl' 2>/dev/null || { echo "Missing: python-pulsectl" >&2; exit 1; }

install -Dm755 pa-stop-on-disconnect.sh "$bin/pa-stop-on-disconnect.sh"
install -Dm644 pa-stop-on-disconnect.service "$unit_dir/pa-stop-on-disconnect.service"

case ":$PATH:" in
    *":$bin:"*) ;;
    *)
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo "Added ~/.local/bin to PATH in ~/.bashrc (open a new shell)."
        ;;
esac

systemctl --user daemon-reload
systemctl --user enable --now pa-stop-on-disconnect.service
systemctl --user restart pa-stop-on-disconnect.service
echo "Installed. Logs: journalctl --user -u pa-stop-on-disconnect -f"

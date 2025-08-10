#!/bin/bash
# Toggle current workspace between two monitors in Hyprland

# Get active workspace and monitor
active_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
active_monitor=$(hyprctl activeworkspace -j | jq -r '.monitor')

# Get all monitors
monitors=($(hyprctl monitors -j | jq -r '.[].name'))

# Determine target monitor
if [[ "${active_monitor}" == "${monitors[0]}" ]]; then
  target="${monitors[1]}"
else
  target="${monitors[0]}"
fi

# Move workspace to target monitor
hyprctl dispatch moveworkspacetomonitor "$active_workspace" "$target"

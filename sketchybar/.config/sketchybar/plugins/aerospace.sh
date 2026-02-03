#!/bin/bash

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

# Get the workspace ID from the item name (space.1 -> 1)
WORKSPACE_ID="${NAME#space.}"

# Display label (show 10 as 0)
DISPLAY_LABEL="$WORKSPACE_ID"
[ "$WORKSPACE_ID" = "10" ] && DISPLAY_LABEL="0"

# Get the currently focused workspace from aerospace
FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)

# Get windows in this workspace
WINDOW_LIST=$(aerospace list-windows --workspace "$WORKSPACE_ID" 2>/dev/null)
WINDOW_COUNT=$(echo "$WINDOW_LIST" | grep -c . 2>/dev/null || echo "0")

# Get the app icon for this workspace
if [ "$WINDOW_COUNT" -gt 0 ]; then
    if [ "$WORKSPACE_ID" = "$FOCUSED" ]; then
        # For focused workspace, show the currently focused app's icon
        FOCUSED_APP=$(aerospace list-windows --focused 2>/dev/null | awk -F'|' '{print $2}' | xargs)
        APP_ICON=$("$PLUGIN_DIR/icon_map.sh" "$FOCUSED_APP")
    else
        # For unfocused workspaces, show the first app
        FIRST_APP=$(echo "$WINDOW_LIST" | head -1 | awk -F'|' '{print $2}' | xargs)
        APP_ICON=$("$PLUGIN_DIR/icon_map.sh" "$FIRST_APP")
    fi
else
    APP_ICON="$DISPLAY_LABEL"
fi

if [ "$WORKSPACE_ID" = "$FOCUSED" ] && [ "$WINDOW_COUNT" -gt 0 ]; then
    # Focused workspace with windows - highlighted with app icon
    sketchybar --set "$NAME" \
        icon="$APP_ICON" \
        icon.font="sketchybar-app-font:Regular:16.0" \
        label="$DISPLAY_LABEL" \
        label.drawing=on \
        background.drawing=on \
        icon.highlight=on
elif [ "$WORKSPACE_ID" = "$FOCUSED" ]; then
    # Focused workspace but empty - show number highlighted
    sketchybar --set "$NAME" \
        icon="$DISPLAY_LABEL" \
        icon.font="FiraCode Nerd Font:Bold:14.0" \
        label.drawing=off \
        background.drawing=on \
        icon.highlight=on
elif [ "$WINDOW_COUNT" -gt 0 ]; then
    # Has windows but not focused - show app icon
    sketchybar --set "$NAME" \
        icon="$APP_ICON" \
        icon.font="sketchybar-app-font:Regular:16.0" \
        label="$DISPLAY_LABEL" \
        label.drawing=on \
        background.drawing=on \
        background.color=0x40ffffff \
        icon.highlight=off
else
    # Empty workspace - show number, dimmed but visible
    sketchybar --set "$NAME" \
        icon="$DISPLAY_LABEL" \
        icon.font="FiraCode Nerd Font:Bold:14.0" \
        label.drawing=off \
        background.drawing=on \
        background.color=0x20ffffff \
        icon.highlight=off
fi

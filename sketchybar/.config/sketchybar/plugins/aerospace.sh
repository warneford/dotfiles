#!/bin/bash

PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

# Get the workspace ID from the item name (space.1 -> 1)
WORKSPACE_ID="${NAME#space.}"

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
    APP_ICON="$WORKSPACE_ID"
fi

if [ "$WORKSPACE_ID" = "$FOCUSED" ]; then
    # Focused workspace - highlighted with app icon
    sketchybar --set "$NAME" \
        icon="$APP_ICON" \
        label="$WORKSPACE_ID" \
        label.drawing=on \
        background.drawing=on \
        icon.highlight=on
elif [ "$WINDOW_COUNT" -gt 0 ]; then
    # Has windows but not focused - show app icon
    sketchybar --set "$NAME" \
        icon="$APP_ICON" \
        label="$WORKSPACE_ID" \
        label.drawing=on \
        background.drawing=on \
        background.color=0x40ffffff \
        icon.highlight=off
else
    # Empty workspace - just show number, dimmed
    sketchybar --set "$NAME" \
        icon="$WORKSPACE_ID" \
        label.drawing=off \
        background.drawing=off \
        icon.highlight=off
fi

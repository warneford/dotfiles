#!/usr/bin/env sh

sketchybar --add event aerospace_workspace_change

HIGHLIGHT_COLOR=0xff89b4fa  # Blue for focused workspace (Catppuccin blue)

# Use explicit path in case PLUGIN_DIR isn't set
AEROSPACE_SCRIPT="$HOME/.config/sketchybar/plugins/aerospace.sh"

for sid in $(aerospace list-workspaces --all); do
    sketchybar --add item "space.$sid" left \
        --subscribe "space.$sid" aerospace_workspace_change \
        --set "space.$sid" \
            icon="$sid" \
            icon.font="Hack Nerd Font:Bold:16.0" \
            icon.padding_left=8 \
            icon.padding_right=4 \
            icon.highlight_color=$HIGHLIGHT_COLOR \
            label="$sid" \
            label.font="Hack Nerd Font:Regular:10.0" \
            label.color=0x80ffffff \
            label.padding_left=0 \
            label.padding_right=8 \
            label.drawing=off \
            background.color=0x44ffffff \
            background.corner_radius=5 \
            background.height=30 \
            background.drawing=off \
            click_script="aerospace workspace $sid" \
            script="$AEROSPACE_SCRIPT $sid"
done

sketchybar --add item separator left \
           --set separator \
               icon= \
               icon.font="Hack Nerd Font:Regular:16.0" \
               background.padding_left=15 \
               background.padding_right=15 \
               label.drawing=off \
               associated_display=active \
               icon.color=$WHITE

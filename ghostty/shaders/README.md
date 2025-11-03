# Ghostty Shaders

Collection of custom shaders for Ghostty terminal effects.

## Currently Installed Shaders

### glow-rgbsplit-twitchy.glsl (ACTIVE)
Combines chromatic aberration (RGB split) with a glow effect. Creates a retro, glitchy aesthetic.
- RGB color separation that pulses over time
- Bloom/glow effect on bright text
- Perceptual color space processing
- Very cool cyberpunk/retro vibe

### cursor_blaze.glsl
Creates a glowing trail effect when the cursor moves. Perfect for making the cursor highly visible!
- Yellow/orange glow trail
- Follows cursor movement
- Configurable duration and opacity

### matrix-hallway.glsl
Matrix-style visual effect
- Creates a Matrix movie aesthetic

### inside-the-matrix.glsl
Advanced Matrix effect with more complex animations
- More elaborate Matrix-style visuals

### bloom.glsl
Simple bloom/glow effect that makes bright text glow.
- Clean and subtle
- Good for general use

## Usage

To change shaders, edit `~/dotfiles/ghostty/config` and modify this line:

```
custom-shader = shaders/cursor_blaze.glsl
```

Replace with any of the shader filenames above.

## More Shaders

For more shader options, check out:
- https://github.com/0xhckr/ghostty-shaders (34+ shaders)
- https://github.com/KroneCorylus/ghostty-shader-playground (interactive playground)

## Installing New Shaders

1. Copy shader file to `~/dotfiles/ghostty/shaders/`
2. Update the `custom-shader` line in `config`
3. Restart Ghostty or reload config

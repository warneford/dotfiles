# Terminal Reference

## Kitty Graphics Protocol

### Ghostty vs Kitty Support

Ghostty supports the Kitty graphics protocol for **static images**, but **animation frames are not supported**.

The Kitty graphics protocol has a separate animation extension using `a=f` (frame data) and `a=a` (animation control) modes. Ghostty has not implemented this part of the protocol.

**Practical implications:**
- `kitten icat image.png` → works in both Kitty and Ghostty
- `kitten icat animation.gif` → only animates in Kitty; shows static frame in Ghostty

**Sources:**
- [Ghostty Discussion #5218 - Terminal Graphics Protocol issues](https://github.com/ghostty-org/ghostty/discussions/5218)
- [Ghostty Discussion #5350 - Enhanced Kitty Graphics Protocol](https://github.com/ghostty-org/ghostty/discussions/5350)
- [Kitty Graphics Protocol Documentation](https://sw.kovidgoyal.net/kitty/graphics-protocol/)

### kitten icat Usage

```bash
# Display image (static or animated in Kitty)
kitten icat image.gif

# Loop forever
kitten icat --loop=-1 image.gif

# Show only first frame
kitten icat --loop=0 image.gif

# Display from URL
kitten icat https://example.com/image.gif
```

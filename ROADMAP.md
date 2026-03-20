# Dotfiles Roadmap

## R Environment

- [ ] Auto-patch renv `.Rprofile` to source global `~/.Rprofile` — `renv::init()` creates a local `.Rprofile` that overrides the global one, which breaks gargle auth and other global R config. Options: wrapper function in `~/.Rprofile`, post-init hook, or use `.Rprofile.site` for global config instead.

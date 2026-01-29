# R.nvim Issue 492 - Troubleshooting Context for Linux

## Issue Summary

R.nvim issue [#492](https://github.com/R-nvim/R.nvim/issues/492): `rnvimserver` crashes with a segfault (signal 11) on startup. The root cause was a use-after-free bug in `data_structures.c` in the `finish_updating_loaded_libs` / `load_cached_data` functions. The `start_libs` branch (now merged to `main`) added a newline character check and other fixes. The current `main` HEAD is commit `d4d00a8`.

**Status:** Fixed on macOS (Apple Silicon, R 4.5.2), still crashes on Linux (Docker/Ubuntu).

## Working macOS Environment

- **R.nvim commit:** `d4d00a8936a345f90a510669e36a428f6452990d` (main HEAD, 2026-01-29)
- **Neovim:** v0.11.5 (LuaJIT 2.1.1767980792)
- **R:** 4.5.2 (aarch64-apple-darwin20)
- **OS:** macOS Darwin 25.2.0 (Apple Silicon M2, arm64)
- **R console:** radian (via `radian-direnv` wrapper)
- **R.nvim config:** No commit pin, tracking `main` branch via lazy.nvim
- **R.nvim built-in LSP:** Disabled (using r_language_server from Mason instead)

## Symptoms on Linux (from issue thread)

1. Opening a quarto/R file and starting R produces: `Client r_ls quit with exit code 0 and signal 11`
2. R console shows: `Connection with R.nvim was lost`
3. No `rnvimserver` process running, nothing listening on `RNVIM_PORT`
4. `lsp.log` may show cache file not found errors like:
   ```
   Cache file '/home/bgc/.cache/R.nvim/objls_fields_17.1' not found
   ```

## Root Cause (from Valgrind analysis)

The Valgrind log from the original report showed use-after-free errors in `data_structures.c`:

- **Invalid read** at `finish_updating_loaded_libs` (line 347) - reading 1 byte past allocated block
- **Invalid write** at `finish_updating_loaded_libs` (line 349) - writing into freed `closedir` memory
- **Invalid reads** in `strcmp` called from `get_pkg` (line 85) - comparing against freed directory buffer memory

The memory was freed by `closedir()` in `load_cached_data` (line 318), but pointers into that buffer were still being used. The `start_libs` branch fix added a newline character check and removed library version numbers from collected data.

## Troubleshooting Steps for Linux

### 1. Confirm R.nvim is at latest main

```vim
:lua print(require("r.config").config_dir)
```

Check lazy-lock.json for:
```json
"R.nvim": { "branch": "main", "commit": "d4d00a8936a345f90a510669e36a428f6452990d" }
```

If not current, run `:Lazy update R.nvim`.

### 2. Force nvimcom recompilation

The C code in `rnvimserver` needs to be recompiled after updating R.nvim:

```sh
echo "remove.packages('nvimcom')" | R --no-save
```

Then reopen neovim and an R file - nvimcom will be rebuilt automatically.

### 3. Clear R.nvim cache

Stale cache files may trigger the bug. Clear them:

```sh
rm -rf ~/.cache/R.nvim/
```

### 4. Check rnvimserver binary architecture

Ensure the compiled binary matches your platform:

```sh
file ~/.local/share/nvim/lazy/R.nvim/nvimcom/src/apps/rnvimserver
```

If it shows the wrong architecture or is missing, nvimcom needs recompilation.

### 5. Run with Valgrind (if crash persists)

Edit `~/.local/share/nvim/lazy/R.nvim/lua/r/lsp/init.lua` around line 662-668:

```lua
-- Replace:
-- cmd = { rns_path },
-- With:
cmd = {
    "valgrind",
    "--leak-check=full",
    "--log-file=/tmp/rnvimserver_valgrind_log",
    rns_path,
},
```

Edit `~/.local/share/nvim/lazy/R.nvim/nvimcom/src/apps/Makefile` line 2:

```makefile
CFLAGS = -pthread -g -O0 -Wall
```

Then remove and recompile nvimcom:

```sh
echo "remove.packages('nvimcom')" | R --no-save
```

Check the log:
```sh
tail -f /tmp/rnvimserver_valgrind_log
```

### 6. Enable rnvimserver logging

Add to `~/.Rprofile`:
```r
options(nvimcom.verbose = 2)
```

Then monitor:
```sh
tail -f /dev/shm/rnvimserver_log
```

### 7. Check loaded library info

After R starts (if it doesn't crash), run in neovim:
```vim
:RGetNRSInfo
```

### 8. Environment differences to investigate

Things that differ between macOS (working) and Linux (crashing):

- **Compiler/libc:** macOS uses clang + Apple's libc; Linux uses gcc + glibc. The use-after-free bug may manifest differently depending on memory allocator behavior.
- **R package library paths:** Different installed packages or library locations may produce different-length strings that trigger the buffer overflow.
- **Number of installed R packages:** More packages = more entries to process = more iterations through the buggy code path.
- **Filesystem:** Case sensitivity and directory entry ordering differ between macOS (HFS+/APFS) and Linux (ext4/etc.), which affects `readdir()` behavior in `load_cached_data`.
- **Docker-specific:** If running in Docker, check that `/dev/shm` is available and has adequate size. Also check that the R library path is accessible.

### 9. Key source files to examine

All paths relative to the R.nvim plugin directory (`~/.local/share/nvim/lazy/R.nvim/`):

- `nvimcom/src/apps/data_structures.c` - Contains `finish_updating_loaded_libs`, `load_cached_data`, `get_pkg` (where the bug lives)
- `nvimcom/src/apps/rnvimserver.c` - Main server loop, `handle_exe_cmd`
- `nvimcom/src/apps/tcp.c` - TCP message handling, `ParseMsg`, `receive_msg`
- `lua/r/lsp/init.lua` - LSP client setup (where Valgrind wrapper goes)
- `nvimcom/src/apps/Makefile` - Build flags

### 10. Another reporter's environment

User `typhooncamel` also reports the crash on the latest `main` on Linux, suggesting the fix in `start_libs` did not fully resolve the issue on Linux. Their symptoms match: `r_ls quit with exit code 0`, followed by `Connection with R.nvim was lost`.

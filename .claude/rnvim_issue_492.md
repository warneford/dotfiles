# R.nvim Issue 492 - Troubleshooting Context

## Issue Summary

R.nvim issue [#492](https://github.com/R-nvim/R.nvim/issues/492): `rnvimserver` crashes with a segfault (signal 11) on startup. The `start_libs` branch (now merged to `main` as commit `3e08252`) changed delimiters and added a newline check, but **did not fix the underlying race condition**. The current `main` HEAD is commit `d4d00a8`.

**Status:** Still crashes on Linux (Docker/Ubuntu) after the `start_libs` merge. macOS needs Valgrind testing to confirm.

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

## Root Cause: Thread-Safety Race Condition

### Original report (pre-fix, v0.99.2)

The original Valgrind log showed use-after-free from `closedir()` in `load_cached_data` (line 318) — pointers into the directory buffer were used after `closedir()` freed it.

### Fresh Valgrind (post-fix, main HEAD `d4d00a8`, 2026-01-29)

After the `start_libs` merge, a **different use-after-free pattern** appears — a **race condition between threads**:

- **TCP thread** (`receive_msg` → `ParseMsg` → `update_loaded_libs` at line 388) calls `free(lib_names)` at line 371 and `malloc`s a new buffer at line 372
- **Main thread** (`handle_exe_cmd` → `finish_updating_loaded_libs` at line 327) iterates over `lib_names` at lines 341-355, reading pointer `p` which points into the now-freed buffer
- The free at `data_structures.c:371` races with reads at `:344` and write at `:346`
- The freed block (195 bytes) was allocated by `calloc` at `finish_updating_loaded_libs:338` and freed at `:365`
- **2,704,189 errors** from 11 contexts before final SIGSEGV
- SIGSEGV at `data_structures.c:344` — "Bad permissions for mapped region"

### Key code (data_structures.c lines 327-389)

```c
// MAIN THREAD - iterates lib_names
void finish_updating_loaded_libs(int has_new_lib) {
    // ...
    char *msg = calloc(128 + strlen(lib_names), sizeof(char));  // line 338
    char *p = lib_names;                                         // line 341
    while (*p && *p != '#' && *p != '\n') {                      // line 342
        while (*p != ',' && *p != '#')                           // line 344 ← SIGSEGV here
            p++;
        *p = 0;                                                  // line 346 ← invalid write
        // ...
    }
    free(msg);                                                   // line 365
}

// TCP THREAD - frees and replaces lib_names
void update_loaded_libs(char *libnms) {
    if (lib_names)
        free(lib_names);                                         // line 371 ← frees while main thread reads
    lib_names = malloc(sizeof(char) * strlen(libnms) + 1);       // line 372
    strcpy(lib_names, libnms);                                   // line 373
    // ...
    finish_updating_loaded_libs(0);                              // line 388
}
```

The `start_libs` fix only changed delimiters (`\003`→`,`, `\004`→`#`) and added `\n` checks. It did not add any synchronization (mutex/lock) to protect concurrent access to `lib_names`.

## Linux Valgrind Log (post-fix, 2026-01-29)

```
==2701189== Memcheck, a memory error detector
==2701189== Command: rnvimserver
==2701189==
==2701189== Invalid read of size 1
==2701189==    at 0x1100F8: finish_updating_loaded_libs (data_structures.c:344)
==2701189==    by 0x111439: handle_exe_cmd (rnvimserver.c:327)
==2701189==    by 0x111AC9: lsp_loop (rnvimserver.c:471)
==2701189==    by 0x111CCC: main (rnvimserver.c:505)
==2701189==  Address 0x617b154 is 0 bytes after a block of size 68 alloc'd
==2701189==    at 0x4846828: malloc
==2701189==    by 0x110239: update_loaded_libs (data_structures.c:372)
==2701189==    by 0x112DD2: ParseMsg (tcp.c:71)
==2701189==    by 0x1135EF: get_whole_msg (tcp.c:305)
==2701189==    by 0x113691: receive_msg (tcp.c:325)
==2701189==    by 0x48FEAA3: start_thread (pthread_create.c:447)
==2701189==
==2701189== Invalid write of size 1
==2701189==    at 0x11010E: finish_updating_loaded_libs (data_structures.c:346)
==2701189==    by 0x111439: handle_exe_cmd (rnvimserver.c:327)
==2701189==  Address 0x617b1cc is 44 bytes inside a block of size 195 free'd
==2701189==    at 0x484988F: free
==2701189==    by 0x1101D8: finish_updating_loaded_libs (data_structures.c:365)
==2701189==    by 0x1102DC: update_loaded_libs (data_structures.c:388)
==2701189==  Block was alloc'd at
==2701189==    at 0x484D953: calloc
==2701189==    by 0x1100AE: finish_updating_loaded_libs (data_structures.c:338)
==2701189==    by 0x1102DC: update_loaded_libs (data_structures.c:388)
==2701189==
==2701189== Invalid read of size 1
==2701189==    at 0x4850367: strcmp
==2701189==    by 0x10F53E: get_pkg (data_structures.c:84)
==2701189==    by 0x110121: finish_updating_loaded_libs (data_structures.c:348)
==2701189==  Address 0x617b1cd is 45 bytes inside a block of size 195 free'd (same block)
==2701189==
==2701189== Process terminating with default action of signal 11 (SIGSEGV): dumping core
==2701189==  Bad permissions for mapped region at address 0x6277000
==2701189==    at 0x1100F8: finish_updating_loaded_libs (data_structures.c:344)
==2701189==
==2701189== ERROR SUMMARY: 2704189 errors from 11 contexts (suppressed: 0 from 0)
```

## macOS Valgrind Log (TODO)

Run the same Valgrind setup on macOS to compare. macOS may not crash because:
- Different memory allocator (libmalloc vs glibc malloc) — freed pages may remain readable longer
- Different thread scheduling — the race window may be smaller on Apple Silicon
- Fewer installed R packages — fewer iterations through the buggy loop

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

## Reproducing Valgrind on macOS

### Prerequisites

Install Valgrind on macOS (may require building from source on Apple Silicon):
```sh
brew install valgrind
```

> **Note:** Valgrind support on macOS/ARM is limited. If Valgrind doesn't work, consider using AddressSanitizer instead — change the Makefile to:
> ```makefile
> CFLAGS = -pthread -g -O0 -Wall -fsanitize=address
> ```
> and set `ASAN_OPTIONS=detect_leaks=1` in the environment. The LSP init.lua does NOT need the Valgrind wrapper with ASan — just use `cmd = { rns_path }` as normal. ASan output goes to stderr which will appear in `lsp.log`.

### Steps

1. Edit `~/.local/share/nvim/lazy/R.nvim/nvimcom/src/apps/Makefile`:
   ```makefile
   CFLAGS = -pthread -g -O0 -Wall
   ```

2. Edit `~/.local/share/nvim/lazy/R.nvim/lua/r/lsp/init.lua` (~line 662):
   ```lua
   -- cmd = { rns_path },
   cmd = {
       "valgrind",
       "--leak-check=full",
       "--log-file=/tmp/rnvimserver_valgrind_log",
       rns_path,
   },
   ```

3. Remove and recompile nvimcom:
   ```sh
   echo "remove.packages('nvimcom')" | R --no-save
   ```

4. Restart Neovim, open an R file, start R

5. Check the log:
   ```sh
   cat /tmp/rnvimserver_valgrind_log
   ```

6. Compare with the Linux log above — look for the same race condition pattern (TCP thread freeing `lib_names` while main thread iterates it)

### What to report

- Whether macOS shows the same invalid read/write errors at `data_structures.c:344/346`
- Whether it actually crashes (SIGSEGV) or survives despite the errors
- Error count comparison (Linux had 2.7M errors)
- If using ASan instead of Valgrind, paste the ASan report

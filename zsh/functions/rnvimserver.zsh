# Auto-cleanup orphaned rnvimserver processes on shell startup
# These can get stuck using 100% CPU when nvim exits unexpectedly
() {
    local pids=$(pgrep -x rnvimserver 2>/dev/null)
    [[ -z "$pids" ]] && return

    for pid in ${(f)pids}; do
        # Kill only if TCP connection is CLOSED or CLOSE_WAIT (orphaned)
        if lsof -p "$pid" 2>/dev/null | grep -qE 'TCP.*(CLOSED|CLOSE_WAIT)'; then
            kill -9 "$pid" 2>/dev/null
        fi
    done
}

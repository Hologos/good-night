#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
    >&2 echo "Please, run this command as super-user."
    exit 1
fi

if [[ $# -ne 1 ]]; then
    >&2 echo "Pass number of minutes before shutting down."
    >&2 echo 
    >&2 echo "E.g: $0 <minutes-before-shutdown>"
    exit 1
fi

function write_line()
{
    message="$1"
    line_break="$2"

    echo -ne "\033[2K"
    echo -ne "\r$message"

    if [[ "$line_break" -eq 1 ]]; then
        echo
    fi
}

cycle_timeout=5
countdown="$(($1 * 60))"

while true; do
    if [[ "$countdown" -le 0 ]]; then
        write_line "SHUTDOWN!" 1
        break
    fi

    write_line "System is gonna be shut down in $countdown seconds."

    sleep "$cycle_timeout"
    countdown="$(($countdown - $cycle_timeout))"
done

shutdown -h now

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

control_c()
{
    stty sane
}

trap control_c SIGINT

cycle_timeout=5
extra_time=15
countdown="$(($1 * 60))"

# non-blocking stty
stty -icanon time 0 min 0

while true; do
    read key_pressed

    if [[ "$countdown" -le 0 ]]; then
        write_line "SHUTDOWN!" 1
        break
    fi

    if [[ "$key_pressed" != "" ]]; then
        countdown="$(($countdown + $extra_time * 60))"
        write_line "Adding extra $extra_time minutes." 1
    fi

    write_line "System is gonna be shut down in $countdown seconds."

    sleep "$cycle_timeout"
    countdown="$(($countdown - $cycle_timeout))"
    key_pressed=""
done

# set the stty back to normal
stty sane

shutdown -h now

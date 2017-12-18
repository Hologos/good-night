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

function gen_time_message_part()
{
    minutes="$1"
    seconds="$2"

    message=""

    if [[ "$minutes" -gt 0 ]]; then
        units="minutes"

        if [[ "$minutes" -eq 1 ]]; then
            units="minute"
        fi

        message="${message} ${minutes} ${units}"
    fi

    if [[ "$seconds" -gt 0 ]]; then
        units="seconds"

        if [[ "$seconds" -eq 1 ]]; then
            units="second"
        fi

        message="${message} ${seconds} ${units}"
    fi

    echo -n "$message"
}

ALERT_SHUTDOWN="alert-shutdown"

function voice_alert()
{
    alert="$1"

    case "$alert" in
        "$ALERT_SHUTDOWN")
            say "*"
        ;;
    esac
}

control_c()
{
    stty sane
    echo
    exit 1
}

trap control_c SIGINT

extra_time=15
countdown="$(($1 * 60))"

# non-blocking stty
stty -icanon time 0 min 0

while true; do
    read key_pressed

    if [[ "$countdown" -eq 300 ]] || [[ "$countdown" -eq 150 ]]; then
        voice_alert "$ALERT_SHUTDOWN"
    fi

    if [[ "$countdown" -le 0 ]]; then
        write_line "SHUTDOWN!" 1
        break
    fi

    if [[ "$key_pressed" != "" ]]; then
        countdown="$(($countdown + $extra_time * 60))"
        write_line "Adding extra $extra_time minutes." 1
    fi

    minutes="$(($countdown / 60))"
    seconds="$(($countdown % 60))"
    time_message_part="$(gen_time_message_part "$minutes" "$seconds")"

    write_line "System is gonna be shut down in${time_message_part}."

    sleep 1
    countdown="$(($countdown - 1))"
    key_pressed=""
done

# set the stty back to normal
stty sane

shutdown -h now

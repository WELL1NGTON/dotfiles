#!/bin/zsh

: "${ARCHNEWS_DAYS:=7}"
: "${ARCHNEWS_CACHE:=$HOME/.cache/archlinux-news}"
: "${ARCHNEWS_CACHE_LIFETIME:=86400}"
: "${ARCHNEWS_SHORT:=$ARCHNEWS_CACHE/archnews_short.txt}"
: "${ARCHNEWS_FULL:=$ARCHNEWS_CACHE/archnews_full.txt}"

function is_file_outdated(){
    local file_path=$1
    local file_lifetime=$2
    local now=$(date +%s)
    local last_update=$(stat -c %Y $file_path)
    local diff=$((now - last_update))
    if [ $diff -gt $file_lifetime ]; then
        return 0
    else
        return 1
    fi
}

function update_archnews() {
    local file_path=$1
    local full_data=${2:-false}
    mkdir -p $ARCHNEWS_CACHE
    local arg_exec=Pww
    if [ $full_data = true ]; then
        arg_exec="${arg_exec}c"
    else
        arg_exec="${arg_exec}q"
    fi
    local tmp_file=$(mktemp)
    if yay -$arg_exec > $tmp_file && [ -s $tmp_file ]; then
        mv $tmp_file $file_path
    else
        echo "Failed to update archnews: yay command failed or output is empty."
        rm -f $tmp_file
        return 1
    fi
}

function print_archnews() {
    if [[ ! -f $ARCHNEWS_SHORT ]]; then
        return 1
    fi
    local days_check=${1:-$ARCHNEWS_DAYS}
    local base_date=$(date -d "$(date +%Y-%m-%d) - $days_check days" +%Y-%m-%d)
    local base_date_seconds=$(date -d $base_date +%s)
    local arr=()
    while read line; do
        local news_date="$(echo $line | cut -d ' ' -f 1)"
        if [ $(date -d $news_date +%s) -ge $base_date_seconds ]; then
            arr+=($line)
        fi
    done <$ARCHNEWS_SHORT
    if [ ${#arr[@]} -gt 0 ]; then
        echo ""
        local green="\033[0;32m"
        local no_color="\033[0m"
        echo -e "${green}Arch Linux News from the last $days_check days:${no_color}"
        for i in "${arr[@]}"; do
            echo $i
        done
    fi
}

function print_archnews_complete() {
    if [[ ! -f $ARCHNEWS_FULL ]]; then
        return 1
    fi
    local days_check=${1:-$ARCHNEWS_DAYS}
    local base_date=$(date -d "$(date +%Y-%m-%d) - $days_check days" +%Y-%m-%d)
    local base_date_seconds=$(date -d $base_date +%s)
    local print_line=false
    local count=0
    while read line; do
        local is_title=false
        if [ ! -z "$line" -a "$line" != " " ]; then
            local news_date=$(echo $line | cut -d " " --field 1)
            if [[ $news_date =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}" ]]; then
                if [ $(date -d $news_date +%s) -ge $base_date_seconds ]; then
                    is_title=true
                    print_line=true
                fi
            fi
        fi
        if $print_line; then
            ((count=count+1))
            local bold=$(tput bold)
            local green="\033[0;32m"
            local no_color="\033[0m"
            if $is_title; then
                echo -e "${green}${bold}$line${no_color}"
            else
                echo "$line"
            fi
        fi
    done<$ARCHNEWS_FULL
    if [ $count -eq 0 ]; then
        echo "No recent news ($days_check days)"
    fi
    echo ""
    echo "For more information visit: https://archlinux.org"
}

function update_all_archnews() {
    local archnews_cache_dir="/home/wellington/.cache/archlinux-news/"
    local was_short_updated=false
    local delay_seconds=60
    if [[ ! -f $ARCHNEWS_SHORT ]] || is_file_outdated $ARCHNEWS_SHORT $ARCHNEWS_CACHE_LIFETIME; then
        touch $ARCHNEWS_SHORT # update timestamp so other terminals don't try to update it
        update_archnews $ARCHNEWS_SHORT false
        was_short_updated=true
    fi
    if [[ ! -f $ARCHNEWS_FULL ]] || is_file_outdated $ARCHNEWS_FULL $ARCHNEWS_CACHE_LIFETIME; then
        if $was_short_updated; then
            sleep $delay_seconds
        fi
        touch $ARCHNEWS_FULL # update timestamp so other terminals don't try to update it
        update_archnews $ARCHNEWS_FULL true
    fi
}

if [ ! -d "${ARCHNEWS_CACHE}" ]; then
    echo "${ARCHNEWS_CACHE}/ directory does not exist. Creating it now..."
    mkdir -p ${ARCHNEWS_CACHE}
fi

if command -v yay &> /dev/null; then
    if [[ -z ${_ARCHNEWS_UPDATER_SPAWNED:-} ]]; then
        export _ARCHNEWS_UPDATER_SPAWNED=1
        nohup zsh -c 'source ~/.config/zsh/arch-scripts.zsh; update_all_archnews' >/dev/null 2>&1 &!
    fi
    print_archnews
fi

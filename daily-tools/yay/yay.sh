#!/usr/bin/env bash

# set -xeu


declare -A repos
repos['backend']='git@git.xkool.org:xkool/backend.git'
repos['algorithm']='git@git.xkool.org:xkool/algorithm.git'
repos['test']='git@git.xkool.org:xkool/nothing.git'
repos['frontend']='git@git.xkool.org:xkool/frontend.git'
repos['new_task_center']='git@git.xkool.org:xkool/new_task_center.git'
repos['frontend']='git@git.xkool.org:xkool/frontend.git'


function clone() {
    local dir="${1-.}"
    mkdir -p "${dir}"

    cd "$dir" || exit
    for repo in "${!repos[@]}"; do
        if git clone "${repos[${repo}]}" \
            "$repo" --recurse-submodules > /dev/null 2>&1; then
            echo "[$repo] done"
        else
            echo "[$repo] fail"
        fi
    done
}


function clean() {
    local dir=${1-.}
    cd "$dir" || exit

    for repo in "${!repos[@]}"; do
        if rm -rf "$repo"; then
            echo "[$repo] done"
        else
            echo "[$repo] fail"
        fi
    done
}


function checkout() { # abbreivation for shortcut
    local branch=${1-""}
    [ -z "$branch" ] && exit

    local dir=${2-.}
    cd "$dir" || exit

    for repo in "${!repos[@]}"; do (
        cd "$repo" > /dev/null 2>&1 || exit
        if [ -d '.git' ]; then
            if git checkout "$branch" -f > /dev/null 2>&1; then
                echo "[$repo] done"
            else
                echo "[$repo] fail"
            fi

            if [ -f '.gitmodules' ]; then
                sed -n '/path/p' '.gitmodules' \
                | cut -d ' ' -f 3 \
                | while read -r submodule; do (
                    cd "$submodule" > /dev/null 2>&1 || exit
                    if git checkout "$branch" -f > /dev/null 2>&1; then
                        echo "-[$submodule] done"
                    else
                        echo "-[$submodule] fail"
                    fi
                    )
                done
            fi
        fi
    )
    done
}


# function solar_repo_handler() {

# }


# function new_repo_handler() {

# }


# function xkconfig_repo_handler() {

# }

function frontend_repo_handler() {
    port=$(($1 + 4200))
    if sed -n "/start:local_backend/p" package.json | grep -q "port"; then
        echo "Port ${port} has been set."        
    else
        sed -i -e "/start:local_backend/s/\",$/ --port ${port}\",/" package.json      
    fi
}


# function port() {
#     local port_offset=${1-0}

#     local dir=${2-.}
#     cd "$dir" || exit

#     for repo in "${!repos[@]}"; do (
#         cd "$repo" > /dev/null 2>&1 || exit
#         case $repo in
#             solar)
#                 solar_repo_handler "$port_offset"
#                 ;;
#             new_task_center)
#                 new_task_center_repo_handler "$port_offset"
#                 ;;
#             xkconfig)
#                 xkconfig_repo_handler "$port_offset"
#                 ;;
#             frontend)
#                 frontend_repo_handler "$port_offset"
#             *)
#                 ;;
#         esac
#     )
#     done
# }


function main() {
    case "$1" in
        clone)
            shift
            clone "$@"
            ;;
        clean)
            shift
            clean "$@"
            ;;
        co)
            shift
            checkout "$@"
            ;;
        *)
            echo 'Unknown command'
    esac
}

main "$@"

#!/usr/bin/env bash

# set -xeu


declare -A repos
repos["light_exchange"]="git@git.xkool.org:chun/light_exchange.git"
repos["frontend"]="git@git.xkool.org:xkool/frontend.git"
repos["backend"]="git@git.xkool.org:xkool/backend.git"
repos["algorithm"]="git@git.xkool.org:xkool/algorithm.git"
repos["xkconfig"]="git@git.xkool.org:xkool/xkconfig.git"
repos["ppt_service"]="git@git.xkool.org:xkool/ppt_service.git"
repos["new_algorithm_residence"]="git@git.xkool.org:xkool/new_algorithm_residence.git"
repos["new_algorithm_point_candidate"]="git@git.xkool.org:xkool/new_algorithm_point_candidate.git"
repos["new_algorithm_measure"]="git@git.xkool.org:xkool/new_algorithm_measure.git"
repos["solar_algorithm"]="git@git.xkool.org:xkool/solar_algorithm.git"
repos["cad_processor"]="git@git.xkool.org:xkool/cad_processor.git"
repos["shapely_extension"]="git@git.xkool.org:weilong/shapely_extension.git"
repos["new_task_center"]="git@git.xkool.org:xkool/new_task_center.git"
repos["xkadmin"]="git@git.xkool.org:xkool/xkadmin.git"
repos["new_xkadmin"]="git@git.xkool.org:xkool/new_xkadmin.git"
repos["xk_monitor_backend"]="git@git.xkool.org:xkool/xk_monitor_backend.git"
repos["shapely_extension"]="git@git.xkool.org:weilong/shapely_extension.git"


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

function pull(){
    local branch=${1-""}
    local remote_repo="origin"
    [ -z "$branch" ] && exit

    local dir=${2-.}
    cd "$dir" || exit

    for repo in "${!repos[@]}"; do (
        cd "$repo" > /dev/null 2>&1 || exit
        
        if [ -d '.git' ]; then
            if git pull "$remote_repo" "$branch"; then
                echo "[$repo] done"
            else
                echo "[$repo] fail"
            fi
            if [ -f '.gitmodules' ]; then
                sed  -n '/path/p' '.gitmoduels' \
                | cut -d ' ' -f 3 \
                | while read -r submodule; do (
                    cd "$submodule" > /dev/null 2>&1 || exit
                    if git pull "$remote_repo" "$branch"; then
                        echo "[$repo] done"
                    else
                        echo "[$repo] fail"
                    fi         
                )
                done
            fi
        fi
    )
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

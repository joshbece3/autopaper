#!/bin/bash

# launch
run() {
    local dir=$1
    local jar=$2
    local ram=$3

    echo "launching: $dir ($ram GB)"
    cd "$dir" || exit 1

    java -Xmx"${ram}G" \
    -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
    -jar "$jar" nogui
}

# input
read -p "ram (gb): " memory

# choice
while true; do
    read -p "server (paper/fabric): " type

    case $type in
        paper)
            # folder
            if [ -d "minecraft_server" ]; then
                run "minecraft_server" "paper.jar" "$memory"
            else
                echo "missing: minecraft_server"
            fi
            break ;;

        fabric)
            # folder
            if [ -d "fabric_server" ]; then
                run "fabric_server" "fabric-server.jar" "$memory"
            else
                echo "missing: fabric_server"
            fi
            break ;;

        *)
            echo "pick paper or fabric" ;;
    esac
done

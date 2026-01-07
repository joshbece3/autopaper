#!/bin/bash
#input
read -p "key:" key
#setup
dir="fabric_server/config"
file="$dir/playit-fabric-config.cfg"
#check
if [[ ! -d "$dir" ]];then
mkdir -p "$dir"
fi
#config
cat <<EOL > "$file"
agent-secret=$key
autostart=true
mc-timeout-seconds=90000
EOL
echo "done:$file"

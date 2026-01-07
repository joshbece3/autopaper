#!/bin/bash
#launch
run(){
local d=$1
local j=$2
local r=$3
echo "booting:$d"
cd "$d"||exit
java -Xmx"${r}G" -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -jar "$j" nogui
}
#input
read -p "ram:" ram
#choice
while true;do
read -p "type:" type
case $type in
paper)
#folder
if [ -d "minecraft_server" ];then
run "minecraft_server" "paper.jar" "$ram"
else
echo "missing folder"
fi
break;;
fabric)
#folder
if [ -d "fabric_server" ];then
run "fabric_server" "fabric-server.jar" "$ram"
else
echo "missing folder"
fi
break;;
*)
echo "invalid";;
esac
done

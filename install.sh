#!/bin/bash

download() {
    local url="$1"
    local name="$2"
    echo "fetching: $name"
    if wget --spider -S "$url" 2>&1 | grep -q "200 OK"; then
        wget -q --show-progress "$url" -O "$name"
    else
        return 1
    fi
}

properties() {
    cat <<EOL > "$1"
difficulty=hard
enforce-secure-profile=$3
gamemode=survival
level-name=world
max-players=20
online-mode=$2
pvp=true
server-port=25565
view-distance=7
EOL
}

ask() {
    local reply
    while true; do
        read -p "$1 " reply
        case "$reply" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
        esac
    done
}

# requirements
if ! command -v java &> /dev/null; then
    exit 1
fi

read -p "type (paper/fabric/forge): " type

case "$type" in
    paper)
        # setup
        mkdir -p paper_server && cd paper_server
        read -p "version: " v
        build=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$v/builds/" | grep -oP '"build":\K\d+' | head -n 1)
        curl -s -o "server.jar" "https://api.papermc.io/v2/projects/paper/versions/$v/builds/$build/downloads/paper-$v-$build.jar"
        
        # plugins
        mkdir -p plugins
        while ask "add plugin?"; do
            read -p "url: " p_url
            download "$p_url" "plugins/$(basename "$p_url")"
        done
        wget -P plugins "https://github.com/playit-cloud/playit-minecraft-plugin/releases/latest/download/playit-minecraft-plugin.jar"
        ;;

    fabric)
        # setup
        mkdir -p fabric_server && cd fabric_server
        read -p "version: " v
        loader=$(curl -s "https://meta.fabricmc.net/v2/versions/loader" | jq -r '.[0].version')
        installer=$(curl -s "https://meta.fabricmc.net/v2/versions/installer" | jq -r '.[0].version')
        curl -s -o "server.jar" "https://meta.fabricmc.net/v2/versions/loader/$v/$loader/$installer/server/jar"
        ;;

    forge)
        # setup
        mkdir -p forge_server && cd forge_server
        read -p "version: " v
        f_ver=$(curl -s "https://files.minecraftforge.net/net/minecraftforge/forge/promotions_slim.json" | jq -r ".promos[\"$v-recommended\"]")
        curl -s -o "installer.jar" "https://maven.minecraftforge.net/net/minecraftforge/forge/$v-$f_ver/forge-$v-$f_ver-installer.jar"
        java -jar installer.jar --installServer && rm installer.jar
        
        # mods
        mkdir -p mods
        while ask "add mod?"; do
            read -p "url: " m_url
            download "$m_url" "mods/$(basename "$m_url")"
        done
        ;;
esac

# config
if ask "cracked?"; then
    online="false"; secure="false"
else
    online="true"; secure="true"
fi

echo "eula=true" > eula.txt
properties "server.properties" "$online" "$secure"

# launch
jar_file=$(ls *.jar | grep -v "installer" | head -n 1)
cat > start.sh << EOF
#!/bin/bash
java -Xmx8G -jar $jar_file nogui
EOF
chmod +x start.sh
./start.sh

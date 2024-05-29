#!/bin/bash

# Function to check if a string is a valid IP address
is_ip() {
    local ip="$1"
    # Check if the input matches the format of an IP address
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0  # It is an IP address
    else
        return 1  # It is not an IP address
    fi
}

# Function to get IP address from DDNS or return the input if it is already an IP address
get_ip_from_ddns() {
    local ddns_name="$1"
    local ip

    if is_ip "$ddns_name"; then
        ip="$ddns_name"
    else
        # Use nslookup to get the IP address
        ip=$(nslookup "$ddns_name" | awk '/^Address: / { print $2 }' | tail -n1)
    fi

    if [ -z "$ip" ]; then
        echo "No IP address found for $ddns_name"
        return 1
    else
        echo "IP address for $ddns_name: $ip"
    fi
}

# Function to detect if running on Windows (Git Bash)
is_windows() {
    case "$(uname -s)" in
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

esacoin() {
    local prefix=""
    local ipc_path="/root/.esa/geth.ipc"
    local bash_path="/bin/bash"
    local conv_ip=$(get_ip_from_ddns "$this_ip")
    
    if is_windows; then
        prefix="winpty"
    fi

    convert_path() {
        if is_windows; then
            # Convert /path/to to //path//to
            echo "$1" | sed 's,/,//,g'
        else
            echo "$1"
        fi
    }

    if [ "$1" = "exec" ]; then
        if [ "$2" = "bash" ]; then
            ${prefix} docker exec -it esanode $(convert_path "$bash_path")
        else
            ${prefix} docker exec -it esanode ./build/bin/geth attach ipc:$(convert_path "$ipc_path")
        fi
    elif [ "$1" = "run" ]; then
        if [ "$2" = "gai" ]; then
            docker run --name esanode -d -p 8546:8546 -p 30303:30303 -v ${this_root_path}:/root/.esa -e IP=$conv_ip -e esculapeso/core-geth:latest
        else
            local cmd="docker run --name esanode -d -p 8546:8546 -p 30303:30303 -v ${this_root_path}:/root/.esa -e IP=$conv_ip -e BOOTNODES=$gai_bootnode esculapeso/core-geth:latest"
            echo "Preview: $cmd"
            eval $cmd
        fi
    elif [ "$1" = "stop" ]; then
        if [ "$2" = "only" ]; then
            docker stop esanode
        else
            docker stop esanode
            docker rm esanode
        fi
    fi
}

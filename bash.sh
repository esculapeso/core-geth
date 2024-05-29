#!/bin/bash

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
            docker run --name esanode -d -p 8546:8546 -p 30303:30303 -v ${this_root_path}:/root/.esa -e IP=$this_ip -e esculapeso/core-geth:latest
        else
            local cmd="docker run --name esanode -d -p 8546:8546 -p 30303:30303 -v ${this_root_path}:/root/.esa -e IP=$this_ip -e BOOTNODES=$gai_bootnode esculapeso/core-geth:latest"
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

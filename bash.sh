esacoin() {
    if [ "$1" = "exec" ]; then
        if [ "$2" = "bash" ]; then
            docker exec -it esanode /bin/bash
        else
            docker exec -it esanode ./build/bin/geth attach ipc:/root/.esa/geth.ipc
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

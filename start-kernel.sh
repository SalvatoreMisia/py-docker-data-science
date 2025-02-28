#!/bin/bash

# detect the host
determine_target_ip() {
    # try to reach host.docker.internal
    if curl -s --connect-timeout 2 host.docker.internal > /dev/null; then
        echo "host.docker.internal"
    else
        echo "localhost"
    fi
}

TARGET_IP=$(determine_target_ip)
TARGET_IP="127.0.0.1" # to overwrite host.docker.internal, which it is no more working

# start the spyder kernel
python -m spyder_kernels.console \
    --ip=0.0.0.0 \
    --shell=8888 \
    --iopub=8889 \
    --stdin=8890 \
    --control=8891 \
    --hb=8892 \
    --IPKernelApp.connection_file=/usr/src/app/kernel/spyder-kernel-connection.json &

# wait for json file to be created
until KERNEL_FILE=$(ls /usr/src/app/kernel/*kernel-*.json 2> /dev/null); do
    sleep 1
done

# update json's IP value
jq --arg ip "$TARGET_IP" '.ip = $ip' "$KERNEL_FILE" > "$KERNEL_FILE.tmp"
mv "$KERNEL_FILE.tmp" "$KERNEL_FILE"

# keep container active
tail -f /dev/null
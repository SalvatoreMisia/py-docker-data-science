#!/bin/bash

# detect the host
if grep -q "host.docker.internal" /etc/hosts; then
    TARGET_IP="host.docker.internal"
else
    TARGET_IP="localhost"
fi

# start the spyder kernel
python -m spyder_kernels.console \
    --ip=0.0.0.0 \
    --shell=8888 \
    --iopub=8889 \
    --stdin=8890 \
    --control=8891 \
    --hb=8892 \
    --IPKernelApp.connection_file=/usr/src/app/spyder-kernel-connection.json &

# wait for json file to be created
until KERNEL_FILE=$(ls /usr/src/app/*kernel-*.json 2> /dev/null); do
    sleep 1
done

# update json's IP value
jq --arg ip "$TARGET_IP" '.ip = $ip' "$KERNEL_FILE" > "$KERNEL_FILE.tmp"
mv "$KERNEL_FILE.tmp" "$KERNEL_FILE"

# keep container active
tail -f /dev/null
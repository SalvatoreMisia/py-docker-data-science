#!/bin/bash

# cleaning old connection files
KERNEL_DIR="${WORK_DIR}/kernel" # previously set env variable WORK_DIR in Dockerfile
echo "Cleaning old connection files in $KERNEL_DIR"
rm -f "$KERNEL_DIR"/*kernel-*.json

# # detect the host
# determine_target_ip() {
#     # try to reach host.docker.internal
#     if curl -s --connect-timeout 2 host.docker.internal > /dev/null; then
#         echo "host.docker.internal"
#     else
#         echo "localhost"
#     fi
# }

# TARGET_IP=$(determine_target_ip) 
# it is no more working, so we put directly 127.0.0.1, which is the docker ip
TARGET_IP="127.0.0.1"

# start the spyder kernel
python -m spyder_kernels.console \
    --ip=0.0.0.0 \
    --shell=8888 \
    --iopub=8889 \
    --stdin=8890 \
    --control=8891 \
    --hb=8892 \
    --IPKernelApp.connection_file="$KERNEL_DIR"/spyder-kernel-connection.json &

# wait for json file to be created
until KERNEL_FILE=$(ls "$KERNEL_DIR"/*kernel-*.json 2> /dev/null); do
    sleep 1
done

# update json's IP value
jq --arg ip "$TARGET_IP" '.ip = $ip' "$KERNEL_FILE" > "$KERNEL_FILE.tmp"
mv "$KERNEL_FILE.tmp" "$KERNEL_FILE"

# keep container active
echo -e "\nKernel is ready on 127.0.0.1"
echo -e '\npy-ds service is running correctly.
If your terminal is stuck, press CTRL+C and use \"docker compose up -d\" 
to launch this service in background (detached mode).'
echo -e '\nThen, to link again to this service use \"docker compose exec py-ds /bin/bash\".'
tail -f /dev/null
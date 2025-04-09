# python slim to reduce image size
FROM python:3.12-slim

# build arguments and environment variables
ARG VERSION="normal" # Default version of the application, options are small, normal, and large
ARG INST_EXTRA=false # Set to true to install additional optional packages
ARG EXTRA_PACKS=requirements-opt.txt # Filename for extra packages, it can be also a string like "numpy pandas"

ARG USERNAME=pyuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV WORK_DIR=/workspace
ENV CURR_USR=$USERNAME

# from this line onward, all commands will be executed in the following directory
WORKDIR $WORK_DIR

# copy needed files into the container
COPY ./requirements/ ./requirements/
COPY start-kernel.sh ./

RUN chmod +x ./start-kernel.sh

# install essential libraries and tools for python development
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    jq \
    curl \
    git \
    wget \
    sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* # to remove unnecessary files and for security reasons

# create and give privileges to the user to run sudo commands
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -ms /bin/bash $USERNAME && \
    mkdir -p /etc/sudoers.d && \
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    chown -R $USERNAME:$USERNAME $WORK_DIR

# upgrade pip
RUN pip install --upgrade pip

# installing requirements
RUN if [ "$VERSION" = "small" ] || [ "$VERSION" = "normal" ] || [ "$VERSION" = "large" ]; then \
        if [ -f "requirements/requirements-${VERSION}.txt" ]; then \
            pip install --no-cache-dir -r "requirements/requirements-${VERSION}.txt"; \
            echo "[${VERSION}] version installed :)"; \
        else \
            echo "[requirements-${VERSION}.txt] file not found in requirements folder."; \
            exit 1; \
        fi; \
    else \
        echo "Invalid --build-arg VERSION specified. Please use 'small', 'normal', or 'large'."; \
        exit 1; \
    fi

# Extra optional packages installation
# If the user wants to install extra packages, 
# it is possible to set the INST_EXTRA build argument to true
# and specify EXTRA_PACKS as filename or a list of packages. 
# The default is requirements-opt.txt
RUN if [ "$INST_EXTRA" = "true" ]; then \
        if [ "$EXTRA_PACKS" == *.txt ]; then \
            if [ -f "requirements/$EXTRA_PACKS" ]; then \
                pip install --no-cache-dir -r "requirements/$EXTRA_PACKS"; \
            else \
                echo "Extra packages requirements file not found, please put it in "; \
                echo "requirements folder and specify just the filename, not the path."; \
                exit 1; \
            fi; \
        else \
            pip install --no-cache-dir "$EXTRA_PACKS"; \
        fi; \
        echo "Optional extra packages installed :)"; \
    else \
        echo "Optional extra packages not installed"; \
    fi

# copy the rest of the current folder into the container
# uncomment the following line if you want to copy it
# COPY . .

# expose ports that will be used for kernels
EXPOSE 8888-8898

# set the user to run the container
USER $USERNAME

# create and add the user's bin directory to the PATH env variable
RUN mkdir -p /home/$USERNAME/bin
ENV PATH="/home/${USERNAME}/bin:${PATH}"

# default command (shell)
CMD ["/bin/bash"]
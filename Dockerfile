FROM python:3.12-slim

ARG VERSION="normal" # Default version of the application, options are small, normal, and large
ARG INST_EXTRA=false # Set to true to install additional optional packages
ARG EXTRA_PACKS=requirements-opt.txt # Filename for extra packages, it can be also a string like "numpy pandas"

WORKDIR /app

COPY ./requirements/ ./requirements/
COPY start-kernel.sh ./

RUN chmod +x ./start-kernel.sh

RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* # to remove unnecessary files and for security reasons

RUN pip install --upgrade pip

RUN if [ "$VERSION" = "small" ] || [ "$VERSION" = "normal" ] || [ "$VERSION" = "large" ]; then \
        if [ -f requirements/"requirements-${VERSION}.txt" ]; then \
            pip install --no-cache-dir -r requirements/"requirements-${VERSION}.txt"; \
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

# COPY . . # Uncomment this line if you want to copy the entire current directory into the container

EXPOSE 8888-8898

CMD ["bash"]
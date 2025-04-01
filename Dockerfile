FROM python:3.12-slim

ARG VERSION="normal"
ARG INST_EXTRA=false
ARG EXTRA_PACKS=requirements_opt.txt

WORKDIR /app

COPY requirements .
COPY start-kernel.sh ./

RUN chmod +x ./start-kernel.sh

RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    # rm -rf /var/lib/apt/lists/* to remove unnecessary files and for security reasons

RUN pip install --upgrade pip

RUN if [ "$VERSION" = "small" ]; then \
        if [ -f requirements/requirements_small.txt ]; then \
            pip install --no-cache-dir -r requirements/requirements_small.txt; \
            echo "Small version installed :)"; \
        else \
            echo "Small version requirements file not found."; \
            exit 1; \
        fi; \
    elif [ "$VERSION" = "normal" ]; then \
        if [ -f requirements/requirements_normal.txt ]; then \
            pip install --no-cache-dir -r requirements/requirements_normal.txt; \
            echo "Normal version installed :)"; \
        else \
            echo "Normal version requirements file not found."; \
            exit 1; \
        fi; \
    elif [ "$VERSION" = "large" ]; then \
        if [ -f requirements/requirements_large.txt ]; then \
            pip install --no-cache-dir -r requirements/requirements_large.txt; \
            echo "Large version installed :)"; \
        else \
            echo "Large version requirements file not found."; \
            exit 1; \
        fi; \
    else \
        echo "Invalid version specified. Please use 'small', 'normal', or 'large'."; \
        exit 1; \
    fi

# Extra optional packages installation
# If the user wants to install extra packages, 
# they can set the INST_EXTRA build argument to true 
# and provide a requirements file or a list of packages in EXTRA_PACKS.
RUN if [ "$INST_EXTRA" = "true" ]; then \
        if [ "$EXTRA_PACKS" == *.txt ]; then \
            if [ -f "requirements/$EXTRA_PACKS" ]; then \
                pip install --no-cache-dir -r "requirements/$EXTRA_PACKS"; \
            else \
                echo "Extra packages requirements file not found, please put it "; \
                echo "in requirements and specify just the name, not the path."; \
                exit 1; \
            fi; \
        else \
            pip install --no-cache-dir "$EXTRA_PACKS"; \
        fi; \
        echo "Optional extra packages installed :)"; \
    else \
        echo "Optional extra packages not installed"; \
    fi

# COPY . .

EXPOSE 8888-8898

CMD ["bash"]
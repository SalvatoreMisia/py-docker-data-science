FROM python:3.12

WORKDIR /usr/src/app

COPY requirements.txt ./
COPY start-kernel.sh ./

RUN chmod +x ./start-kernel.sh

RUN apt-get update && \\
    apt-get install -y jq && \\
    rm -rf /var/lib/apt/lists/* # rm -rf /var/lib/apt/lists/* to remove unnecessary files and for security reasons

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8888-8898

CMD ["bash"]
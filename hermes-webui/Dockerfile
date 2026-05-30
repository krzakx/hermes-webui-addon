ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       python3 python3-pip python3-venv python3-yaml \
       ca-certificates curl git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/nesquena/hermes-webui.git /opt/hermes-webui

WORKDIR /opt/hermes-webui

RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --break-system-packages \
       -r requirements.txt 2>&1 || \
    /opt/venv/bin/pip install --no-cache-dir --break-system-packages \
       flask flask-cors pyyaml requests

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8787

CMD ["/run.sh"]

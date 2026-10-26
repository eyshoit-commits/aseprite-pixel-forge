# syntax=docker/dockerfile:1

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

# Install the runtime libraries needed by Aseprite headless and Python.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    libc++1-18 \
    libfontconfig1 \
    libx11-6 \
    libxcursor1 \
    libxext6 \
    libxrandr2 \
    && rm -rf /var/lib/apt/lists/*

# Use the reference headless Aseprite binary from the upstream headless image.
COPY --from=ghcr.io/kidthales/aseprite:v1.3.18.6-headless /opt/aseprite/bin/aseprite /usr/local/bin/aseprite
RUN ln -sf /usr/local/bin/aseprite /usr/local/bin/ase

WORKDIR /workspace

# Copy project files before installing Python dependencies.
COPY . /workspace

RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir pillow

# Smoke check the runtime so the container is ready for forge commands.
RUN aseprite --batch --version

CMD ["bash", "-lc", "python3 scripts/forge.py doctor"]

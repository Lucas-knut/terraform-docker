FROM localstack/localstack:latest

USER root

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Installer OpenTofu
RUN wget https://github.com/opentofu/opentofu/releases/download/v1.10.8/tofu_1.10.8_linux_amd64.zip \
    && unzip tofu_1.10.8_linux_amd64.zip \
    && mv tofu /usr/local/bin/ \
    && rm tofu_1.10.8_linux_amd64.zip \
    && ln -s /usr/local/bin/tofu /usr/local/bin/terraform

# Installer Python et pip (si pas déjà présent)
RUN apt-get update && apt-get install -y python3-pip python3-venv

# Installer awslocal et tflocal
RUN pip3 install --upgrade pip \
    && pip3 install awscli-local terraform-local

# Créer un répertoire de travail
WORKDIR /workspace

USER localstack

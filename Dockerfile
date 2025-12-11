FROM localstack/localstack:latest

USER root

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    curl \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Installer OpenTofu
RUN wget https://github.com/opentofu/opentofu/releases/download/v1.11.1/tofu_1.11.1_linux_amd64.zip \
    && unzip tofu_1.11.1_linux_amd64.zip \
    && mv tofu /usr/local/bin/ \
    && rm tofu_1.11.1_linux_amd64.zip \
    && ln -s /usr/local/bin/tofu /usr/local/bin/terraform

# Installer Python et pip (si pas déjà présent)
RUN apt-get update && apt-get install -y python3-pip python3-venv

# Installer awslocal et tflocal
RUN pip3 install --upgrade pip \
    && pip3 install awscli-local terraform-local

# Installer Oh My Zsh pour l'utilisateur localstack
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Installer Powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k

# Installer les plugins zsh
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# Configurer zsh avec autocomplétion
RUN echo 'export ZSH="/root/.oh-my-zsh"' >> /root/.zshrc \
    && echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> /root/.zshrc \
    && echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> /root/.zshrc \
    && echo 'plugins=(git terraform aws docker zsh-syntax-highlighting zsh-autosuggestions)' >> /root/.zshrc \
    && echo 'source $ZSH/oh-my-zsh.sh' >> /root/.zshrc \
    && echo 'autoload -U compinit && compinit' >> /root/.zshrc \
    && echo 'complete -o nospace -C /usr/local/bin/tofu tofu' >> /root/.zshrc \
    && echo 'complete -o nospace -C /usr/local/bin/tofu terraform' >> /root/.zshrc

# Changer le shell par défaut pour zsh
RUN chsh -s /bin/zsh root

# Créer un répertoire de travail
WORKDIR /workspace

USER localstack

# Configurer zsh pour l'utilisateur localstack
USER root
RUN cp -r /root/.oh-my-zsh /home/localstack/.oh-my-zsh \
    && cp /root/.zshrc /home/localstack/.zshrc \
    && chown -R localstack:localstack /home/localstack/.oh-my-zsh /home/localstack/.zshrc \
    && chsh -s /bin/zsh localstack

USER localstack

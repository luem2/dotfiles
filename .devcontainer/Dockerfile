FROM fedora:latest

# Instalar paquetes básicos
RUN dnf update -y && \
    dnf install -y git curl wget stow sudo ansible ansible-lint pip

# Crear usuario no root
RUN useradd -m dev && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER dev

WORKDIR /workspace
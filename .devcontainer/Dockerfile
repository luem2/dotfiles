FROM fedora:latest

# Instalar paquetes básicos
RUN dnf update -y && \
    dnf install -y --setopt=install_weak_deps=False \
    git curl wget stow sudo ansible ansible-lint python3-pip shfmt && \
    dnf clean all && rm -rf /var/cache/dnf

# Crear usuario no root
RUN useradd -m dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev && \
    chmod 0440 /etc/sudoers.d/dev

# Cambiar al usuario no root
USER dev

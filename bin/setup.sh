#!/bin/bash

# Declaro variables
SSH_DIR="$HOME/.ssh"
DOTFILES_DIR="$HOME/.dotfiles"
REPO_URL="https://github.com/luem2/dotfiles.git"

# Verificar si unzip está instalado, si no, instalarlo
if ! command -v unzip &> /dev/null; then
    echo "⚠️📦   unzip no encontrado, instalándolo..."
    sudo dnf install -y unzip
fi

# Verificar si jq está instalado, si no, instalarlo
if ! command -v jq &> /dev/null; then
    echo "⚠️📦   jq no encontrado, instalándolo..."
    sudo dnf install -y jq
fi

# Verificar si Ansible está instalado, si no, instalarlo
if ! command -v ansible &> /dev/null; then
    echo "⚠️📦   ansible no encontrado, instalándolo..."
    sudo dnf install -y ansible
fi

# Verificar si Bitwarden CLI está instalado
if ! command -v bw &> /dev/null; then
    echo "⚠️📦   bw no encontrado, instalando..."

    # Descargar Bitwarden CLI desde la página oficial
    DOWNLOAD_URL="https://bitwarden.com/download/?app=cli&platform=linux"

    # Descargar el archivo del CLI
    wget -O bitwarden-cli.zip "$DOWNLOAD_URL"

    # Extraer el archivo descargado
    unzip bitwarden-cli.zip

    # Elimino el zip
    rm bitwarden-cli.zip

    # Mover el binario al directorio del PATH
    sudo mv bw /usr/local/bin/

    # Verificar la instalación
    bw --version
fi

# Función para iniciar sesión
login_bitwarden() {
    while true; do
        # Obtengo las credenciales de API KEY
        echo "🪪   Introduce tu client_id de Bitwarden: "
        read -r -s BW_CLIENTID

        echo "🔑   Introduce tu client_secret de Bitwarden: "
        read -r -s BW_CLIENTSECRET

        # Exporto las credenciales
        export BW_CLIENTID BW_CLIENTSECRET

        if bw login --apikey; then
            echo "✅   Ha iniciado sesión!"

            return 0  # Éxito
        else
            echo -e "❌   Error en el inicio de sesión. Ingrese nuevamente las crendenciales."
        fi
    done
}

# Función para desbloquear bóveda
unlock_bitwarden() {
    while true; do
        echo "🔑   Introduce tu contraseña de Bitwarden para desbloquear:"
        read -r -s BW_PASSWORD

        # Exporto la variable de entorno
        export BW_PASSWORD

        # Desbloqueo la bóveda y persisto la sesión
        BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)

        if [ -n "$BW_SESSION" ]; then
            export BW_SESSION

            echo "✅   Bóveda desbloqueada!"
            return 0  # Éxito
        else
            echo -e "❌   Error al desbloquear Bitwarden. Intenta nuevamente."
        fi
    done
}

# Verificar si no hay sesión activa e iniciar sesión si es necesario
if [ "$(bw status | jq -r '.status')" == "unauthenticated" ]; then
    echo "⚠️   No hay sesión activa, iniciando sesión..."
    login_bitwarden
fi

# Verificar si la sesión está bloqueada y desbloquearla si es necesario
if [ "$(bw status | jq -r '.status')" == "locked" ]; then
    echo "🔒   La sesión está bloqueada, desbloqueándola..."
    unlock_bitwarden
fi

# Generar las llaves SSH
if ! [[ -f "$SSH_DIR/authorized_keys" ]]; then
  echo "✨   Obteniendo las llaves SSH"
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"

  # TODO: Recorrer todas las llaves SSH y crearlas.
  # Me traigo las llaves ssh desde Bitwarden
  bw get item "github SSH" | jq -r ".sshKey.privateKey" > "$SSH_DIR/github"
  chmod 600 "$SSH_DIR/github"

  # Guardo la llave publica
  bw get item "github SSH" | jq -r ".sshKey.publicKey" >> "$SSH_DIR/authorized_keys"
fi

# Clono el repositorio Github y lo muevo a home
if ! [[ -d "$DOTFILES_DIR" ]]; then
  echo "✨   Clonando repositorio"
  git clone --quiet $REPO_URL "$DOTFILES_DIR"
else
  echo "✨   Actualizando repositorio"
  git -C "$DOTFILES_DIR" pull --quiet
fi

# Ejecutar el playbook de Ansible
ansible-playbook bootstrap.yml --ask-become-pass

# Finalizando sesión de Bitwarden
bw logout

# Envio notificación
if command -v notify-send 1>/dev/null 2>&1; then
  notify-send "Se han configurado correctamente el entorno." -a "Dotfiles: Bootstrap Completado" 
fi
#!/bin/bash

# Declaro variables
SSH_DIR="$HOME/.ssh"
DOTFILES_DIR="$HOME/.dotfiles"
REPO_URL="https://github.com/luem2/dotfiles.git"
ENV_FILE="$HOME/.dotfiles.env"

set -e

# Cargo las variables de entorno
if [[ -f "$ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE" 
    export BW_CLIENTID BW_CLIENTSECRET BW_PASSWORD
else
    echo "⚠️  Archivo de variables no encontrado: $ENV_FILE"
    exit 1
fi

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

# Verificar si no hay sesión activa e iniciar sesión si es necesario
if [ "$(bw status | jq -r '.status')" == "unauthenticated" ]; then
    printf "⚠️   No hay sesión activa, \n 🔶   Iniciando sesión..."
    bw login --apikey
fi

# Verificar si la sesión está bloqueada y desbloquearla si es necesario
if [ "$(bw status | jq -r '.status')" == "locked" ]; then
    echo "🔒   La sesión está bloqueada, desbloqueándola..."

    # Desbloqueo la bóveda y persisto la sesión
    BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)
    export BW_SESSION

    echo "✅   Bóveda desbloqueada correctamente!"
fi

# Crea el directorio SSH si no existe
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Obtiene todas las llaves SSH almacenadas en Bitwarden (filtra por nombre que contenga "SSH")
bw list items | jq -r '.[] | select(.name | test("SSH")) | .id' | while read -r item_id; do
  # Obtengo el diccionario SSH
  item=$(bw get item "$item_id")

  # Obtengo el nombre del SSH
  key_name=$(echo "$item" | jq -r '.name' | sed 's/[^a-zA-Z0-9_-]/_/g') # Formatea el nombre

  # Obtengo la llave
  private_key=$(echo "$item" | jq -r ".sshKey.privateKey")

  # Creo las llaves
  if [[ -n "$private_key" ]]; then
    key_path="$SSH_DIR/$key_name"
    echo "🔑 Creando llave SSH: $key_name"
    
    echo "$private_key" > "$key_path"
    chmod 600 "$key_path"
  else
    echo "❌  No se encontró una clave privada en $key_name"
  fi
done

echo "✅  Todas las llaves SSH han sido restauradas correctamente."

# Clono el repositorio Github y lo muevo a home
if ! [[ -d "$DOTFILES_DIR" ]]; then
  echo "✨   Clonando repositorio"
  git clone --quiet $REPO_URL "$DOTFILES_DIR"
else
  echo "✨   Actualizando repositorio"
  git -C "$DOTFILES_DIR" pull --quiet
fi

# Ejecutar el playbook de Ansible
ansible-playbook "$DOTFILES_DIR/bootstrap.yml"

rm -f "$ENV_FILE"

# Envío de notificación
if command -v notify-send >/dev/null 2>&1; then
  notify-send -a "Dotfiles: Bootstrap Completado" "✅ Se han configurado correctamente el entorno."
else
  echo "✅ Se ha completado correctamente la restauración del sistema."
fi
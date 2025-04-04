#!/bin/bash

# Declaro variables
SSH_DIR="$HOME/.ssh"
DOTFILES_DIR="$HOME/.dotfiles"
REPO_URL="https://github.com/luem2/dotfiles.git"
ENV_FILE="$HOME/.dotfiles.env"

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

# Cargo las variables de entorno (si existe el archivo ".dotfiles.env")
if [[ -f "$ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE" 
    export BW_CLIENTID BW_CLIENTSECRET BW_PASSWORD
fi

# Función para iniciar sesión
login_bitwarden() {
    while true; do
        # Si las credenciales no están seteadas, pedirlas
        if [ -z "$BW_CLIENTID" ] || [ -z "$BW_CLIENTSECRET" ]; then
            echo "🪪   Introduce tu client_id de Bitwarden:"
            read -r -s BW_CLIENTID

            echo "🔑   Introduce tu client_secret de Bitwarden:"
            read -r -s BW_CLIENTSECRET

            export BW_CLIENTID BW_CLIENTSECRET
        fi

        # Intentar iniciar sesión con las credenciales
        if bw login --apikey; then
            echo "✅   Inicio de sesión exitoso!"
            return 0  # Éxito
        else
            echo "❌   Error en el inicio de sesión. Intenta nuevamente."
            unset BW_CLIENTID BW_CLIENTSECRET  # Limpiar credenciales erróneas
        fi
    done
}


# Función para desbloquear bóveda
unlock_bitwarden() {
    while true; do
        # Solo pedir la contraseña si no está seteada
        if [ -z "$BW_PASSWORD" ]; then
            echo "🔑   Introduce tu contraseña de Bitwarden para desbloquear:"
            read -r -s BW_PASSWORD
            export BW_PASSWORD
        fi

        # Intentar desbloquear la bóveda
        BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)

        if [ -n "$BW_SESSION" ]; then
            export BW_SESSION
            echo "✅   Bóveda desbloqueada!"
            return 0  # Éxito
        else
            echo "❌   Error al desbloquear Bitwarden. Intenta nuevamente."
            unset BW_PASSWORD  # Limpiar la variable para volver a pedirla
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

# Si existe el archivo de variables de entorno, lo borra
if [ -f "$ENV_FILE" ]; then
    rm -f "$ENV_FILE"
fi

# Envío de notificación
if command -v notify-send >/dev/null 2>&1; then
  notify-send -a "Dotfiles: Bootstrap Completado" "✅ Se han configurado correctamente el entorno."
else
  echo "✅ Se ha completado correctamente la restauración del sistema."
fi
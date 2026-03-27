<a name="readme-top"></a>

<!-- LOGO -->
<br />
<div align="center">
  <a href="https://github.com/luem2/dotfiles">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">Luem2 dotfiles</h3>
  <p align="center">
    Automatización de instalaciones de programas y archivos de configuración.
  </p>
</div>

<!-- GETTING STARTED -->
## Requisitos previos

- Fedora con `sudo`.
- SSH:
  - Configuración y llaves manuales (no se restauran automáticamente).
- VirtIO (Windows VMs):
  - El ISO de drivers se descarga manualmente desde https://fedorapeople.org/groups/virt/virtio-win/
- VMs (virt-manager):
  - Habilita 3D acceleration y OpenGL en el dispositivo de video (SPICE/Virtio) para que Niri arranque.
- Opcional: archivo local con flags en `~/.config/dotfiles/vars.yml`.

### Fedora Everything (mínimo recomendado)

Si instalás Fedora Everything en modo mínimo, asegurate de tener:

- Red funcionando
- Usuario con `sudo`
- `curl`

Instalación mínima previa:

```sh
sudo dnf install -y curl
```

El resto de dependencias (`git`, `jq`, `unzip`, `ansible`, `stow`) las instala automáticamente el script `dotfiles`.
El playbook también instala herramientas de desarrollo como `just`.
Rust se instala con `rustup` durante el playbook, no desde los paquetes de Fedora.

Ejemplo de `~/.config/dotfiles/vars.yml`:

```yaml
install_steam: false
gaming_packages:
  - steam
```

## Instalación

```sh
git clone https://github.com/luem2/dotfiles.git ~/workspace/dotfiles
ln -snf ~/workspace/dotfiles/bin/dotfiles ~/.local/bin/dotfiles
dotfiles
```

## Uso

```sh
dotfiles
```

Esto ejecuta:
1. El instalador oficial de Dank (`dankinstall`) para Niri + DMS.
2. El playbook de Ansible.
3. Los enlaces con Stow en modo seguro (`--no-folding`, sin adopción de archivos existentes) usando el repo clonado como fuente real.

YouTube Music:

- No se crea un launcher manual.
- Instalalo de forma oficial desde Chrome: abrí `https://music.youtube.com/` y usá `Cast, save, and share` -> `Install page as app`.
- Eso conserva el icono, el `app id` y el agrupado correcto en el dock.

## Stow manual (opcional)

Ejecutalo parado en `roles/`:

```sh
stow -d . -t ~ --no-folding -R -S */
```

Qué hace:

- `-d .`: usa el directorio actual como `stow dir`. En este repo, eso significa `roles/`.
- `-t ~`: crea los symlinks en tu home.
- `--no-folding`: no colapsa directorios completos en un solo symlink; enlaza archivo por archivo.
- `-R`: re-stow. Reaplica el paquete y actualiza symlinks existentes de ese mismo origen.
- `-S`: stow. Activa los paquetes indicados.
- `*/`: selecciona todos los directorios hijos de `roles/`, o sea todos los paquetes.

Ejemplo equivalente con ruta explícita desde la raíz del repo:

```sh
stow -d roles -t ~ --no-folding -R -S roles/*
```

Para deshacer los symlinks manualmente:

```sh
stow -d . -t ~ --no-folding -D */
```

Qué hace:

- `-D`: unstow. Elimina los symlinks creados por Stow para esos paquetes.
- `*/`: aplica la operación a todos los paquetes dentro de `roles/`.

Ejemplo equivalente con ruta explícita desde la raíz del repo:

```sh
stow -d roles -t ~ --no-folding -D roles/*
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

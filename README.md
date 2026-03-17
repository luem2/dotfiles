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
Rust se instala con `rustup` durante el playbook, no desde los paquetes de Fedora.

Ejemplo de `~/.config/dotfiles/vars.yml`:

```yaml
install_steam: false
gaming_packages:
  - steam
```

## Instalación

```sh
curl -fsSL https://raw.githubusercontent.com/luem2/dotfiles/main/bin/dotfiles | sh
```

## Uso

```sh
dotfiles
```

Esto ejecuta:
1. El instalador oficial de Dank (`dankinstall`) para Niri + DMS.
2. El playbook de Ansible.
3. Los enlaces con Stow en modo seguro (`--no-folding`, sin adopción de archivos existentes).

## Stow manual (opcional)

```sh
stow -d . -t ~ --no-folding -R -S */
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

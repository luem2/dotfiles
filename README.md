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
- Bitwarden:
  - Un item llamado `ssh-config` con un attachment `ssh_config` que contiene tu `~/.ssh/config` privado.
  - Llaves SSH guardadas como items de tipo SSH (campo `sshKey`).
- VirtIO (Windows VMs):
  - El ISO de drivers se descarga manualmente desde https://fedorapeople.org/groups/virt/virtio-win/
- VMs (virt-manager):
  - Habilita 3D acceleration y OpenGL en el dispositivo de video (SPICE/Virtio) para que Niri arranque.
- Opcional: archivo local con flags en `~/.config/dotfiles/vars.yml`.

Ejemplo de `~/.config/dotfiles/vars.yml`:

```yaml
install_steam: false
gaming_packages:
  - steam
```

## Instalación

```sh
curl -fsSL https://raw.githubusercontent.com/luem2/dotfiles/main/bin/setup.sh | sh
```

## Uso

```sh
dotfiles
```

Esto ejecuta el playbook de Ansible y aplica los enlaces con Stow usando `--adopt -R`.

## Stow manual (opcional)

```sh
stow -d . -t ~ --adopt -R -S */
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

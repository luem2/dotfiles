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

## Troubleshooting

### Wi-Fi: autoconnect, prioridad y perfiles guardados

`NetworkManager` no elige "la red mas cercana" de forma literal. Decide en base a:

- perfiles guardados
- `autoconnect`
- prioridad del perfil
- exito o fallo de conexiones previas

Por eso, si existe un perfil viejo con `autoconnect=yes`, puede intentar usarlo primero y demorar la conexion aunque haya otra red mejor disponible.

Inspeccionar perfiles:

```sh
nmcli connection show
```

Ver solo nombre, tipo, autoconnect y prioridad:

```sh
nmcli -f NAME,TYPE,AUTOCONNECT,AUTOCONNECT-PRIORITY connection show
```

Subir la prioridad de un perfil Wi-Fi:

```sh
nmcli connection modify "<wifi>" connection.autoconnect-priority 200
```

Bajar la prioridad de otro perfil:

```sh
nmcli connection modify "<wifi>" connection.autoconnect-priority 50
```

Desactivar autoconnect para un perfil guardado sin borrarlo:

```sh
nmcli connection modify "<wifi>" connection.autoconnect no
```

Volver a activarlo:

```sh
nmcli connection modify "<wifi>" connection.autoconnect yes
```

Borrar un perfil guardado:

```sh
nmcli connection delete "<wifi>"
```

Activar una conexion manualmente:

```sh
nmcli connection up "<wifi>"
```

Ver la conexion activa:

```sh
nmcli -f NAME,TYPE,DEVICE,STATE connection show --active
```

Ver logs del arranque actual de `NetworkManager`:

```sh
journalctl -b -u NetworkManager.service
```

Filtrar eventos Wi-Fi/auth:

```sh
journalctl -b -u NetworkManager.service | rg "wifi|wpa|auth|ssid|wrong_key|need-auth"
```

### OpenVPN importado en NetworkManager

Si un `.ovpn` importado funciona con:

```sh
nmcli connection up "<vpn>" --ask
```

entonces el perfil base esta bien y el problema suele ser de secretos no guardados o del agente grafico que los pide.

Mostrar el perfil:

```sh
nmcli connection show "<vpn>"
```

Mostrar secretos visibles para diagnostico:

```sh
nmcli --show-secrets connection show "<vpn>"
```

Si el `.ovpn` usa una clave privada cifrada (`ENCRYPTED PRIVATE KEY`), la conexion puede necesitar `cert-pass` en lugar de un password VPN comun.

En ese caso, algunos agentes graficos pueden pedir el secreto equivocado o entrar en bucle. Una forma confiable de validar el perfil es:

```sh
nmcli connection up "<vpn>" --ask
```

Si eso conecta, el perfil importado esta bien y el problema suele ser del agente grafico de secretos, no del `.ovpn`.

Para revisar si el perfil esta usando passphrase de certificado:

```sh
nmcli connection show "<vpn>" | rg "cert-pass|challenge-response|vpn.data"
```

Si el agente grafico entra en bucle pidiendo password, revisa el keyfile real de `NetworkManager`:

```sh
sudo nvim /etc/NetworkManager/system-connections/<vpn>.nmconnection
```

En la seccion `[vpn]`, `cert-pass-flags` debe quedar asi:

```ini
cert-pass-flags=0
```

Si esta en `1`, `NetworkManager` sigue tratando la passphrase como `agent-owned` y depende del prompt grafico.

Ademas, el archivo debe tener una seccion `[vpn-secrets]`:

```ini
[vpn-secrets]
cert-pass=<passphrase>
```

Despues de editar el keyfile:

```sh
sudo chmod 600 /etc/NetworkManager/system-connections/<vpn>.nmconnection
sudo nmcli connection reload
```

Verificacion:

```sh
nmcli --show-secrets connection show "<vpn>" | rg "cert-pass|vpn.secrets|cert-pass-flags"
```

Con eso, `NetworkManager` ya no depende del prompt interactivo y el plugin grafico puede conectar el VPN sin pedir password.

Si al conectar el VPN "anda" pero te deja sin salida a internet, normalmente significa que el tunel esta tomando la ruta por defecto. Para dejarlo en modo split-tunnel desde `NetworkManager`:

```sh
nmcli connection modify "<vpn>" ipv4.never-default yes ipv6.never-default yes
```

Luego volver a levantar la conexion:

```sh
nmcli connection down "<vpn>"
nmcli connection up "<vpn>" --ask
```

Si quieres volver al comportamiento full-tunnel:

```sh
nmcli connection modify "<vpn>" ipv4.never-default no ipv6.never-default no
```

Si el VPN conecta pero no resuelven dominios internos, el problema suele ser DNS del tunel, no conectividad IP.

Ver estado de DNS y rutas:

```sh
nmcli -f NAME,TYPE,DEVICE,STATE connection show --active
nmcli device show tun0
resolvectl status
ip route
```

Para usar el DNS de la VPN tambien en split-tunnel:

```sh
nmcli connection modify "<vpn>" ipv4.dns-search "~."
nmcli connection down "<vpn>"
nmcli connection up "<vpn>" --ask
```

Si solo quieres mandar un dominio interno concreto al DNS de la VPN:

```sh
nmcli connection modify "<vpn>" ipv4.dns-search "~dominio.interno"
```

Nota importante:

- modificar el `.ovpn` original no cambia automaticamente el perfil ya importado en `NetworkManager`
- una vez importado, lo que manda es el perfil guardado por `NetworkManager`
- si quieres aplicar cambios del archivo original, reimporta el perfil o edita directamente el keyfile de `NetworkManager`

### Suspend: wakeup inmediato en `s2idle`

Si el equipo entra en suspend pero se despierta casi instantaneamente, no siempre es un problema de `Niri` o `DMS`. En laptops modernas con Fedora suele intervenir:

- `s2idle` como modo de suspend por defecto
- algun dispositivo con wakeup habilitado

Ver modo actual de suspend:

```sh
cat /sys/power/mem_sleep
```

Si ves algo como:

```text
[s2idle] deep
```

entonces el equipo esta usando `s2idle`.

Listar wakeup USB que suelen ser sospechosos:

```sh
grep . /sys/bus/usb/devices/*/power/wakeup 2>/dev/null
```

En este setup se identificaron dos receptores relevantes:

- `3-4`: `Logitech USB Receiver`
- `3-1.2`: `AJAZZ AK820 MAX 2.4G`

La prueba util para aislar el culpable es desactivar uno por vez y luego suspender:

```sh
echo disabled | sudo tee /sys/bus/usb/devices/3-4/power/wakeup
echo enabled | sudo tee /sys/bus/usb/devices/3-1.2/power/wakeup
systemctl suspend
```

Resultado validado en esta maquina:

- con `3-4` deshabilitado, el equipo suspende bien
- `3-1.2` puede quedar habilitado
- el sistema se puede reanudar correctamente desde el teclado AJAZZ

Interpretacion:

- `3-4` es el receiver Logitech
- ese receiver estaba generando el wakeup espurio
- `3-1.2` es el dongle del teclado AJAZZ
- ese dongle si sirve como wake source util
- la persistencia no debe basarse en `3-4`, sino en `idVendor:idProduct`
- en este repo la regla persistente usa `046d:c548`, que corresponde a este receiver Logitech concreto

Para volver al estado base:

```sh
echo enabled | sudo tee /sys/bus/usb/devices/3-4/power/wakeup
echo enabled | sudo tee /sys/bus/usb/devices/3-1.2/power/wakeup
```

Para diagnosticar el ultimo ciclo de suspend:

```sh
journalctl -b -1 | rg "suspend|PM: suspend|wakeup|wake|ACPI"
```

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

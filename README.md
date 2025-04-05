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

<p align="center">
  <img src="images/screenshot.png" alt="Dotfiles Screenshot" width="600" />
</p>

<!-- GETTING STARTED -->
## Requisitos previos

### Declaracion de variables
Los `dotfiles` requieren 3 variables para poder cargar los secretos y así poder generar las llaves e iniciar sesión a los servicios. Tenemos las siguientes opciones:

- Estos podrán cargarse de forma dinámica a traves de "prompts" una vez ejecutado el comando de instalación.
- Se pueden cargar a través de un archivo ubicado en `$HOME/.dotfiles.env`.

```sh
BW_CLIENTID= # ID (API Key)
BW_CLIENTSECRET= # Secreto (API Key)
BW_PASSWORD= # Contraseña maestra Bóveda Bitwarden
```

## Instalación

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/luem2/dotfiles/main/bin/setup.sh)"
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Comando para aplicar todas las configuraciones

```sh
stow --adopt -R */
```
`--adopt`
- Adopta archivos existentes en el directorio destino (ej. /usr/local).
- Si hay archivos o enlaces que no fueron creados por Stow, los mueve al paquete correspondiente (dentro del directorio de Stow) y los reemplaza con enlaces simbólicos.

`-R`
- Reinstala los paquetes: Primero elimina los enlaces existentes y luego los vuelve a crear.
- Útil para actualizar o corregir enlaces rotos después de modificar los paquetes.

`*/`
- Aplica la acción a todos los subdirectorios en el directorio actual (cada uno representa un paquete de Stow).

## Usar Stow que no este en $HOME

```sh
stow -d . -t ~ -S */
```

## Combinar comando 1ero con el 2do
```sh
stow -d . -t ~ --adopt -R -S */
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

[product-screenshot]: images/screenshot.png
# Dotfiles Luem2

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
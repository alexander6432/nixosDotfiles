#!/run/current-system/sw/bin/bash

modo="$1" # ejemplo: ./atajos.sh grupos o ./atajos.sh ventanas

if [[ $modo == "grupos" ]]; then
  filtro="\[Modo Grupos\]"
elif [[ $modo == "ventanas" ]]; then
  filtro="\[Modo Ventanas\]"
else
  filtro=""
fi
# Ejecutar hyprctl y procesar con awk
salida=$(hyprctl binds | awk '
function modmask_to_names(mask,   names, i, result) {
    split("", names)
    if (and(mask, 128)) names[length(names)+1] = "ALTGR"
    if (and(mask, 64))  names[length(names)+1] = "SUPER"
    if (and(mask, 32))  names[length(names)+1] = "SCROLL"
    if (and(mask, 16))  names[length(names)+1] = "NUM"
    if (and(mask, 8))   names[length(names)+1] = "ALT"
    if (and(mask, 4))   names[length(names)+1] = "CTRL"
    if (and(mask, 2))   names[length(names)+1] = "CAPS"
    if (and(mask, 1))   names[length(names)+1] = "SHIFT"
    result = ""
    for (i = 1; i <= length(names); i++) {
        result = result names[i] " + "
    }
    return result
}

function format_key(k,   parts) {
    # Traducir scroll
    if (k == "F1") return "󱊫"
    if (k == "F10") return "󱊴"
    if (k == "F11") return "󱊵"
    if (k == "F12") return "󱊶"
    if (k == "F2") return "󱊬"
    if (k == "F3") return "󱊭"
    if (k == "F8") return "󱊲"
    if (k == "F9") return "󱊳"
    if (k == "PRINT") return "Impr Pant"
    if (k == "Tab") return ""
    if (k == "XF86AudioLowerVolume") return ""
    if (k == "XF86AudioMicMute") return ""
    if (k == "XF86AudioMute") return ""
    if (k == "XF86AudioNext") return "󰒭"
    if (k == "XF86AudioPause") return ""
    if (k == "XF86AudioPlay") return ""
    if (k == "XF86AudioPrev") return "󰒮"
    if (k == "XF86AudioRaiseVolume") return ""
    if (k == "XF86AudioStop") return ""
    if (k == "XF86MonBrightnessDown") return "󰃞"
    if (k == "XF86MonBrightnessUp") return "󰃠"
    if (k == "apostrophe") return "\x27"
    if (k == "backspace") return "󰞓"
    if (k == "comma") return ","
    if (k == "down") return ""
    if (k == "end") return "Fin"
    if (k == "escape") return "󱊷"
    if (k == "left") return ""
    if (k == "minus") return "-"
    if (k == "mouse_down") return "Scroll 󱕐"
    if (k == "mouse_up")   return "Scroll 󱕑"
    if (k == "page_down") return "AvPág"
    if (k == "period") return "."
    if (k == "plus") return "+"
    if (k == "return") return "󰌑"
    if (k == "right") return ""
    if (k == "space") return "󱁐"
    if (k == "up") return ""

    # Traducir clicks
    if (k ~ /^mouse:[0-9]+$/) {
        split(k, parts, ":")
        if (parts[2] == 272) return " Izquie."
        if (parts[2] == 273) return " Derecho"
        if (parts[2] == 274) return " Medio"
        return "Mouse " parts[2]
    }

    # Limpiar prefijo XF86
    gsub(/^XF86/, "", k)
    return k
}

BEGIN {
    BOLD="\033[1m"
    RESET="\033[0m"
    BLUE="\033[34m"
    GREEN="\033[32m"
    CYAN="\033[36m"
    YELLOW="\033[33m"

    # Encabezado
    printf BOLD BLUE "%-15s %-9s %-76s\n" RESET, "TECLA LíDER", "TECLA", "DESCRIPCIÓN"
    printf "%s\n", "󰣇 ===  ===  === 󰣇 ===  ===  === 󰣇 ===  ===  === 󰣇 ===  ===  === 󰣇 ===  ===  === 󰣇 ===  ===  === 󰣇 "
}

/^bind/ {
    getline; modmask = $2
    getline; submap = $2
    getline; key = $2
    getline; keycode = $2
    getline; catchall = $2
    getline; desc = substr($0, index($0, $2))

    modnames = modmask_to_names(modmask)

    key_display = (key != "" ? key : (keycode != "" ? "KEYCODE_" keycode : catchall))
    key_display = format_key(key_display)

    # Imprimir línea con colores
    printf GREEN "%-16s" RESET, modnames
    printf CYAN "%-10s" RESET, key_display
    printf YELLOW "%-76s\n" RESET, desc
}
')

# Aplicar filtro según modo
if [[ -n $filtro ]]; then
  echo "$salida" | grep "$filtro"
else
  echo "$salida" | grep -v "\[Modo Grupos\]\|\[Modo Ventanas\]"
fi | fzf --ansi --reverse --prompt="Buscar atajo: " --preview-window=down:3

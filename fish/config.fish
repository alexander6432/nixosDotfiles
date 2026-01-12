# =========================
# CONFIGURACIÓN GENERAL
# =========================

# Quita el saludo inicial de fish
set -g fish_greeting ""

# Iniciar Starship
starship init fish | source

# Yazi con cd automático
function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# =========================
# ALIASES
# =========================

# SUDO HELIX
alias shx="sudo hx -c $HOME/.config/helix/config.toml"

# RESPALDO
alias respaldo-nixos="cp -r /etc/nixos/ $HOME/.config/"

# SSH
alias ssh-keygen="ssh-keygen -t ed25519 -C 'alexander6432@gmail.com'"
alias ssh-testgithub="ssh -T git@github.com"

# =========================
# REBUILDS DE NIXOS
# =========================

alias nixos-switch="sudo nixos-rebuild switch --flake /etc/nixos"
alias nixos-boot="sudo nixos-rebuild boot --flake /etc/nixos"
alias nixos-test="sudo nixos-rebuild test --flake /etc/nixos"
alias nixos-build="sudo nixos-rebuild build --flake /etc/nixos"
alias nixos-dry="sudo nixos-rebuild dry-build --flake /etc/nixos"
alias nixos-rollback="sudo nixos-rebuild switch --rollback"
alias nixos-upgrade="sudo nixos-rebuild switch --flake /etc/nixos --upgrade"

# =========================
# OPERACIONES DE FLAKES
# =========================

alias flake-update="sudo nix flake update /etc/nixos"
alias flake-check="sudo nix flake check /etc/nixos"
alias flake-show="sudo nix flake show /etc/nixos"
alias flake-lock="sudo nix flake lock /etc/nixos"
alias flake-metadata="sudo nix flake metadata /etc/nixos"

# =========================
# LIMPIEZA Y OPTIMIZACIÓN
# =========================

alias nix-trash="sudo nix-collect-garbage -d"
alias nix-optimize="sudo nix-store --optimize"
alias nix-clean="sudo nix-collect-garbage --delete-older-than 30d && sudo nix-store --optimize"
alias nix-oldclean="sudo nix-collect-garbage --delete-older-than 7d"

# =========================
# INFORMACIÓN DE GENERACIONES
# =========================

alias nixos-gens="sudo nix-env --list-generations --profile /nix/var/nix/profiles/system"
alias nixos-current="readlink /run/current-system"

# =========================
# BÚSQUEDA Y CONSULTA
# =========================

alias nix-search="nix search nixpkgs"
alias nix-why="nix why-depends /run/current-system"

# =========================
# INFORMACIÓN DEL STORE
# =========================

alias nix-roots="nix-store --gc --print-roots | grep -v '/proc/'"
alias nix-dead="nix-store --gc --print-dead"
alias nix-live="nix-store --gc --print-live"

# =========================
# EDICIÓN DE CONFIGURACIÓN
# =========================

alias nixos-edit="sudo hx -c $HOME/.config/helix/config.toml /etc/nixos/configuration.nix"
alias nixos-config="cd /etc/nixos"

# =========================
# INFORMACIÓN DEL SISTEMA
# =========================

alias nixos-version="nixos-version"
alias nix-info="nix-info -m"

# =========================
# SHELLS Y ENTORNOS
# =========================

alias nix-shell="nix-shell -p"
alias nix-run="nix run nixpkgs#"

# =========================
# BUILD LOCAL
# =========================

alias nix-build="nix-build"
alias nix-develop="nix develop"

# =========================
# FUNCIONES
# =========================

# Tamaño del store y top 20 paquetes
function nixos-size
    echo "=== Tamaño de /nix/store ==="
    du -sh /nix/store 2>/dev/null
    echo ""
    echo "=== Top 20 paquetes más grandes ==="
    nix path-info -rsSh /run/current-system 2>/dev/null | sort -hk2 | tail -20
end

# Comparar generaciones específicas
function nixos-diff
    if test (count $argv) -ne 2
        echo "Uso: nixos-diff <gen1> <gen2>"
        return 1
    end

    set gen1 /nix/var/nix/profiles/system-$argv[1]-link
    set gen2 /nix/var/nix/profiles/system-$argv[2]-link

    if not test -e $gen1
        echo "❌ Generación $argv[1] no existe"
        return 1
    end

    if not test -e $gen2
        echo "❌ Generación $argv[2] no existe"
        return 1
    end

    echo "📊 Comparando generación $argv[1] → $argv[2]"
    nix store diff-closures $gen1 $gen2
end

# Comparar última generación
function nixos-diff-last
    set current (readlink /nix/var/nix/profiles/system | grep -o '[0-9]*')
    if test -z "$current"
        echo "❌ No se pudo determinar la generación actual"
        return 1
    end

    set previous (math $current - 1)

    if not test -e /nix/var/nix/profiles/system-$previous-link
        echo "❌ No hay generación anterior"
        return 1
    end

    echo "📊 Comparando generación $previous → $current"
    nix store diff-closures \
        /nix/var/nix/profiles/system-$previous-link \
        /nix/var/nix/profiles/system-$current-link
end

# Switch seguro con dry-build previo
function nixos-safe-switch
    echo "🔍 Verificando configuración..."
    if sudo nixos-rebuild dry-build --flake /etc/nixos
        echo ""
        echo "✅ Build exitoso, aplicando cambios..."
        sudo nixos-rebuild switch --flake /etc/nixos
        if test $status -eq 0
            echo "✨ Sistema actualizado correctamente"
        else
            echo "❌ Error al aplicar cambios"
            return 1
        end
    else
        echo "❌ Error en dry-build, no se aplicarán cambios"
        return 1
    end
end

# Update completo del sistema
function nixos-full-update
    echo "🔄 Actualizando flake..."
    sudo nix flake update /etc/nixos
    if test $status -ne 0
        echo "❌ Error al actualizar flake"
        return 1
    end

    echo ""
    echo "✅ Verificando configuración..."
    sudo nix flake check /etc/nixos
    if test $status -ne 0
        echo "❌ Error en verificación"
        return 1
    end

    echo ""
    echo "🔨 Aplicando actualización..."
    sudo nixos-rebuild switch --flake /etc/nixos --upgrade
    if test $status -ne 0
        echo "❌ Error al aplicar cambios"
        return 1
    end

    echo ""
    echo "🧹 Limpiando generaciones antiguas..."
    sudo nix-collect-garbage --delete-older-than 30d

    echo ""
    echo "⚡ Optimizando store..."
    sudo nix-store --optimize

    echo ""
    echo "✨ Sistema actualizado completamente"
end

# Qué paquete provee un comando
function nixos-which
    if test (count $argv) -eq 0
        echo "Uso: nixos-which <comando>"
        return 1
    end

    if not command -q nix-locate
        echo "❌ nix-locate no está instalado"
        echo "💡 Ejecuta: nix-shell -p nix-index --run 'nix-index'"
        echo "   O añade 'nix-index' a tu configuración"
        return 1
    end

    echo "🔍 Buscando paquetes que proveen: $argv[1]"
    nix-locate --top-level --whole-name --type x --type s --at-root "/bin/$argv[1]"
end

# Buscar opciones de configuración
function nixos-search-option
    if test (count $argv) -eq 0
        echo "Uso: nixos-search-option <término>"
        return 1
    end
    echo "🔍 Buscando opciones que coincidan con: $argv[1]"
    nixos-option -r $argv[1]
end

# Backup de /etc/nixos con timestamp
function nixos-backup
    set backup_dir ~/nixos-backups/(date +%Y%m%d_%H%M%S)
    mkdir -p $backup_dir

    if sudo cp -r /etc/nixos/* $backup_dir/
        echo "✅ Backup creado en: $backup_dir"

        # Crear un symlink al último backup
        ln -sfn $backup_dir ~/nixos-backups/latest
        echo "🔗 Acceso rápido: ~/nixos-backups/latest"
    else
        echo "❌ Error al crear backup"
        return 1
    end
end

# Eliminar generación específica
function nixos-delete-gen
    if test (count $argv) -eq 0
        echo "Uso: nixos-delete-gen <número|+N>"
        echo ""
        echo "Ejemplos:"
        echo "  nixos-delete-gen 42    # Elimina la generación 42"
        echo "  nixos-delete-gen +5    # Mantiene las últimas 5 generaciones"
        return 1
    end

    echo "🗑️  Eliminando generación(es): $argv[1]"
    sudo nix-env --delete-generations $argv[1] --profile /nix/var/nix/profiles/system

    if test $status -eq 0
        echo "✅ Generación(es) eliminada(s)"
        echo "💡 Ejecuta 'nix-trash' para liberar espacio"
    else
        echo "❌ Error al eliminar generación(es)"
        return 1
    end
end

# Ver cambios en flake.lock
function flake-diff
    if not test -d /etc/nixos/.git
        echo "❌ /etc/nixos no es un repositorio git"
        return 1
    end

    cd /etc/nixos
    echo "📝 Cambios en flake.lock:"
    echo ""
    git diff flake.lock
end

# Limpiar /boot de kernels antiguos
function nixos-clean-boot
    echo "🧹 Limpiando kernels antiguos de /boot..."
    sudo nix-collect-garbage -d

    if test $status -eq 0
        echo "🔄 Actualizando bootloader..."
        sudo /run/current-system/bin/switch-to-configuration boot
        echo "✅ Limpieza completada"
    else
        echo "❌ Error en limpieza"
        return 1
    end
end

# Listar paquetes instalados en el perfil de usuario
function nix-list-user
    echo "📦 Paquetes instalados en perfil de usuario:"
    nix-env -q
end

# Verificar dependencias rotas
function nixos-verify
    echo "🔍 Verificando integridad del store..."
    nix-store --verify --check-contents
end

# Mostrar ruta de un paquete
function nixos-path
    if test (count $argv) -eq 0
        echo "Uso: nixos-path <paquete>"
        return 1
    end

    nix-build '<nixpkgs>' -A $argv[1] --no-out-link
end

# Información resumida del sistema
function nixos-info-system
    echo "╔════════════════════════════════════════╗"
    echo "║       INFORMACIÓN DEL SISTEMA          ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "📌 Versión NixOS:"
    nixos-version
    echo ""
    echo "🔢 Generación actual:"
    readlink /nix/var/nix/profiles/system | grep -o '[0-9]*'
    echo ""
    echo "💾 Tamaño del store:"
    du -sh /nix/store 2>/dev/null
    echo ""
    echo "🗂️  Total de generaciones:"
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | wc -l
end

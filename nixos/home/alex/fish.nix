{ config, pkgs, ... }:
{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
          set -g fish_greeting ""
        '';
      shellAliases = {
        #SUDO HELIX
        shx = "sudo hx -c $HOME/.config/helix/config.toml";

        #RESPALDO
        respaldo-nixos = "cp -r /etc/nixos/ $HOME/.config/";

        # SSH
        ssh-keygen = "ssh-keygen -t ed25519 -C 'alexander6432@gmail.com'";
        ssh-testgithub = "ssh -T git@github.com";

        # REBUILDS DE NIXOS
        nixos-switch = "sudo nixos-rebuild switch --flake /etc/nixos"; # Aplica cambios de configuración y los hace predeterminados en el bootloader
        nixos-boot = "sudo nixos-rebuild boot --flake /etc/nixos"; # Aplica cambios solo para el próximo reinicio (no afecta el sistema actual)
        nixos-test = "sudo nixos-rebuild test --flake /etc/nixos"; # Aplica cambios temporalmente sin afectar el bootloader (para pruebas)
        nixos-build = "sudo nixos-rebuild build --flake /etc/nixos"; # Solo construye el sistema sin activarlo (útil para verificar que compila)
        nixos-dry = "sudo nixos-rebuild dry-build --flake /etc/nixos"; # Muestra qué se construirá sin construir realmente (simulación)
        nixos-rollback = "sudo nixos-rebuild switch --rollback"; # Vuelve a la generación anterior inmediatamente
        nixos-upgrade = "sudo nixos-rebuild switch --flake /etc/nixos --upgrade"; # Actualiza los canales y aplica cambios (actualización completa)

        # OPERACIONES DE FLAKES
        flake-update = "sudo nix flake update --flake /etc/nixos"; # Actualiza el flake.lock (actualiza todas las dependencias del flake)
        flake-check = "sudo nix flake check --flake /etc/nixos"; # Verifica que el flake sea válido y no tenga errores
        flake-show = "sudo nix flake show --flake /etc/nixos"; # Muestra los outputs disponibles del flake (paquetes, sistemas, etc.)
        flake-lock = "sudo nix flake lock --flake /etc/nixos"; # Regenera el flake.lock sin actualizar (útil si se corrompió)
        flake-metadata = "sudo nix flake metadata --fleke /etc/nixos"; # Muestra metadata del flake (descripción, última modificación, inputs)

        # LIMPIEZA Y OPTIMIZACIÓN
        nix-trash = "sudo nix-collect-garbage -d"; # Borra todas las generaciones antiguas excepto la actual (libera mucho espacio)
        nix-optimize = "sudo nix-store --optimize"; # Optimiza el store creando hardlinks de archivos duplicados (ahorra espacio)
        nix-clean = "sudo nix-collect-garbage --delete-older-than 30d && sudo nix-store --optimize"; # Limpieza completa: borra generaciones de 30+ días y optimiza
        nix-genclean = "sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system"; # Mantiene solo las últimas 5 generaciones del sistema
        nix-oldclean = "sudo nix-collect-garbage --delete-older-than 7d"; # Borra generaciones de más de 7 días (limpieza más agresiva)

        # INFORMACIÓN DE GENERACIONES
        nixos-gens = "nixos-rebuild list-generations"; # Lista todas las generaciones del sistema con fechas
        nixos-current = "readlink /run/current-system"; # Muestra la ruta del sistema actual en ejecución

        # BÚSQUEDA Y CONSULTA
        nix-search = "nix search nixpkgs"; # Busca paquetes en nixpkgs (ej: nix-search firefox)
        nix-why = "nix why-depends /run/current-system"; # Muestra por qué un paquete es dependencia del sistema actual
        nixos-option = "nixos-option"; # Busca y muestra el valor de opciones de configuración

        # INFORMACIÓN DEL STORE
        nix-roots = "nix-store --gc --print-roots | grep -v '/proc/'"; # Lista las raíces de GC (qué mantiene vivos los paquetes en el store)
        nix-dead = "nix-store --gc --print-dead"; # Muestra qué paquetes se pueden eliminar (no están en uso)
        nix-live = "nix-store --gc --print-live"; # Muestra qué paquetes están activamente en uso

        # EDICIÓN DE CONFIGURACIÓN
        nixos-edit = "sudo hx -c $HOME/.config/helix/cofig.toml /etc/nixos/configuration.nix"; # Abre el archivo de configuración principal con tu editor
        nixos-config = "cd /etc/nixos"; # Cambia al directorio de configuración de NixOS

        # INFORMACIÓN DEL SISTEMA
        nixos-version = "nixos-version"; # Muestra la versión actual de NixOS
        nix-info = "nix-info -m"; # Muestra información detallada del sistema (útil para reportar bugs)

        # SHELLS Y ENTORNOS TEMPORALES
        nix-shell = "nix-shell -p"; # Crea un shell temporal con paquetes (ej: nix-shell gcc)
        nix-run = "nix run nixpkgs#"; # Ejecuta un programa sin instalarlo (ej: nix-run firefox)

        # BUILD LOCAL
        nix-build = "nix-build"; # Construye un paquete desde un nix file
        nix-develop = "nix develop"; # Entra en el entorno de desarrollo de un flake
      };
      functions = {
        yy = ''
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
        	yazi $argv --cwd-file="$tmp"
        	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        		builtin cd -- "$cwd"
        	end
        	rm -f -- "$tmp"
          '';
        # Muestra el tamaño total del store y los 20 paquetes más grandes
        nixos-size = ''
          echo "=== Tamaño de /nix/store ==="
          du -sh /nix/store
          echo ""
          echo "=== Top 20 paquetes más grandes ==="
          nix path-info -rsSh /run/current-system 2>/dev/null | sort -hk2 | tail -20
        '';
        # Compara dos generaciones específicas (ej: nixos-diff 42 43)
        # Útil para ver qué cambió entre versiones del sistema
        nixos-diff = ''
          if test (count $argv) -ne 2
            echo "Uso: nixos-diff <gen1> <gen2>"
            echo "Ejemplo: nixos-diff 42 43"
            return 1
          end
          nix store diff-closures /nix/var/nix/profiles/system-$argv[1]-link /nix/var/nix/profiles/system-$argv[2]-link
        '';
        # Compara automáticamente la generación actual con la anterior
        # Muestra qué paquetes se agregaron, actualizaron o eliminaron
        nixos-diff-last = ''
          set -l current (readlink /nix/var/nix/profiles/system | grep -o '[0-9]*')
          set -l previous (math $current - 1)
          echo "Comparando generación $previous → $current"
          nix store diff-closures /nix/var/nix/profiles/system-$previous-link /nix/var/nix/profiles/system-$current-link
        '';
        # Verifica que la configuración compile antes de aplicarla
        # Si hay errores, no se aplican cambios (evita romper el sistema)
        nixos-safe-switch = ''
          echo "🔍 Verificando configuración..."
          if sudo nixos-rebuild dry-build --flake /etc/nixos
            echo "✅ Build exitoso, aplicando cambios..."
            sudo nixos-rebuild switch --flake /etc/nixos
          else
            echo "❌ Error en build, no se aplicaron cambios"
            return 1
          end
        '';
        # Actualiza todo el sistema de forma completa y limpia
        # 1. Actualiza flake, 2. Verifica, 3. Aplica, 4. Limpia, 5. Optimiza
        nixos-full-update = ''
          echo "📦 Actualizando flake..."
          nix flake update /etc/nixos
          echo ""
          echo "🔧 Verificando configuración..."
          nix flake check /etc/nixos
          echo ""
          echo "🚀 Rebuilding sistema..."
          sudo nixos-rebuild switch --flake /etc/nixos --upgrade
          echo ""
          echo "🧹 Limpiando generaciones antiguas..."
          sudo nix-collect-garbage --delete-older-than 30d
          echo ""
          echo "⚡ Optimizando store..."
          sudo nix-store --optimize
          echo ""
          echo "✨ ¡Sistema actualizado completamente!"
        '';
        # Encuentra qué paquete provee un comando específico
        # Requiere tener nix-index instalado (nixos.nix-index)
        nixos-which = ''
          if test (count $argv) -eq 0
            echo "Uso: nixos-which <comando>"
            echo "Ejemplo: nixos-which gcc"
            return 1
          end
          nix-locate --top-level --whole-name --type x --type s --at-root "/bin/$argv[1]"
        '';
        # Busca opciones de configuración disponibles
        # Útil para descubrir configuraciones (ej: nixos-search-option "services.nginx")
        nixos-search-option = ''
          if test (count $argv) -eq 0
            echo "Uso: nixos-search-option <término>"
            echo "Ejemplo: nixos-search-option networking"
            return 1
          end
          nixos-option -r $argv[1]
        '';
        # Lista todos los paquetes instalados en el sistema actual
        # Muestra solo los nombres sin la ruta completa del store
        nixos-list-packages = ''
          nix-store -q --references /run/current-system/sw | sed 's/.*-//'
        '';
        # Muestra el árbol de dependencias de un paquete
        # Útil para ver qué necesita un paquete para funcionar
        nixos-deps = ''
          if test (count $argv) -eq 0
            echo "Uso: nixos-deps <ruta-paquete>"
            echo "Ejemplo: nixos-deps /nix/store/...-firefox-120.0"
            return 1
          end
          nix-store -q --tree $argv[1]
        '';
        # Muestra qué otros paquetes usan/dependen de un paquete específico
        # Lo opuesto a nixos-deps (dependencias inversas)
        nixos-refs = ''
          if test (count $argv) -eq 0
            echo "Uso: nixos-refs <ruta-paquete>"
            echo "Ejemplo: nixos-refs /nix/store/...-glibc-2.38"
            return 1
          end
          nix-store -q --referrers $argv[1]
        '';
        # Borra generaciones específicas por número
        # Acepta números individuales o rangos (ej: 1 2 3 o 1..10)
        nixos-delete-gen = ''
          if test (count $argv) -eq 0
            echo "Uso: nixos-delete-gen <número(s)>"
            echo "Ejemplo: nixos-delete-gen 1 2 3"
            echo "Ejemplo: nixos-delete-gen 1..10"
            return 1
          end
          sudo nix-env --delete-generations $argv --profile /nix/var/nix/profiles/system
          sudo nixos-rebuild switch --flake /etc/nixos
        '';
        # Cambia a una generación específica del sistema
        # Útil para volver a una configuración anterior sin hacer rollback completo
        nixos-go-gen = ''
          if test (count $argv) -ne 1
            echo "Uso: nixos-go-gen <número>"
            echo "Ejemplo: nixos-go-gen 42"
            return 1
          end
          sudo nix-env --switch-generation $argv[1] --profile /nix/var/nix/profiles/system
          sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
        '';
        # Verifica la integridad de todos los archivos en el nix store
        # Detecta corrupción de datos
        nixos-verify = ''
          echo "🔍 Verificando integridad del store..."
          nix-store --verify --check-contents
        '';
        # Repara archivos corruptos en el store
        # Re-descarga o reconstruye archivos dañados
        nixos-repair = ''
          echo "🔧 Reparando store..."
          nix-store --verify --check-contents --repair
        '';
        # Muestra los últimos 100 logs del servicio nixos-rebuild
        # Útil para debuggear problemas en builds anteriores
        nixos-log = ''
          journalctl -u nixos-rebuild -n 100 --no-pager
        '';
        # Crea un backup timestamped de toda la configuración en ~/nixos-backups/
        # Útil antes de hacer cambios grandes
        nixos-backup = ''
          set -l backup_dir ~/nixos-backups/(date +%Y%m%d_%H%M%S)
          mkdir -p $backup_dir
          sudo cp -r /etc/nixos/* $backup_dir/
          echo "✅ Backup creado en: $backup_dir"
        '';
      };
    };
  };
}

#!/bin/bash

# Diretórios monitorados
DIRS="/tmp /var/tmp"

# Arquivo de log
LOGFILE="/var/log/symlink-monitor.log"

# Cores para terminal
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m" # No Color

# Verifica se inotifywait está instalado
if ! command -v inotifywait &> /dev/null; then
    echo -e "${RED}[ERRO] inotifywait não encontrado. Instale com: sudo apt install inotify-tools${NC}"
    exit 1
fi

# Função para registrar eventos
log_event() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$LOGFILE"
    if [ -t 1 ]; then
        echo -e "${YELLOW}$msg${NC}"
    fi
}

# Início
log_event "✅ Monitoramento iniciado em: $DIRS"

# Loop de monitoramento
inotifywait -m -e create,move,delete --format '%e %w%f' $DIRS | while read event file; do
    case "$event" in
        CREATE|MOVED_TO)
            if [ -L "$file" ]; then
                target=$(readlink "$file")
                log_event "⚠️  Symlink detectado: $file -> $target"
            fi
            ;;
        DELETE)
            # Se for symlink deletado, avisa também
            log_event "❌ Symlink removido: $file"
            ;;
    esac
done

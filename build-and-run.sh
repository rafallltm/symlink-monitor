#!/bin/bash

# Cria o Dockerfile
cat <<EOF > Dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y inotify-tools
COPY monitor_symlinks.sh /app/
WORKDIR /app
RUN chmod +x monitor_symlinks.sh
CMD ["./monitor_symlinks.sh"]
EOF

echo "[✔️] Dockerfile criado."

# Constrói a imagem
docker build -t symlink-monitor .
echo "[✔️] Imagem Docker 'symlink-monitor' criada."

# Executa o contêiner com acesso ao /tmp real e log
docker run -it --rm \
  -v /tmp:/tmp \
  -v /var/tmp:/var/tmp \
  -v /var/log:/var/log \
  --name symlink-watchdog \
  symlink-monitor

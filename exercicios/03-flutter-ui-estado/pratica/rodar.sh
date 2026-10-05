#!/bin/bash
# Roda o app no Chrome, na porta FIXA 5300 (o cache offline fica no navegador, por porta).
# Mac/Linux:  ./rodar.sh      No terminal: r = hot reload · R = hot restart · q = sair
cd "$(dirname "$0")" || exit 1
ls lib > /dev/null || { echo "Não achei a pasta lib/ — rode este script de dentro de exercicios/03-flutter-ui-estado/pratica"; exit 1; }
exec flutter run -d chrome --web-port 5300

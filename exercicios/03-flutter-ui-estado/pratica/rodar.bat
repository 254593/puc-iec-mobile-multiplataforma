@echo off
REM Roda o app no Chrome, na porta FIXA 5300 (o cache offline fica no navegador, por porta).
REM No terminal: r = hot reload / R = hot restart / q = sair
cd /d "%~dp0"
if not exist lib (
  echo Nao achei a pasta lib\ - rode este arquivo de dentro de exercicios\03-flutter-ui-estado\pratica
  exit /b 1
)
flutter run -d chrome --web-port 5300

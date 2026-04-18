#!/bin/bash
set -e

echo "🚀 Iniciando despliegue a GitHub Pages..."

# Preparar deploy
echo "📤 Preparando archivos..."
rm -rf /tmp/deploy 2>/dev/null || true
mkdir -p /tmp/deploy
cp -r dist/* /tmp/deploy/

# Cambiar a gh-pages
echo "🔄 Cambiando a rama gh-pages..."
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git checkout gh-pages

# Copiar archivos
echo "📁 Copiando archivos compilados..."
git rm -rf . 2>/dev/null || true
cp -r /tmp/deploy/* .
git add .

# Commit y push
echo "💾 Confirmando cambios..."
git commit -m "Deploy: $(date '+%Y-%m-%d %H:%M:%S')" || echo "Sin cambios nuevos, branch up to date"

echo "☁️ Enviando a GitHub Pages..."
git push origin gh-pages

# Regresar a rama original
echo "🔙 Regresando a rama $CURRENT_BRANCH..."
git checkout $CURRENT_BRANCH

echo ""
echo "✅ ¡Despliegue completado exitosamente!"
echo "🌐 Tu app está en: https://marlonchca3.github.io/horariosMisa.github.io/"
echo ""

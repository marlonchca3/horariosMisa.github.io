#!/bin/bash

echo "🚀 Iniciando despliegue a GitHub Pages..."

# Verificar que el build esté completo
if [ ! -d "dist" ]; then
    echo "❌ Error: carpeta 'dist' no encontrada. Ejecuta 'npm run build' primero."
    exit 1
fi

echo "📤 Preparando archivos..."

# Cambiar a rama gh-pages
git checkout gh-pages || git checkout --orphan gh-pages

# Copiar build a raíz
cp -r dist/* .

# Actualizar git
git add -A
git commit -m "Deploy: Update from main branch" || true

# Enviar a GitHub
git push -u origin gh-pages

# Volver a rama main
git checkout main

echo "✅ Despliegue completado exitosamente"
echo "📍 Tu app está en: https://marlonchca3.github.io/horariosMisa.github.io/"

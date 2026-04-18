# 🚀 Guía de Despliegue

## Opción 1: GitHub Pages (Recomendado)

### Paso 1: Preparar el repositorio

1. Asegúrate de que tu repositorio está en GitHub con el nombre `horariosMisa.github.io`
2. Clona el repositorio localmente

### Paso 2: Configurar Vite para GitHub Pages

Si deseas que la app esté en una ruta específica (ejemplo: `/callao-misas`), actualiza `vite.config.js`:

```javascript
export default defineConfig({
  base: '/horariosMisa.github.io/',  // O la ruta que prefieras
  // ... resto de configuración
})
```

### Paso 3: Compilar la aplicación

```bash
npm install
npm run build
```

Esto generará una carpeta `dist` con los archivos optimizados.

### Paso 4: Desplegar manualmente

**Opción A: Usar GitHub CLI**
```bash
# Si tienes GitHub CLI instalado
gh repo set-default
git branch -D gh-pages 2>/dev/null || true
git checkout --orphan gh-pages
git rm -rf .
cp -r dist/* .
git add .
git commit -m "Deploy app"
git push -u origin gh-pages
git checkout main
```

**Opción B: Usar git tradicional**
```bash
git add dist
git commit -m "Deploy to GitHub Pages"
git push origin main

# Luego, en GitHub:
# 1. Ve a Settings > Pages
# 2. Selecciona "gh-pages" como rama de deploy
# 3. Selecciona "/ (root)" como carpeta
```

### Paso 5: Verificar despliegue

Tu app estará disponible en: `https://tuusuario.github.io/horariosMisa.github.io/`

---

## Opción 2: Despliegue Automático con GitHub Actions

Ya incluimos un workflow en `.github/workflows/deploy.yml`. Simplemente:

1. Haz push a la rama `main`
2. GitHub Actions automáticamente compilará y desplegará en `gh-pages`
3. Tu app se actualizará automáticamente en `gh-pages`

---

## Opción 3: Netlify

### Paso 1: Conectar repositorio

1. Ve a [netlify.com](https://netlify.com)
2. Haz clic en "New site from Git"
3. Selecciona GitHub y autoriza
4. Busca y selecciona tu repositorio

### Paso 2: Configurar build

- **Build command**: `npm run build`
- **Publish directory**: `dist`

### Paso 3: Desplegar

Netlify automáticamente desplegará cualquier push a `main`.

---

## Opción 4: Vercel

### Paso 1: Importar proyecto

```bash
vercel
```

O ve a [vercel.com](https://vercel.com) y haz clic en "New Project" > "Import Git Repository"

### Paso 2: Configurar

Vercel detectará automáticamente que es un proyecto Vite/Vue.

### Paso 3: Desplegar

Tu app estará en: `https://horarios-misa.vercel.app/`

---

## Opción 5: Servidor Personal (Apache/Nginx)

### Con Apache:

1. Compila: `npm run build`
2. Copia contenido de `dist/` a `/var/www/html/`
3. Configura `.htaccess`:
   ```
   <IfModule mod_rewrite.c>
     RewriteEngine On
     RewriteBase /
     RewriteRule ^index\.html$ - [L]
     RewriteCond %{REQUEST_FILENAME} !-f
     RewriteCond %{REQUEST_FILENAME} !-d
     RewriteRule . /index.html [L]
   </IfModule>
   ```

### Con Nginx:

1. Compila: `npm run build`
2. Copia contenido de `dist/` a `/usr/share/nginx/html/`
3. Configura nginx.conf:
   ```nginx
   server {
     listen 80;
     server_name tu-dominio.com;
     root /usr/share/nginx/html;
     index index.html;
     
     location / {
       try_files $uri $uri/ /index.html;
     }
   }
   ```

---

## Troubleshooting

**Problema**: Los estilos no se cargan correctamente
- **Solución**: Verifica que el `base` en `vite.config.js` coincida con tu ruta de despliegue

**Problema**: La geolocalización no funciona
- **Solución**: La geolocalización requiere HTTPS. Algunos deployments como GitHub Pages ya incluyen HTTPS

**Problema**: Las notificaciones no aparecen
- **Solución**: El usuario debe dar permisos. El navegador solicitará automáticamente en la primera carga

**Problema**: Error 404 al recargar la página
- **Solución**: Asegúrate que tu servidor redirija todas las rutas a `index.html` (SPA configuration)

---

## Dominio personalizado

Para usar tu propio dominio (example: misas-callao.com):

### GitHub Pages:
1. Ve a Settings > Pages
2. En "Custom domain", ingresa tu dominio
3. Configura tu DNS:
   ```
   CNAME misas-callao.com -> tuusuario.github.io
   ```

### Netlify/Vercel:
Sigue las instrucciones en sus dashboards para conectar dominio personalizado.

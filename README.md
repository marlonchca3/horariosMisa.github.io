# Horarios de Misa - Callao 🙏

Una aplicación web en Vue 3 que muestra los horarios de misas de iglesias del Callao y detecta la iglesia más cercana a tu ubicación actual.

## Características

✨ **Geolocalización**: Detecta automáticamente tu ubicación y encuentra la iglesia más cercana
⛪ **Base de datos de iglesias**: Incluye 6 iglesias del Callao con horarios completos
📱 **Responsive**: Optimizado para dispositivos móviles y de escritorio
🔔 **Notificaciones**: Recibe notificaciones cuando detectes tu ubicación
🔍 **búsqueda**: Busca iglesias por nombre o ubicación
⏰ **Horarios diarios**: Ve los horarios de misas según el día de la semana

## Instalación

### Requisitos
- Node.js 16+ 
- npm o yarn

### Pasos

1. **Clonar el repositorio**
```bash
git clone https://github.com/tuusuario/horariosMisa.github.io.git
cd horariosMisa.github.io
```

2. **Instalar dependencias**
```bash
npm install
```

3. **Ejecutar en desarrollo**
```bash
npm run dev
```

La aplicación estará disponible en `http://localhost:5173`

## Compilar para producción

```bash
npm run build
```

Los archivos optimizados se generarán en la carpeta `dist/`.

## Uso

1. Abre la aplicación en tu navegador
2. Haz clic en el botón **"📍 Detectar mi ubicación"**
3. Otorga permisos de localización cuando se solicite
4. La aplicación mostrará:
   - Tu ubicación actual
   - La iglesia más cercana con sus horarios de hoy
   - Un listado completo de todas las iglesias con distancias

## Iglesias Incluidas

1. **Catedral del Callao** - Plaza Matriz
2. **Iglesia San Felipe** - Av. Sáenz Peña
3. **Iglesia Santa Rosa** - Jr. Huancavelica
4. **Iglesia Sagrado Corazón** - Av. Mil Viviendas
5. **Iglesia San Martín** - Av. Colón
6. **Iglesia San Pedro** - Av. Guardia Chalaca

## Personalización

### Agregar más iglesias

Edita el archivo `src/data/churches.js` y añade nuevas iglesias siguiendo el formato:

```javascript
{
  id: 7,
  name: "Nombre de la Iglesia",
  location: "Dirección completa",
  latitude: -12.0000,
  longitude: -77.0000,
  horarios: [
    { dia: "Lunes a Viernes", horas: ["07:00", "18:00"] },
    { dia: "Sábado", horas: ["07:00", "17:00"] },
    { dia: "Domingo", horas: ["07:00", "08:00", "10:00", "18:00"] }
  ]
}
```

### Modificar estilos

Edita los estilos en el bloque `<style scoped>` de `src/App.vue`.

## Tecnologías

- **Vue 3** - Framework progresivo
- **Vite** - Herramienta de build rápida
- **Geolocation API** - Para detectar ubicación
- **Notification API** - Para notificaciones del navegador

## Navegadores soportados

- Chrome/Edge 60+
- Firefox 55+
- Safari 12.1+
- Opera 47+

## Deployment

### GitHub Pages

1. Actualiza `vite.config.js` con tu repositorio:
```javascript
export default defineConfig({
  base: '/horariosMisa.github.io/'
})
```

2. Compila:
```bash
npm run build
```

3. Haz push a la rama `gh-pages`:
```bash
git add dist
git commit -m "Deploy"
git push origin gh-pages
```

## Licencia

MIT - Libre para usar y modificar

## Contribuciones

Las contribuciones son bienvenidas. Para cambios significativos, abre un issue primero.

## Autor

Creado con ❤️ para la comunidad del Callao

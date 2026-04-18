<template>
  <div class="map-container">
    <div id="cesium-map" ref="cesiumContainer"></div>
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import * as Cesium from 'cesium'

const props = defineProps({
  userLocation: Object,
  churches: Array,
  nearestChurch: Object
})

const cesiumContainer = ref(null)
let viewer = null

onMounted(() => {
  initializeCesium()
})

function initializeCesium() {
  Cesium.Ion.defaultAccessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI2ZGY4MDBjNi0xNzZhLTQzMzktODM0ZC01OTA4ZjFhMjA4OTUiLCJpZCI6MTc2MzMzLCJpYXQiOjE3MTI0MDczNzUsImV4cCI6MTc0Mzk0MzM3NSwic2NvcGVzIjpbImFzciIsImdjIl0sInNyYyI6ImVzcGsiLCJzbm9uIjoiU1BPIiwic3AiOlsibWFwcyIsIm9zbSJdLCJzYnMiOlsiZGVtbyIsIm1hcHMiXX0.wQk0a-0kiwPPfQrLUglSRKCJLhYTAMQdXNgfUKPcTSU'
  
  viewer = new Cesium.Viewer(cesiumContainer.value, {
    terrain: Cesium.Terrain.fromWorldTerrain(),
    timeline: false,
    animation: false,
    homeButton: false,
    fullscreenButton: false,
    vrButton: false
  })

  viewer.cesiumWidget.creditContainer.style.display = 'none'
  
  // Coordenadas del Callao
  const callaoLat = -12.0432
  const callaoLon = -77.0281
  
  viewer.camera.setView({
    destination: Cesium.Cartesian3.fromDegrees(callaoLon, callaoLat, 15000)
  })
}

watch(
  () => props.churches,
  (churches) => {
    if (!viewer || !churches) return
    
    // Limpiar entidades previas
    viewer.entities.removeAll()
    
    // Agregar iglesias como puntos
    churches.forEach((church) => {
      viewer.entities.add({
        position: Cesium.Cartesian3.fromDegrees(church.longitude, church.latitude),
        point: {
          pixelSize: 10,
          color: Cesium.Color.BLUE,
          outlineColor: Cesium.Color.WHITE,
          outlineWidth: 2
        },
        label: {
          text: church.name,
          font: '12px sans-serif',
          backgroundColor: Cesium.Color.fromCssColorString('rgba(0, 0, 0, 0.7)'),
          backgroundPadding: new Cesium.Cartesian2(8, 4),
          pixelOffset: new Cesium.Cartesian2(0, -20)
        }
      })
    })
  },
  { deep: true }
)

watch(
  () => props.userLocation,
  (location) => {
    if (!viewer || !location) return
    
    // Agregar punto de usuario
    viewer.entities.add({
      position: Cesium.Cartesian3.fromDegrees(location.longitude, location.latitude),
      point: {
        pixelSize: 15,
        color: Cesium.Color.RED,
        outlineColor: Cesium.Color.WHITE,
        outlineWidth: 3
      },
      label: {
        text: 'Tu Ubicación',
        font: 'bold 12px sans-serif',
        backgroundColor: Cesium.Color.fromCssColorString('rgba(255, 0, 0, 0.7)'),
        backgroundPadding: new Cesium.Cartesian2(8, 4),
        pixelOffset: new Cesium.Cartesian2(0, -20)
      }
    })
    
    // Centrar en la ubicación del usuario
    viewer.camera.setView({
      destination: Cesium.Cartesian3.fromDegrees(location.longitude, location.latitude, 15000),
      duration: 1
    })
  }
)

watch(
  () => props.nearestChurch,
  (church) => {
    if (!viewer || !church) return
    
    // Agregar la iglesia más cercana con color diferente
    viewer.entities.add({
      position: Cesium.Cartesian3.fromDegrees(church.longitude, church.latitude),
      point: {
        pixelSize: 20,
        color: Cesium.Color.YELLOW.withAlpha(0.8),
        outlineColor: Cesium.Color.ORANGE,
        outlineWidth: 4
      },
      label: {
        text: '⭐ ' + church.name,
        font: 'bold 14px sans-serif',
        backgroundColor: Cesium.Color.fromCssColorString('rgba(255, 165, 0, 0.8)'),
        backgroundPadding: new Cesium.Cartesian2(8, 4),
        pixelOffset: new Cesium.Cartesian2(0, -25)
      }
    })
  }
)
</script>

<style scoped>
.map-container {
  width: 100%;
  height: 400px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  margin-bottom: 30px;
}

#cesium-map {
  width: 100%;
  height: 100%;
}
</style>

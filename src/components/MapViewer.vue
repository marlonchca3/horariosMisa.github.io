<template>
  <div class="map-container">
    <div id="cesium-container" ref="cesiumContainer"></div>
    <div v-if="mapError" class="map-error">⚠️ {{ mapError }}</div>
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'

const props = defineProps({
  userLocation: Object,
  churches: Array,
  nearestChurch: Object
})

const cesiumContainer = ref(null)
const mapError = ref('')
let viewer = null
let Cesium = null

const initializeCesium = async () => {
  try {
    if (!window.CESIUM_BASE_URL && cesiumContainer.value) {
      window.CESIUM_BASE_URL = 'https://cesium.com/downloads/unpackaged/'
    }
    
    Cesium = window.Cesium || (await import('cesium')).default || await import('cesium')
    
    if (!Cesium) {
      throw new Error('Cesium no se pudo cargar')
    }

    Cesium.Ion.defaultAccessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI2ZGY4MDBjNi0xNzZhLTQzMzktODM0ZC01OTA4ZjFhMjA4OTUiLCJpZCI6MTc2MzMzLCJpYXQiOjE3MTI0MDczNzUsImV4cCI6MTc0Mzk0MzM3NSwic2NvcGVzIjpbImFzciIsImdjIl0sInNyYyI6ImVzcGsiLCJzbm9uIjoiU1BPIiwic3AiOlsibWFwcyIsIm9zbSJdLCJzYnMiOlsiZGVtbyIsIm1hcHMiXX0.wQk0a-0kiwPPfQrLUglSRKCJLhYTAMQdXNgfUKPcTSU'
    
    viewer = new Cesium.Viewer(cesiumContainer.value, {
      terrain: Cesium.Terrain.fromWorldTerrain(),
      timeline: false,
      animation: false,
      homeButton: false,
      fullscreenButton: true,
      vrButton: false,
      navigationHelpButton: false,
      baseLayerPicker: false,
      geocoder: false
    })

    viewer.cesiumWidget.creditContainer.style.display = 'none'
    
    const callaoLat = -12.0432
    const callaoLon = -77.0281
    
    viewer.camera.flyTo({
      destination: Cesium.Cartesian3.fromDegrees(callaoLon, callaoLat, 20000),
      duration: 2
    })
  } catch (error) {
    mapError.value = error.message
    console.error('Error inicializando Cesium:', error)
  }
}

const addChurches = async () => {
  if (!viewer || !props.churches) return
  
  viewer.entities.removeAll()
  
  props.churches.forEach((church) => {
    viewer.entities.add({
      position: Cesium.Cartesian3.fromDegrees(church.longitude, church.latitude),
      point: {
        pixelSize: 12,
        color: Cesium.Color.BLUE,
        outlineColor: Cesium.Color.WHITE,
        outlineWidth: 2
      },
      label: {
        text: church.name,
        font: '11px sans-serif',
        showBackground: true,
        backgroundColor: Cesium.Color.fromCssColorString('rgba(0, 0, 0, 0.8)'),
        backgroundPadding: new Cesium.Cartesian2(6, 3),
        pixelOffset: new Cesium.Cartesian2(0, -25)
      }
    })
  })
}

const addUserLocation = async () => {
  if (!viewer || !props.userLocation) return
  
  viewer.entities.add({
    position: Cesium.Cartesian3.fromDegrees(props.userLocation.longitude, props.userLocation.latitude),
    point: {
      pixelSize: 18,
      color: Cesium.Color.RED,
      outlineColor: Cesium.Color.WHITE,
      outlineWidth: 3
    },
    label: {
      text: '📍 Tu Ubicación',
      font: 'bold 12px sans-serif',
      showBackground: true,
      backgroundColor: Cesium.Color.fromCssColorString('rgba(255, 0, 0, 0.8)'),
      backgroundPadding: new Cesium.Cartesian2(6, 3),
      pixelOffset: new Cesium.Cartesian2(0, -30)
    }
  })
  
  viewer.camera.flyTo({
    destination: Cesium.Cartesian3.fromDegrees(props.userLocation.longitude, props.userLocation.latitude, 15000),
    duration: 1.5
  })
}

const addNearestChurch = async () => {
  if (!viewer || !props.nearestChurch) return
  
  viewer.entities.add({
    position: Cesium.Cartesian3.fromDegrees(props.nearestChurch.longitude, props.nearestChurch.latitude),
    point: {
      pixelSize: 22,
      color: Cesium.Color.YELLOW.withAlpha(0.9),
      outlineColor: Cesium.Color.ORANGE,
      outlineWidth: 4
    },
    label: {
      text: '⭐ ' + props.nearestChurch.name,
      font: 'bold 13px sans-serif',
      showBackground: true,
      backgroundColor: Cesium.Color.fromCssColorString('rgba(255, 165, 0, 0.9)'),
      backgroundPadding: new Cesium.Cartesian2(8, 4),
      pixelOffset: new Cesium.Cartesian2(0, -35)
    }
  })
}

onMounted(() => {
  initializeCesium()
})

watch(() => props.churches, addChurches, { deep: true })
watch(() => props.userLocation, addUserLocation, { deep: true })
watch(() => props.nearestChurch, addNearestChurch, { deep: true })
</script>

<style scoped>
.map-container {
  width: 100%;
  height: 500px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  margin-bottom: 30px;
}
</style>

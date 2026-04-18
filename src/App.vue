<template>
  <div class="container">
    <!-- Header -->
    <header class="header">
      <h1>⛪ Horarios de Misa</h1>
      <p class="subtitle">Iglesias del Callao</p>
    </header>

    <!-- Location Section -->
    <section class="location-section">
      <button 
        @click="detectLocation" 
        :disabled="loading"
        class="btn btn-primary"
      >
        <span v-if="!loading">📍 Detectar mi ubicación</span>
        <span v-else>Detectando...</span>
      </button>
      
      <div v-if="error" class="alert alert-error">
        ⚠️ {{ error }}
      </div>

      <div v-if="userLocation" class="location-info">
        <p>📍 Tu ubicación: <strong>{{ userLocation.latitude.toFixed(6) }}, {{ userLocation.longitude.toFixed(6) }}</strong></p>
        <p class="location-details">
          <span v-if="userLocation.accuracy">Precisión: ±{{ userLocation.accuracy.toFixed(0) }}m</span>
          <span v-if="userLocation.altitude"> | Altitud: {{ userLocation.altitude.toFixed(1) }}m</span>
        </p>
      </div>
    </section>

    <!-- Nearest Church Section -->
    <section v-if="nearestChurch" class="nearest-church">
      <h2>⭐ Iglesia Más Cercana</h2>
      <div class="church-card featured">
        <div class="church-header">
          <h3>{{ nearestChurch.name }}</h3>
          <span class="distance">📏 {{ (nearestChurch.distance * 1000).toFixed(0) }}m</span>
        </div>
        <p class="location">📍 {{ nearestChurch.location }}</p>
        <div class="horarios">
          <h4>Horarios de Hoy:</h4>
          <div class="horarios-list">
            <div v-if="todaySchedule" class="schedule-item">
              <strong>{{ todaySchedule.dia }}</strong>
              <div class="times">
                <span v-for="hora in todaySchedule.horas" :key="hora" class="time-badge">
                  ⏰ {{ hora }}
                </span>
              </div>
            </div>
            <p v-else class="no-schedule">Sin horarios para hoy</p>
          </div>
        </div>
      </div>
    </section>

    <!-- All Churches Section -->
    <section class="all-churches">
      <h2>Todas las Iglesias</h2>
      
      <div class="search-bar">
        <input 
          v-model="searchTerm"
          type="text"
          placeholder="🔍 Buscar iglesia..."
          class="search-input"
        >
      </div>

      <div class="churches-grid">
        <div 
          v-for="church in filteredChurches" 
          :key="church.id"
          class="church-card"
          :class="{ 'is-nearest': userLocation && nearestChurch && church.id === nearestChurch.id }"
        >
          <div class="church-header">
            <h3>{{ church.name }}</h3>
            <span v-if="userLocation" class="distance">
              📏 {{ (church.distance * 1000).toFixed(0) }}m
            </span>
          </div>
          
          <p class="location">📍 {{ church.location }}</p>

          <div class="horarios">
            <h4>Horarios:</h4>
            <div class="horarios-list">
              <div v-for="schedule in church.horarios" :key="schedule.dia" class="schedule-item">
                <strong>{{ schedule.dia }}</strong>
                <div class="times">
                  <span v-for="hora in schedule.horas" :key="hora" class="time-badge">
                    {{ hora }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
      <p>📱 Horarios de Misa - Callao © 2024</p>
      <p class="small">Usa tu ubicación para encontrar la iglesia más cercana</p>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { churches } from './data/churches'
import { getCurrentPosition, findNearestChurch, getDayOfWeek, calculateDistance } from './utils/geolocation'

const userLocation = ref(null)
const nearestChurch = ref(null)
const loading = ref(false)
const error = ref('')
const searchTerm = ref('')
const currentDay = ref('')

// Iglesias ordenadas por distancia
const churchesWithDistance = ref(churches)

// Iglesias filtradas por búsqueda
const filteredChurches = computed(() => {
  return churchesWithDistance.value.filter(church =>
    church.name.toLowerCase().includes(searchTerm.value.toLowerCase()) ||
    church.location.toLowerCase().includes(searchTerm.value.toLowerCase())
  )
})

// Horarios de hoy para la iglesia más cercana
const todaySchedule = computed(() => {
  if (!nearestChurch.value) return null
  
  const today = getDayOfWeek()
  
  // Buscar horarios del día actual
  let schedule = nearestChurch.value.horarios.find(h => h.dia === today)
  
  // Si no hay horarios específicos, buscar "Lunes a Viernes", "Sábado", etc.
  if (!schedule && today !== 'Domingo') {
    schedule = nearestChurch.value.horarios.find(h => h.dia === `${today} a ...` || h.dia.includes(today))
    if (!schedule) {
      schedule = nearestChurch.value.horarios.find(h => h.dia === 'Lunes a Viernes')
    }
  }
  
  // Para domingo, buscar horarios específicos
  if (!schedule && today === 'Domingo') {
    schedule = nearestChurch.value.horarios.find(h => h.dia === 'Domingo')
  }
  
  return schedule
})

onMounted(() => {
  currentDay.value = getDayOfWeek()
})

async function detectLocation() {
  loading.value = true
  error.value = ''
  
  try {
    const location = await getCurrentPosition()
    userLocation.value = location

    // Calcular distancias para todos las iglesias
    churchesWithDistance.value = churches.map(church => ({
      ...church,
      distance: calculateDistance(
        location.latitude,
        location.longitude,
        church.latitude,
        church.longitude
      )
    })).sort((a, b) => a.distance - b.distance)

    // Encontrar la iglesia más cercana
    nearestChurch.value = churchesWithDistance.value[0]

    // Notificar al usuario
    try {
      if ('serviceWorker' in navigator && 'Notification' in window && Notification.permission === 'granted') {
        const registration = await navigator.serviceWorker.ready
        registration.showNotification('Iglesia Más Cercana', {
          body: `${nearestChurch.value.name} está a ${(nearestChurch.value.distance * 1000).toFixed(0)}m`,
          icon: '⛪',
          badge: '⛪'
        })
      }
    } catch (notifErr) {
      console.log('Notificación no disponible')
    }
  } catch (err) {
    if (err.code === 1) {
      error.value = 'Permiso de localización denegado. Por favor, habilita el GPS.'
    } else if (err.code === 2) {
      error.value = 'No se puede obtener tu ubicación. Verifica tu conexión GPS.'
    } else if (err.code === 3) {
      error.value = 'La solicitud de ubicación tardó demasiado.'
    } else {
      error.value = 'Error: ' + err.message
    }
  } finally {
    loading.value = false
  }
}

// Solicitar permisos de notificación al cargar
onMounted(() => {
  if ('Notification' in window && Notification.permission === 'default') {
    Notification.requestPermission()
  }
})
</script>

<style scoped>
.container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
}

.header {
  text-align: center;
  color: white;
  margin-bottom: 40px;
  animation: fadeInDown 0.6s ease-out;
}

.header h1 {
  font-size: 3em;
  margin-bottom: 10px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.subtitle {
  font-size: 1.2em;
  opacity: 0.9;
}

.location-section {
  background: white;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  margin-bottom: 30px;
  text-align: center;
  animation: fadeInUp 0.6s ease-out 0.1s both;
}

.btn {
  padding: 12px 30px;
  font-size: 1em;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.alert {
  margin-top: 20px;
  padding: 15px;
  border-radius: 8px;
  font-weight: 500;
}

.alert-error {
  background: #fee;
  color: #c33;
  border-left: 4px solid #c33;
}

.location-info {
  margin-top: 20px;
  padding: 15px;
  background: #f0f4ff;
  border-radius: 8px;
  color: #333;
  font-size: 0.95em;
}

.location-details {
  margin-top: 8px;
  font-size: 0.85em;
  color: #666;
}

.location-details span {
  display: inline-block;
  margin-right: 10px;
}

.nearest-church {
  margin-bottom: 40px;
  animation: fadeInUp 0.6s ease-out 0.2s both;
}

.nearest-church h2 {
  color: white;
  margin-bottom: 20px;
  font-size: 1.8em;
}

.church-card {
  background: white;
  padding: 25px;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  margin-bottom: 20px;
  transition: all 0.3s ease;
}

.church-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.25);
}

.church-card.featured {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: 3px solid gold;
}

.church-card.featured .church-header h3 {
  color: white;
}

.church-card.featured .location {
  color: rgba(255, 255, 255, 0.9);
}

.church-card.is-nearest {
  border-left: 4px solid #667eea;
  background: linear-gradient(to right, #f0f4ff, white);
}

.church-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.church-header h3 {
  margin: 0;
  color: #333;
  font-size: 1.3em;
}

.distance {
  background: #fff3cd;
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 0.85em;
  font-weight: 600;
  color: #856404;
}

.church-card.featured .distance {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

.location {
  color: #666;
  margin: 10px 0 15px 0;
  font-size: 0.95em;
}

.horarios h4 {
  margin-bottom: 12px;
  color: #333;
  font-size: 1em;
}

.church-card.featured .horarios h4 {
  color: white;
}

.horarios-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.schedule-item {
  background: #f5f5f5;
  padding: 12px;
  border-radius: 8px;
}

.church-card.featured .schedule-item {
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

.schedule-item strong {
  display: block;
  margin-bottom: 8px;
  color: #333;
}

.church-card.featured .schedule-item strong {
  color: white;
}

.times {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.time-badge {
  background: #667eea;
  color: white;
  padding: 5px 10px;
  border-radius: 20px;
  font-size: 0.85em;
  font-weight: 500;
}

.church-card.featured .time-badge {
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.5);
}

.no-schedule {
  color: #999;
  font-style: italic;
}

.all-churches {
  animation: fadeInUp 0.6s ease-out 0.3s both;
}

.all-churches h2 {
  color: white;
  margin-bottom: 20px;
  font-size: 1.8em;
}

.search-bar {
  margin-bottom: 20px;
}

.search-input {
  width: 100%;
  padding: 15px 20px;
  font-size: 1em;
  border: none;
  border-radius: 8px;
  background: white;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
}

.churches-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

@media (max-width: 768px) {
  .churches-grid {
    grid-template-columns: 1fr;
  }

  .header h1 {
    font-size: 2em;
  }

  .church-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .distance {
    margin-top: 8px;
  }
}

.footer {
  text-align: center;
  color: white;
  padding: 30px;
  margin-top: 50px;
  opacity: 0.9;
}

.footer .small {
  font-size: 0.9em;
  opacity: 0.8;
}

@keyframes fadeInDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>

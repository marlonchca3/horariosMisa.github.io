/**
 * Obtiene la ubicación actual del usuario
 */
export function getCurrentPosition() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Geolocalización no soportada en este navegador'))
      return
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        resolve({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: position.coords.accuracy,
          altitude: position.coords.altitude
        })
      },
      (error) => {
        reject(error)
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
      }
    )
  })
}

/**
 * Calcula la distancia entre dos puntos usando la fórmula de Haversine
 * Retorna la distancia en kilómetros
 */
export function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371 // Radio de la Tierra en km
  const dLat = (lat2 - lat1) * Math.PI / 180
  const dLon = (lon2 - lon1) * Math.PI / 180
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c
}

/**
 * Encuentra la iglesia más cercana
 */
export function findNearestChurch(userLocation, churches) {
  return churches
    .map(church => ({
      ...church,
      distance: calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        church.latitude,
        church.longitude
      )
    }))
    .sort((a, b) => a.distance - b.distance)[0]
}

/**
 * Obtiene el día de la semana actual en español
 */
export function getDayOfWeek() {
  const days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
  return days[new Date().getDay()]
}


export function groupSaldo (groupId, settings, stationVisits) {
  if (!settings) return 0
  return settings.starterCash + stationExpenses(groupId, stationVisits)
}

function stationExpenses (groupId, stationVisits) {
  if (!stationVisits) return 0
  return firstVisitsByStation(stationVisits).filter(visit => visit.group.id === groupId).reduce((total, visit) => total - visit.station.value, 0)
}

function firstVisitsByStation (stationVisits) {
  return Array.from(stationVisits.reduceRight((map, visit) => map.set(visit.station.id, visit), new Map()).values())
}


export function groupSaldo (groupId, settings, stationVisits) {
  if (!settings) return 0
  return settings.starterCash +
    stationExpenses(groupId, stationVisits, settings)
}

function stationExpenses (groupId, stationVisits, settings) {
  if (!stationVisits || !settings) return 0
  let buyingVisits = firstVisitsByStation(stationVisits).filter(visit => visit.group.id === groupId)
  let boughtStationIds = buyingVisits.map(visit => visit.station.id)
  let payingVisits = stationVisits.filter(visit => visit.group.id === groupId).filter(visit => !boughtStationIds.includes(visit.station.id))
  let payeeVisits = stationVisits.filter(visit => visit.group.id !== groupId).filter(visit => boughtStationIds.includes(visit.station.id))
  console.log(buyingVisits, payingVisits, payeeVisits)
  return -buyingCost(buyingVisits) - rentAmount(payingVisits, settings.rentRate) + rentAmount(payeeVisits, settings.rentRate)
}

function firstVisitsByStation (stationVisits) {
  return Array.from(stationVisits.reduceRight((map, visit) => map.set(visit.station.id, visit), new Map()).values())
}

function buyingCost (visits) {
  return visits.reduce((total, visit) => total + visit.station.value, 0)
}

function rentAmount (visits, rentRate) {
  return visits.reduce((total, visit) => total + visit.station.value * rentRate, 0)
}

export function stationOwners (stationVisits) {
  return stationVisits.reduceRight((map, visit) => map.set(visit.station.id, visit.group.id), new Map())
}

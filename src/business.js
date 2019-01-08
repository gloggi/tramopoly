
export function groupSaldo (groupId, settings, stationVisits, jokerVisits, now = new Date()) {
  if (!settings) return 0
  return settings.starterCash +
    stationExpenses(groupId, stationVisits, settings, now) +
    jokerIncome(groupId, jokerVisits, now)
}

export function stationOwners (stationVisits, now = new Date()) {
  return filter(stationVisits, now).reduceRight((map, visit) => map.set(visit.station.id, visit.group.id), new Map())
}

function stationExpenses (groupId, stationVisits, settings, now) {
  if (!stationVisits || !settings) return 0
  let visits = filter(stationVisits, now)
  let buyingVisits = firstVisitsByStation(visits).filter(visit => visit.group.id === groupId)
  let boughtStationIds = buyingVisits.map(visit => visit.station.id)
  let payingVisits = visits.filter(visit => visit.group.id === groupId).filter(visit => !boughtStationIds.includes(visit.station.id))
  let payeeVisits = visits.filter(visit => visit.group.id !== groupId).filter(visit => boughtStationIds.includes(visit.station.id))
  return -buyingCost(buyingVisits) - rentAmount(payingVisits, settings.rentRate) + rentAmount(payeeVisits, settings.rentRate) + interestAmount(buyingVisits, settings.interestPeriod, settings.interestRate, settings.gameEnd, now)
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

function interestAmount (visits, period, rate, gameEnd, now) {
  return Math.round(visits.map(visit => (Math.min(now, gameEnd.toDate()) - visit.time.toDate()) / 60000.0 / period * rate * visit.station.value).reduce((sum, stationInterest) => sum + stationInterest, 0.0))
}

function jokerIncome (groupId, jokerVisits, now) {
  if (!jokerVisits) return 0
  return filter(jokerVisits, now).filter(visit => visit.group.id === groupId).reduce((sum, visit) => sum + visit.station.value, 0)
}

function filter (visits, now) {
  return visits.filter(visit => visit.time.toDate() <= now)
}


export function groupSaldo (groupId, settings, stationVisits) {
  if (!settings) return 0
  return settings.starterCash + stationExpenses(groupId, stationVisits)
}

function stationExpenses (groupId, stationVisits) {
  if (!stationVisits) return 0
  return uniqueByStation(stationVisits.filter(visit => ownedBy(visit.station.id, groupId, stationVisits)))
    .reduce((total, visit) => total - visit.station.value, 0)
}

function ownedBy (stationId, groupId, stationVisits) {
  var firstVisit = stationVisits.find(visit => visit.station.id === stationId)
  return firstVisit && firstVisit.group.id === groupId
}

function uniqueByStation (stationVisits) {
  var unique = {}
  var distinct = []
  stationVisits.forEach(visit => {
    if (unique[visit.station.id] === undefined) {
      distinct.push(visit)
      unique[visit.station.id] = 0
    }
  })
  return distinct
}

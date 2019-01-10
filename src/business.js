
export function renderMrTLocation (mrT, now) {
  if (!mrT || mrT.disabled) return 'Käinä wäiss es so rächt...'
  let text = 'Dä Mr. T isch zletscht '
  if (mrT.time) {
    text = text + 'vor ' + renderDurationInMinutes(now - mrT.time.toDate()) + ' Minutä '
  }
  if (mrT.vehicle) {
    if (/^[a-zäöü]/i.test(mrT.vehicle.match())) {
      text = text + 'i dä ' + mrT.vehicle + ' '
    } else if (parseInt(mrT.vehicle > 17)) {
      text = text + 'im ' + mrT.vehicle + 'er '
    } else {
      text = text + 'im ' + mrT.vehicle + 'i '
    }
  }
  if (mrT.lastKnownStop) {
    text = text + 'bi ' + mrT.lastKnownStop + ' '
  } else {
    text = text + 'irgendwo '
  }
  if (mrT.direction) {
    text = text + 'in Richtig ' + mrT.direction + ' '
  }
  text = text + 'gsichtät wordä.'
  if (mrT.description) {
    text = text + ' ' + mrT.description
  }
  return text
}

function renderDurationInMinutes (milliseconds) {
  let halfMinutes = Math.round(milliseconds / 1000.0 / 30.0)
  if (halfMinutes < 2) {
    return 'wenigär als 1'
  } else if (halfMinutes % 2 === 0) {
    return '' + (halfMinutes / 2)
  } else {
    return '' + ((halfMinutes - 1) / 2) + 'ähalb'
  }
}

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

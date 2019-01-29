
export function renderMrTLocation (mrTChanges, now) {
  if (!mrTChanges || !mrTChanges.length) return 'Käinä wäiss es so rächt...'
  let mrT = mrTChanges[mrTChanges.length - 1]
  if (mrT.disabled) return 'Käinä wäiss es so rächt...'
  let text = 'Dä Mr. T isch zletscht '
  if (mrT.time) {
    text = text + 'vor ' + renderDurationInMinutes(now - mrT.time.toDate()) + ' Minutä '
  }
  if (mrT.vehicle) {
    if (/^[sS]/i.test(mrT.vehicle)) {
      text = text + 'i dä ' + mrT.vehicle + ' '
    } else if (/^[a-zäöü]/i.test(mrT.vehicle)) {
      text = text + 'im ' + mrT.vehicle + ' '
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

export function renderMrTSince (mrTChanges, now) {
  if (!mrTChanges || !mrTChanges.length) return '🔭️ bishär käin Mr. T'
  let mrT = mrTChanges[mrTChanges.length - 1]
  if (mrT.disabled) return '⛔ momentan nöd aktiv'
  for (let i = mrTChanges.length - 1; i >= 0; i--) {
    if (mrTChanges[i].group.id !== mrT.group.id) break
    mrT = mrTChanges[i]
  }
  return '🕑 sit ' + renderDurationInMinutes(now - mrT.time.toDate()) + ' Minutä bi dä gliichä Gruppä'
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

export function calculateAllScores (groups, stationVisits, jokerVisits, mrTChanges, settings, now = new Date()) {
  if (!settings) return { allGroups: [], stationOwners: new Map() }
  let allGroups = groups.reduce((map, group) => map.set(group.id, { ...group, id: group.id, saldo: 0, realEstatePoints: 0, mrTPoints: 0 }), new Map())
  addStarterCash(allGroups, settings)
  let stationOwners = addStationExpenses(allGroups, stationVisits, settings, now)
  addJokerIncome(allGroups, jokerVisits, settings)
  addMrTPoints(allGroups, mrTChanges, settings, now)
  return {
    allGroups: Array.from(allGroups.values()).map(group => ({ ...group, totalPoints: group.saldo + group.realEstatePoints + group.mrTPoints }))
      .sort((a, b) => b.totalPoints - a.totalPoints),
    stationOwners: stationOwners
  }
}

function addStarterCash (allGroups, settings) {
  allGroups.forEach(group => { group.saldo += settings.starterCash })
}

function addStationExpenses (allGroups, stationVisits, settings, now) {
  let stationOwners = new Map()
  const gameEnd = settings.gameEnd.toDate()
  stationVisits.forEach(stationVisit => {
    if (!stationVisit.group || !stationVisit.group.id || stationVisit.time.toDate() > gameEnd) return
    let visitor = allGroups.get(stationVisit.group.id)
    let existingOwner = stationOwners.get(stationVisit.station.id)
    if (existingOwner) {
      let rent = stationVisit.station.value * settings.rentRate
      // Pay
      visitor.saldo -= rent
      // Collect
      existingOwner.saldo += rent
    } else {
      stationOwners.set(stationVisit.station.id, visitor)
      let value = stationVisit.station.value
      // Buying cost
      visitor.saldo -= value
      // Real estate value
      visitor.realEstatePoints += value * settings.realEstateValueRatio
      // Interest
      visitor.saldo += interestAmount(value, settings.interestPeriod, settings.interestRate,
        stationVisit.time.toDate(), now, settings.gameEnd.toDate())
    }
  })
  allGroups.forEach(group => { group.saldo = Math.round(group.saldo) })
  return stationOwners
}

function interestAmount (value, period, rate, buyingTime, now, gameEnd) {
  return Math.max(0, (Math.min(now, gameEnd) - buyingTime) / 60000.0 / period * rate * value)
}

function addJokerIncome (allGroups, jokerVisits, settings) {
  const gameEnd = settings.gameEnd.toDate()
  jokerVisits.forEach(jokerVisit => {
    if (!jokerVisit.group || !jokerVisit.group.id || jokerVisit.time.toDate() > gameEnd) return
    allGroups.get(jokerVisit.group.id).saldo += jokerVisit.station.value
  })
}

function addMrTPoints (allGroups, mrTChanges, settings, now) {
  let currentMrT = null
  let currentMrTSince = null
  const gameEnd = settings.gameEnd.toDate()
  mrTChanges.forEach(mrTVisit => {
    if (!mrTVisit.group) return
    let newMrT = mrTVisit.group.id
    let newMrTSince = mrTVisit.time.toDate()
    if (!newMrT || newMrT === currentMrT) return
    if (currentMrT) {
      allGroups.get(currentMrT).mrTPoints += mrTAmount(settings.mrTRewards, currentMrTSince, newMrTSince, gameEnd)
    }
    currentMrT = newMrT
    currentMrTSince = newMrTSince
  })
  if (currentMrT) {
    let currentMrTGroup = allGroups.get(currentMrT)
    currentMrTGroup.mrTPoints += mrTAmount(settings.mrTRewards, currentMrTSince, now, gameEnd)
    currentMrTGroup.isCurrentlyMrT = true
  }
}

function mrTAmount (rewards, since, until, gameEnd) {
  let durationInMinutes = Math.max(0, (Math.min(until, gameEnd) - since) / 60000.0)
  let result = 0
  let i
  for (i in rewards) {
    if (rewards[i].duration > durationInMinutes) {
      return result
    }
    result = rewards[i].value
  }
  return result
}

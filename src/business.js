
export function renderMrTLocation (mrTChanges, now) {
  if (!mrTChanges || !mrTChanges.length) return 'Käinä wäiss es so rächt...'
  let mrT = mrTChanges[mrTChanges.length - 1]
  let text = ''
  let inactive = mrT.active === false
  if (inactive) {
    text += 'Dä Mr. T isch scho lang nümä gsee wordä. Zletscht'
    mrT = undefined
    for (let i = mrTChanges.length - 1; i >= 0; i--) {
      if (mrTChanges[i].active !== false) {
        mrT = mrTChanges[i]
        break
      }
    }
    if (!mrT) return 'Käinä wäiss es so rächt...'
  } else {
    text += 'Dä Mr. T isch zletscht'
  }
  if (mrT.time) {
    text += ' vor ' + renderDurationInMinutes(now - mrT.time.toDate()) + ' Minutä'
  }
  if (mrT.vehicle) {
    if (/^[sS]/i.test(mrT.vehicle)) {
      text += ' i dä ' + mrT.vehicle
    } else if (/^[a-zäöü]/i.test(mrT.vehicle)) {
      text += ' im ' + mrT.vehicle
    } else if (parseInt(mrT.vehicle > 17)) {
      text += ' im ' + mrT.vehicle + 'er'
    } else {
      text += ' im ' + mrT.vehicle + 'i'
    }
  }
  if (mrT.lastKnownStop) {
    text += ' bi ' + mrT.lastKnownStop
  } else {
    text += ' irgendwo'
  }
  if (mrT.direction) {
    text += ' in Richtig ' + mrT.direction
  }
  if (inactive) text += '.'
  else text += ' gsichtät wordä.'
  if (mrT.description) {
    text += ' ' + mrT.description
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

export function timeSinceLastActiveMrTChange (mrTChanges, now) {
  var lastActiveMrTChange = [...mrTChanges].sort((a, b) => b.time.toDate() - a.time.toDate()).filter(mrTChange => mrTChange.time.toDate() < now).find(mrTChange => mrTChange.active !== false)
  if (!lastActiveMrTChange) return 'Bishär käin aktivä Mr. T...'
  return 'Dä Mr. T hät sich zletscht vor ' + renderDurationInMinutes(now - lastActiveMrTChange.time.toDate()) + ' Minutä gmäldät.'
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
  let currentMrTId = null
  let currentMrTSince = null
  const gameEnd = settings.gameEnd.toDate()
  mrTChanges.forEach(mrTChange => {
    if (!mrTChange.group) return
    let newMrT = mrTChange.group.id
    let newMrTSince = mrTChange.time.toDate()
    if (mrTChange.active === false) {
      finishMrTPeriod(allGroups, currentMrTId, settings, currentMrTSince, newMrTSince, gameEnd)
      currentMrTId = null
      currentMrTSince = null
      return
    }
    if (!newMrT || newMrT === currentMrTId) return
    finishMrTPeriod(allGroups, currentMrTId, settings, currentMrTSince, newMrTSince, gameEnd)
    currentMrTId = newMrT
    currentMrTSince = newMrTSince
  })
  finishMrTPeriod(allGroups, currentMrTId, settings, currentMrTSince, now, gameEnd)
  if (currentMrTId) {
    var currentMrT = allGroups.get(currentMrTId)
    if (currentMrT) currentMrT.isCurrentlyMrT = true
  }
}

function finishMrTPeriod (allGroups, periodOwnerId, settings, since, until, gameEnd) {
  if (periodOwnerId) {
    var periodOwner = allGroups.get(periodOwnerId)
    if (periodOwner) periodOwner.mrTPoints += mrTAmount(settings.mrTRewards, since, until, gameEnd)
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

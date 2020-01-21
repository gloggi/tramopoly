export function renderMrTLocation (checkpoint, mrTChanges, now) {
  const newMrTChanges = [...mrTChanges]
  if (checkpoint && checkpoint.lastMrT) {
    newMrTChanges.unshift(checkpoint.lastMrT.change)
  }
  if (!newMrTChanges || !newMrTChanges.length) return 'Käinä wäiss es so rächt...'
  let mrT = newMrTChanges[newMrTChanges.length - 1]
  let text = ''
  const inactive = mrT.active === false
  if (inactive) {
    text += 'Dä Mr. T isch scho lang nümä gsee wordä. Zletscht'
    mrT = undefined
    for (let i = newMrTChanges.length - 1; i >= 0; i--) {
      if (newMrTChanges[i].active !== false) {
        mrT = newMrTChanges[i]
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

export function renderMrTSince (checkpoint, mrTChanges, now) {
  const newMrTChanges = [...mrTChanges]
  if (checkpoint && checkpoint.lastMrT) {
    newMrTChanges.unshift(checkpoint.lastMrT.since)
  }
  if (!newMrTChanges || !newMrTChanges.length) return '🔭️ bishär käin Mr. T'
  let mrT = newMrTChanges[newMrTChanges.length - 1]
  if (mrT.disabled) return '⛔ momentan nöd aktiv'
  for (let i = newMrTChanges.length - 1; i >= 0; i--) {
    if (newMrTChanges[i].group.id !== mrT.group.id) break
    mrT = newMrTChanges[i]
  }
  return '🕑 sit ' + renderDurationInMinutes(now - mrT.time.toDate()) + ' Minutä bi dä gliichä Gruppä'
}

export function timeSinceLastActiveMrTChange (checkpoint, mrTChanges, now) {
  const newMrTChanges = [...mrTChanges]
  if (checkpoint && checkpoint.lastMrT) {
    newMrTChanges.unshift(checkpoint.lastMrT.change)
  }
  const lastActiveMrTChange = [...newMrTChanges].sort((a, b) => b.time.toDate() - a.time.toDate()).filter(mrTChange => mrTChange.time.toDate() < now).find(mrTChange => mrTChange.active !== false)
  if (!lastActiveMrTChange) return 'Bishär käin aktivä Mr. T...'
  return 'Dä Mr. T hät sich zletscht vor ' + renderDurationInMinutes(now - lastActiveMrTChange.time.toDate()) + ' Minutä gmäldät.'
}

function renderDurationInMinutes (milliseconds) {
  const halfMinutes = Math.round(milliseconds / 1000.0 / 30.0)
  if (halfMinutes < 2) {
    return 'wenigär als 1'
  } else if (halfMinutes % 2 === 0) {
    return '' + (halfMinutes / 2)
  } else {
    return '' + ((halfMinutes - 1) / 2) + 'ähalb'
  }
}

export function renderTime (minutesInFuture) {
  return new Date(Date.now() + minutesInFuture * 60000).toLocaleTimeString('de-CH')
}

export function calculateAllScores (checkpoint, groups, stationVisits, jokerVisits, mrTChanges, settings, now = new Date()) {
  if (!settings) return { allGroups: [], stationOwners: new Map() }
  const allGroups = checkpoint ? allGroupsFromCheckpoint(checkpoint, groups) : allGroupsWithStarterCash(settings, groups)
  const stationOwners = addStationExpenses(checkpoint, allGroups, stationVisits, settings, now)
  addJokerIncome(allGroups, jokerVisits, settings)
  addMrTPoints(checkpoint, allGroups, mrTChanges, settings, now)
  return {
    allGroups: Array.from(allGroups.values()).map(group => ({ ...group, totalPoints: group.saldo + group.realEstatePoints + group.mrTPoints }))
      .sort((a, b) => b.totalPoints - a.totalPoints),
    stationOwners
  }
}

function allGroupsFromCheckpoint (checkpoint, groups) {
  return groups.reduce((map, group) => {
    return map.set(group.id, { ...group, id: group.id, ...checkpoint.groupData[group.id] })
  }, new Map())
}

function allGroupsWithStarterCash (settings, groups) {
  return groups.reduce((map, group) => {
    return map.set(group.id, { ...group, id: group.id, saldo: settings.starterCash, realEstatePoints: 0, mrTPoints: 0 })
  }, new Map())
}

function stationOwnersFromCheckpoint (checkpoint, allGroups) {
  return Object.entries(checkpoint.stationOwners).reduce((map, [stationId, ownerId]) => {
    return map.set(stationId, allGroups.get(ownerId))
  }, new Map())
}

export function calculateCheckpointData (groups, stationVisits, jokerVisits, mrTChanges, settings, checkpointDate) {
  const { allGroups, stationOwners } = calculateAllScores(null, groups, stationVisits, jokerVisits, mrTChanges, settings, checkpointDate)
  const { lastMrTSince, lastMrTChange, lastMrTAmount } = calculateLastMrTChange(mrTChanges, settings, checkpointDate)
  return {
    groupData: Object.fromEntries(allGroups.reduce((map, group) => {
      return map.set(group.id, { saldo: group.saldo, realEstatePoints: group.realEstatePoints, mrTPoints: group.mrTPoints })
    }, new Map())),
    stationOwners: Object.fromEntries(Array.from(stationOwners.entries()).map(([stationId, owner]) => [stationId, owner.id])),
    visitedStations: Object.fromEntries(stationVisits.reduce((map, visit) => map.set(visit.group.id, [...(map.get(visit.group.id) || []), visit.station.id]), new Map())),
    visitedJokers: Object.fromEntries(jokerVisits.reduce((map, visit) => map.set(visit.group.id, [...(map.get(visit.group.id) || []), visit.station.id]), new Map())),
    lastMrT: lastMrTChange ? { id: lastMrTChange.group.id, since: lastMrTSince, change: lastMrTChange, amount: lastMrTAmount } : null
  }
}

function calculateLastMrTChange (mrTChanges, settings, checkpointDate) {
  if (!mrTChanges.length) return { lastMrTChange: null, lastMrTAmount: 0 }
  const finalMrT = mrTChanges[mrTChanges.length - 1].group.id
  let lastMrTSince = null
  let lastMrTAmount = 0
  const mrTHasEverChanged = mrTChanges.slice().reverse().some(mrTChange => {
    if (mrTChange.group.id !== finalMrT) return true
    lastMrTSince = mrTChange
    lastMrTAmount = mrTAmount(settings.mrTRewards, mrTChange.time.toDate(), checkpointDate, settings.gameEnd.toDate())
    return false
  })
  if (!mrTHasEverChanged) return { lastMrTChange: null, lastMrTAmount: 0 }
  return { lastMrTSince: lastMrTSince, lastMrTChange: mrTChanges[mrTChanges.length - 1], lastMrTAmount }
}

function addStationExpenses (checkpoint, allGroups, stationVisits, settings, now) {
  const stationOwners = checkpoint ? stationOwnersFromCheckpoint(checkpoint, allGroups) : new Map()
  const gameEnd = settings.gameEnd.toDate()
  if (checkpoint) {
    allGroups.forEach(group => {
      // Add interest for the time period since the checkpoint for all stations that
      // the group already owned before the checkpoint
      const checkpointRealEstateValue = checkpoint.groupData[group.id].realEstatePoints / settings.realEstateValueRatio
      group.saldo += interestAmount(checkpointRealEstateValue, settings.interestPeriod, settings.interestRate,
        checkpoint.time.toDate(), now, settings.gameEnd.toDate())
    })
  }
  stationVisits.forEach(stationVisit => {
    if (!stationVisit.group || !stationVisit.group.id || stationVisit.time.toDate() > gameEnd) return
    const visitor = allGroups.get(stationVisit.group.id)
    const existingOwner = stationOwners.get(stationVisit.station.id)
    if (existingOwner) {
      const rent = stationVisit.station.value * settings.rentRate
      // Pay
      visitor.saldo -= rent
      // Collect
      existingOwner.saldo += rent
    } else {
      stationOwners.set(stationVisit.station.id, visitor)
      const value = stationVisit.station.value
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

function addMrTPoints (checkpoint, allGroups, mrTChanges, settings, now) {
  const newMrTChanges = [...mrTChanges]
  if (checkpoint && checkpoint.lastMrT) {
    newMrTChanges.unshift(checkpoint.lastMrT.change)
    if (mrTChanges.length && mrTChanges[0].group.id === checkpoint.lastMrT.id) {
      allGroups.get(checkpoint.lastMrT.id).mrTPoints -= checkpoint.lastMrT.amount
    }
  }
  let currentMrTId = null
  let currentMrTSince = null
  const gameEnd = settings.gameEnd.toDate()
  newMrTChanges.forEach(mrTChange => {
    if (!mrTChange.group) return
    const newMrT = mrTChange.group.id
    const newMrTSince = mrTChange.time.toDate()
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
    const currentMrT = allGroups.get(currentMrTId)
    if (currentMrT) {
      currentMrT.isCurrentlyMrT = true
      currentMrT.shouldCallOperator = newMrTChanges[newMrTChanges.length - 1].shouldCallOperator
    }
  }
}

function finishMrTPeriod (allGroups, periodOwnerId, settings, since, until, gameEnd) {
  if (periodOwnerId) {
    const periodOwner = allGroups.get(periodOwnerId)
    if (periodOwner) periodOwner.mrTPoints += mrTAmount(settings.mrTRewards, since, until, gameEnd)
  }
}

function mrTAmount (rewards, since, until, gameEnd) {
  const durationInMinutes = Math.max(0, (Math.min(until, gameEnd) - since) / 60000.0)
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

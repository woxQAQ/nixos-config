import { exec, idle, Variable } from 'astal'

const nproc = Number.parseInt(exec('nproc'))

const _parse = (times: string[]) => {
  if (!times) return null
  if (times[0] === '') {
    times = times.slice(1)
  }
  const cpuVal = times.map((v) => {
    return Number.parseInt(v)
  })
  return cpuVal
}

const idleIndex = 3
const iowaitIndex = 4

class cpuTime {
  total = 0
  idle = 0

  constructor(idle = 0, total = 0) {
    return {
      total: idle,
      idle: total,
    }
  }
}

const _calc = (procLine: string): cpuTime => {
  const values = _parse(procLine.split(' ').slice(1))
  if (values === null) {
    return {
      total: 0,
      idle: 0,
    }
  }

  let total = 0
  let idle = 0
  for (let i = 0; i < values.length; i++) {
    if (i === idleIndex || i===iowaitIndex) {
      idle += values[i]
    }
    total += values[i]
  }
  return {
    total,
    idle,
  }
}

let lastCpuAllUsage = new cpuTime()
let lastCpuUsages = Array(nproc).fill(cpuTime)
let isInit = false

export const initCpuUsage = () => {
  if (!isInit) {
    const content = exec(['cat', '/proc/stat'])
    const lines = content.split('\n')
    const allCpu = lines[0]
    const cpus = lines.slice(1, nproc + 1)

    const CpuAllUsage = _calc(allCpu)
    let cpuUsages = Array(nproc).fill({})
    cpus.forEach((v, i) => {
      cpuUsages[i] = _calc(v)
    })
    lastCpuAllUsage = CpuAllUsage
    lastCpuUsages = cpuUsages
    isInit = true
  }
}

const getPercent = (old_: cpuTime, new_: cpuTime) => {
  return 1 - (new_.idle - old_.idle) / (new_.total - old_.total)
}

export const cpuUsage = Variable({
  usage: 0,
  cpuMap: Array(nproc).fill(0),
}).poll(2000, ['cat', '/proc/stat'], (content, prev) => {
  const lines = content.split('\n')
  const allCpu = lines[0]
  const cpus = lines.slice(1, nproc + 1)

  const CpuAllUsage = _calc(allCpu)
  let cpuUsages = Array(nproc).fill({})
  cpus.forEach((v, i) => {
    cpuUsages[i] = _calc(v)
  })

  if (!isInit) {
    lastCpuAllUsage = CpuAllUsage
    lastCpuUsages = cpuUsages
    isInit = true
    return prev
  }

  const allUsage = getPercent(lastCpuAllUsage, CpuAllUsage)

  let usage = Array(nproc).fill(0)

  cpuUsages.forEach((v, i) => {
    usage[i] = getPercent(lastCpuUsages[i], v)
  })
  lastCpuAllUsage = CpuAllUsage
  lastCpuUsages = cpuUsages

  return {
    usage: allUsage,
    cpuMap: usage,
  }
})

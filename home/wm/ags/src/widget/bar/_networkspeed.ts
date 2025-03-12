import Variable from 'astal/variable'

let lastTotalDown = 0
let lastTotalUp = 0

export const networkSpeed = Variable({
  download: 0,
  upload: 0,
}).poll(1000, ['cat', '/proc/net/dev'], (content, _) => {
  const lines = content.split('\n')
  let totalDownload = 0
  let totalUpload = 0

  for (let i = 0; i < lines.length; i++) {
    const fields = lines[i].trim().split(/\W+/)
    if (fields.length <= 2) {
      continue
    }
    // Skip virtual interfaces.
    const interfce = fields[0]
    const currentInterfaceDownBytes = Number.parseInt(fields[1])
    const currentInterfaceUpBytes = Number.parseInt(fields[9])
    if (
      interfce === 'lo' ||
      // Created by python-based bandwidth manager "traffictoll".
      interfce.match(/^ifb[0-9]+/) ||
      // Created by lxd container manager.
      interfce.match(/^lxdbr[0-9]+/) ||
      interfce.match(/^virbr[0-9]+/) ||
      interfce.match(/^br[0-9]+/) ||
      interfce.match(/^vnet[0-9]+/) ||
      interfce.match(/^tun[0-9]+/) ||
      interfce.match(/^tap[0-9]+/) ||
      isNaN(currentInterfaceDownBytes) ||
      isNaN(currentInterfaceUpBytes)
    ) {
      continue
    }
    totalDownload += currentInterfaceDownBytes
    totalUpload += currentInterfaceUpBytes
  }

  if (lastTotalDown === 0) {
    lastTotalDown = totalDownload
  }
  if (lastTotalUp === 0) {
    lastTotalUp = totalUpload
  }
  const downloadSpeed = (totalDownload - lastTotalDown) / 1000
  const uploadSpeed = (totalUpload - lastTotalUp) / 1000

  lastTotalDown = totalDownload
  lastTotalUp = totalUpload

  return {
    download: downloadSpeed,
    upload: uploadSpeed,
  }
})

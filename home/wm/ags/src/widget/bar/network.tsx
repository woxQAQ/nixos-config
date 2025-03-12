import { networkSpeed } from './_networkspeed'

export default () => {
  return (
    <button>
      <label
        label={networkSpeed((v) => {
          const downloadSpeed = v.download
          const uploadSpeed = v.upload
          const higherSpeed =
            downloadSpeed >= uploadSpeed ? downloadSpeed : uploadSpeed

          const speed = (higherSpeed / 1000).toFixed(2)

          const symbol = downloadSpeed >= uploadSpeed ? '' : ''

          return `${speed} MB/s ${symbol}`
        })}
      ></label>
    </button>
  )
}

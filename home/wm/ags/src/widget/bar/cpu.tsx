import { cpuUsage } from './_cpu'

export default () => {
  return (
    <button>
      <label
        label={cpuUsage((v) => {
          const fixed = (v.usage * 100).toFixed(1)
          return `  ${fixed}%`
        })}
      ></label>
      <popover>
        {cpuUsage((v) => {
          v.cpuMap.map((v) => {
            return <label label={v.toString()}></label>
          })
        })}
      </popover>
    </button>
  )
}

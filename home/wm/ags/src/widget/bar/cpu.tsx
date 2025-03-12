import { cpuUsage } from './_cpu'

export default () => {
  return (
    <menubutton>
      <label
        label={cpuUsage((v) => {
          const fixed = (v.usage * 100).toFixed(1)
          return `  ${fixed}%`
        })}
      ></label>
      <popover>
        {cpuUsage((v) => {
          return v.cpuMap
            .map((v, i) => {
              return `CPU${i}: ${(v * 100).toFixed(1)}%`
            })
            .join('\n')
        })}
      </popover>
    </menubutton>
  )
}

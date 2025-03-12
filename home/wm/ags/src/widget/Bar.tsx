import { App, Astal, Gdk } from 'astal/gtk4'
import Workspaces from './bar/workspaces'
import Time from './bar/time'
import Network from './bar/network'
import Cpu from './bar/cpu'

const Start = () => {
  return <Workspaces />
}

const Center = () => {
  return <Time />
}

const End = () => {
  return (
    <box>
      <Cpu />
      <Network />
    </box>
  )
}

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      visible
      cssClasses={['Bar']}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={App}
    >
      <centerbox cssName="centerbox">
        <Start></Start>
        <Center></Center>
        <End></End>
      </centerbox>
    </window>
  )
}

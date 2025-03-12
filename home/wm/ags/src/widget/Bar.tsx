import { App, Astal, Gtk, Gdk } from 'astal/gtk4'
import { Variable } from 'astal'
import Workspaces from './bar/workspaces'
import Time from './bar/time'
import Network from './bar/network'
import { cpuUsage } from './bar/_cpu'
import Cpu from './bar/cpu'

const time = Variable('').poll(1000, 'date')

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

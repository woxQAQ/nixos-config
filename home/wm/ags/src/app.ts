import { App } from 'astal/gtk4'
import style from './style.scss'
import Bar from './widget/Bar'
import { initCpuUsage } from './widget/bar/_cpu'

initCpuUsage()

App.start({
  css: style,
  main() {
    App.get_monitors().map(Bar)
  },
})

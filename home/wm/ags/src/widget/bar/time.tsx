import { GLib, Variable } from 'astal'
import { Gtk } from 'astal/gtk4'

export default ({ format = '  %H:%M:%S' }) => {
  const time = Variable(GLib.DateTime.new_now_local()).poll(1000, () =>
    GLib.DateTime.new_now_local(),
  )
  return (
    <menubutton hexpand halign={Gtk.Align.CENTER}>
      <label
        label={time((t) => t.format(format)!)}
        tooltipText={time((t) => t.format('%Y-%m-%d')!)}
      ></label>
      <popover>
        <Gtk.Calendar />
      </popover>
    </menubutton>
  )
}

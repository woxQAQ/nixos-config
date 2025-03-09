import { bind, Variable } from "astal";
import { Gtk } from "astal/gtk4";
import { ButtonProps } from "astal/gtk4/widget";
import AstalHyprland from "gi://AstalHyprland?version=0.1";

type wsButtonProps = ButtonProps & {
  ws: AstalHyprland.Workspace;
};
const WorkspaceButton = ({ ws, ...props }: wsButtonProps) => {
  const hyprland = AstalHyprland.get_default();
  const classNames = Variable.derive(
    [bind(hyprland, "focusedWorkspace"), bind(hyprland, "clients")],
    (fws, _) => {
      const classes = ["workspace-button"]
      fws.id == ws.id && classes.push("active")
      hyprland.get_workspace(ws.id)?.get_clients.length > 0 && classes.push("occupied")
      return classes
    });
  return <button
    cssClasses={classNames()}
    onDestroy={() => classNames.drop()}
    valign={Gtk.Align.CENTER}
    halign={Gtk.Align.CENTER}
    onClicked={() => ws.focus()}
    {...props}
  />
};

export default () => {
  return (
    <box cssClasses={["workspace-container"]} spacing={4}>
      {Array.from({ length: 6 }, (_, i) => i).map((i) => (
        <WorkspaceButton
          ws={AstalHyprland.Workspace.dummy(i + 1, null)}
        />
      ))}
    </box>
  );
}

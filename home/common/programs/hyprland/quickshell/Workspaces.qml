import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
  spacing: 4

  Repeater {
    model: [1, 2, 3, 4, 5, 6]

    Rectangle {
      required property int modelData
      property bool active: Hyprland.focusedMonitor?.activeWorkspace?.id === modelData
      property bool occupied: {
        for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
          let ws = Hyprland.workspaces.values[i];
          if (ws.id === modelData && ws.windows > 0) return true;
        }
        return false;
      }

      Layout.preferredWidth: 24
      Layout.preferredHeight: 24
      radius: 4
      color: active ? "#b4befe" : "transparent"

      Text {
        anchors.centerIn: parent
        text: modelData
        font.family: "FiraCode Nerd Font"
        font.pixelSize: 13
        color: active ? "#11111b" : occupied ? "#bac2de" : "#6c7086"
      }

      MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch("workspace " + modelData)
      }
    }
  }
}

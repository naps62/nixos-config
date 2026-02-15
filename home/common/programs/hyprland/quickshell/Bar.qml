import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      exclusionMode: ExclusionMode.Ignore
      implicitHeight: 32
      color: "#e611111b"

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 0

        // left: workspaces
        Workspaces {
          Layout.alignment: Qt.AlignLeft
        }

        // center: spacer
        Item { Layout.fillWidth: true }

        // right: clock
        ClockWidget {
          Layout.alignment: Qt.AlignRight
        }
      }
    }
  }
}

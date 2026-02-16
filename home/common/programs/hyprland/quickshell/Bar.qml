import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Scope {
  id: root
  property bool barVisible: false

  Variants {
    model: Quickshell.screens

    Scope {
      id: perScreen
      required property var modelData

      // invisible trigger zone at the top edge
      PanelWindow {
        id: trigger
        screen: perScreen.modelData
        visible: !root.barVisible

        anchors {
          top: true
          left: true
          right: true
        }

        exclusionMode: ExclusionMode.Ignore
        implicitHeight: 4
        color: "transparent"

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: root.barVisible = true
        }
      }

      // the actual bar
      PanelWindow {
        id: bar
        screen: perScreen.modelData
        visible: root.barVisible

        anchors {
          top: true
          left: true
          right: true
        }

        exclusionMode: ExclusionMode.Ignore
        implicitHeight: 32
        color: "#e611111b"

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          propagateComposedEvents: true
          // keep bar visible while mouse is on it
          onExited: hideTimer.restart()
        }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 12
          anchors.rightMargin: 12
          spacing: 0

          Workspaces {
            Layout.alignment: Qt.AlignLeft
          }

          Item { Layout.fillWidth: true }

          SysTray {
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: 16
          }

          ClockWidget {
            Layout.alignment: Qt.AlignRight
          }
        }
      }

      Timer {
        id: hideTimer
        interval: 500
        onTriggered: root.barVisible = false
      }
    }
  }
}

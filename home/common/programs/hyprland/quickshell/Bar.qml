import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  Variants {
    model: Quickshell.screens;

    delegate: Component {
      PanelWindow {
        property var modelData
        screen: modelData

        anchors {
          top: true
          left: true
          right: true
        }

        implicitHeight: 30

        ClockWidget {
          anchors.centerIn: parent
        }
      }
    }
  }
}

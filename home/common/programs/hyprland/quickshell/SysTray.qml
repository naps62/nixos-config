import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
  spacing: 6

  Repeater {
    model: SystemTray.items

    Image {
      required property SystemTrayItem modelData

      Layout.preferredWidth: 18
      Layout.preferredHeight: 18
      source: modelData.icon
      fillMode: Image.PreserveAspectFit

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
          if (mouse.button === Qt.RightButton || modelData.onlyMenu) {
            modelData.display(bar, parent.x, bar.height)
          } else {
            modelData.activate()
          }
        }
      }

      ToolTip {
        id: tooltip
        visible: hoverArea.containsMouse
        text: modelData.tooltipTitle || modelData.title || ""
      }

      MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
      }
    }
  }
}

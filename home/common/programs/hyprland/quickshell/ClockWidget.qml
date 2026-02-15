import QtQuick
import QtQuick.Layouts

RowLayout {
  spacing: 12

  Text {
    text: Time.date
    font.family: "FiraCode Nerd Font"
    font.pixelSize: 13
    color: "#6c7086"
  }

  Text {
    text: Time.clock
    font.family: "FiraCode Nerd Font"
    font.pixelSize: 14
    color: "#bac2de"
  }
}

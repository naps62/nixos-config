pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  readonly property string clock: Qt.formatDateTime(sysClock.date, "hh:mm")
  readonly property string date: Qt.formatDateTime(sysClock.date, "ddd MMM d")

  SystemClock {
    id: sysClock
    precision: SystemClock.Minutes
  }
}

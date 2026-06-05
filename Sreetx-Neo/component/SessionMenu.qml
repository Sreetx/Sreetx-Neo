// main.py
//
// Copyright 2026 - 2030 Sreetx
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import Quickshell.Widgets

PanelWindow {
    id: sessionRoot
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "#77000000"
    visible: true

    Shortcut {
        sequence: StandardKey.Cancel // Ini otomatis membaca tombol Esc
        onActivated: {
            sessionRoot.visible = false // Menutup jendela saat Esc ditekan
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            sessionRoot.visible = false
        }
    }

    Rectangle {
        id: containerSession
        anchors.centerIn: parent
        width: 800
        height: sessionMenu.implicitHeight + 20
        color: "#0d0606"
        radius: 20
        border.color: "#00b5c9"
        border.width: 1
        
        ColumnLayout {
            id: sessionMenu
            anchors.centerIn: parent
            width: parent.width - 40
            spacing: 10

            Rectangle {
                id: powerMenu
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 25
                color: lockMouse.containsMouse ? "#00b5c9" : "#242222"

                Text {
                    id: powerOFF
                    anchors.centerIn: parent
                    text: "PowerOFF"
                    font.bold: true
                    font.family: "Google Sans Flex"
                    font.pixelSize: 14
                    color: "white"
                }

                MouseArea {
                    id: lockMouse
                    anchors.fill: powerMenu
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        console.log("Poweroff successfully");
                        sessionRoot.visible = false
                        Quickshell.execDetached(["systemctl", "poweroff"]);
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                spacing: 20
                Rectangle {
                    id: logOutContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 25
                    color: lockMouselogout.containsMouse ? "#00b5c9" : "#242222"

                    Text {
                        id: logOut
                        anchors.centerIn: parent
                        text: "Log Out"
                        font.bold: true
                        font.family: "Google Sans Flex"
                        font.pixelSize: 14
                        color: "white"
                    }

                MouseArea {
                        id: lockMouselogout
                        anchors.fill: logOutContainer
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            console.log("Log Out successfully");
                            sessionRoot.visible = false
                            Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
                        }
                    }
                }

                Rectangle {
                    id: reBoot
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 25
                    color: lockreBoot.containsMouse ? "#00b5c9" : "#242222"

                    Text {
                        id: reBootText
                        anchors.centerIn: parent
                        text: "Reboot"
                        font.bold: true
                        font.family: "Google Sans Flex"
                        font.pixelSize: 14
                        color: "white"
                    }

                MouseArea {
                        id: lockreBoot
                        anchors.fill: reBoot
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            console.log("Reboot successfully");
                            sessionRoot.visible = false
                            Quickshell.execDetached(["systemctl", "reboot"]);
                        }
                    }
                }
                Rectangle {
                    id: rebootFirmware
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 25
                    color: lockreBootToFirmware.containsMouse ? "#00b5c9" : "#242222"

                    Text {
                        id: reBootFirmwaretext
                        anchors.centerIn: parent
                        text: "Reboot to Firmware"
                        font.bold: true
                        font.family: "Google Sans Flex"
                        font.pixelSize: 14
                        color: "white"
                    }
                    MouseArea {
                        id: lockreBootToFirmware
                        anchors.fill: rebootFirmware
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            console.log("Reboot firmware successfully");
                            sessionRoot.visible = false
                            Quickshell.execDetached(["systemctl", "reboot", "--firmware-setup"])
                        }
                    }
                }

                Rectangle {
                    id: missionCenter
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 25
                    color: lockMissionCenter.containsMouse ? "#00b5c9" : "#242222"

                    Text {
                        id: missionCenterText
                        anchors.centerIn: parent
                        text: "Task Manager"
                        font.bold: true
                        font.family: "Google Sans Flex"
                        font.pixelSize: 14
                        color: "white"
                    }
                    MouseArea {
                        id: lockMissionCenter
                        anchors.fill: missionCenter
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            console.log("Mission Center Openned successfully");
                            Quickshell.execDetached(["flatpak", "run", "io.missioncenter.MissionCenter"]);
                            sessionRoot.visible = false
                        }
                    }
                }
            }


        }
    }
}
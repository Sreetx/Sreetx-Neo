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

ShellRoot {
    Scope {
        id: launcherScope

        PanelWindow {
            id: launcherWindow
            screen: Quickshell.screens
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            
            color: "transparent"

            // KOTAK RUN LAUNCHER
            Rectangle {
                width: 500
                height: 60
                anchors.centerIn: parent
                
                color: "#1e1e2e" 
                radius: 20
                border.color: "#00f0ff" 
                border.width: 2

                TextField {
                    id: inputField
                    anchors.fill: parent
                    anchors.margins: 10
                    
                    placeholderText: "Run command... (Esc to close)"
                    placeholderTextColor: "#585b70"
                    color: "#cdd6f4"
                    font.pointSize: 12
                    font.family: "Google Sans Flex"
                    
                    background: Item {} 

                    // Jalankan perintah pas Enter
                    onAccepted: {
                        if (text.trim() !== "") {
                            Quickshell.execDetached(["sh", "-c", text])
                            launcherScope.isVisible = false // Sembunyikan launcher
                            text = "" // Reset teks
                        }
                        Qt.quit()
                    }

                    // Tutup pas Escape
                    Keys.onEscapePressed: {
                        Qt.quit()
                    }
                }
            }
        }
    }
}
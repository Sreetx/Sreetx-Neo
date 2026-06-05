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

// ** The Prototype **
// ** Status: Available when Update! **

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
import "./Apps"

Item {
    id: connectionSettingsWindow
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        Text { text: "Connection Settings"; color: "white"; font.pixelSize: 18; font.bold: true }
        //Item { Layout.fillHeight: true }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                text: "Dalam Pengembangan! <br />Nanti bakal ada opsi buat atur koneksi jaringan, VPN, dan lain-lain."
                color: "white"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                anchors.centerIn: parent
                font.family: "Google Sans Flex"
            }
        }
    }
}
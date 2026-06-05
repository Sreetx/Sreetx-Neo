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
// ** Status: Passive **

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: sidebarWindow
    anchors { top: true; bottom: true; right: true }

    // Animasi Slorotan
    width: 340
    visible: true
    Layout.fillHeight: true

    onClosing: (close) => {
        close.accepted = false
        sidebarWindow.visible = false
    }
    
    color: "#1A1B26"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // --- HEADER & TOMBOL CLEAR ---
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Notification Center"; color: "white"; font.bold: true; font.pixelSize: 16 }
            
            Item { Layout.fillWidth: true } // Pendorong ke kanan
            
            Button {
                flat: true
                contentItem: Text { text: "Clear All"; color: "#FF5555"; font.bold: true }
                // Hapus semua isi kotak penyimpanan
                onClicked: sidebarWindow.modelDatabase.clear() 
            }
        }

        // --- LIST NOTIFIKASI & GESTURE ---
        ListView {
            id: listNotif
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: sidebarWindow.modelDatabase // Baca dari kotak penyimpanan
            spacing: 10
            clip: true

            delegate: Item {
                id: delegateItem
                width: listNotif.width
                height: 68

                // Efek mengecil pas dihapus
                ListView.onRemove: SequentialAnimation {
                    PropertyAnimation { target: delegateItem; property: "height"; to: 0; duration: 150 }
                }

                // KARTU NOTIFIKASI
                Rectangle {
                    id: card
                    width: parent.width
                    height: parent.height
                    color: "#222436"
                    radius: 8

                    // LOGIKA GESER (SWIPE)
                    MouseArea {
                        anchors.fill: parent
                        drag.target: card
                        drag.axis: Drag.XAxis
                        drag.minimumX: -400 // Mentok geser ke kiri
                        drag.maximumX: 0
                        
                        onReleased: {
                            // Kalau digeser ke kiri lumayan jauh, hapus dari database
                            if (card.x < -120) {
                                sidebarWindow.modelDatabase.remove(index)
                            } else {
                                // Kalau kurang jauh, balikin ke posisi semula
                                card.x = 0
                            }
                        }
                    }

                    Behavior on x { NumberAnimation { duration: 150 } }

                    // ISI KARTU NOTIF
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 2
                        Text { text: summary; color: "white"; font.bold: true; font.pixelSize: 13; elide: Text.ElideRight }
                        Text { text: body; color: "#A0AEC0"; font.pixelSize: 11; elide: Text.ElideRight }
                    }
                }
            }
        }
    }
}
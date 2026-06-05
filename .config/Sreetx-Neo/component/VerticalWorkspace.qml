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
    id: leftDockWindow
    
    anchors {
        left: true
        top: true
        bottom: true
    }
    
    width: barHoverHandler.hovered ? 350 : 10
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    Item {
        id: leftWorkspaceBar
        
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: barHoverHandler.hovered ? 350 : 10

        readonly property int systemToplevelCount: (typeof ToplevelManager !== "undefined" && ToplevelManager.toplevels) ? ToplevelManager.toplevels.count : 0

        HoverHandler {
            id: barHoverHandler
        }

        Rectangle {
            id: visualPanel
            anchors.fill: parent
            color: "#0b0b11" 
            border.color: "#1b1b28"
            border.width: barHoverHandler.hovered ? 1 : 0
            opacity: barHoverHandler.hovered ? 1.0 : 0.0
            
            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 180 } }

            // CYBERPUNK USER PROFILE HEADER (Statis di Atas)
            Rectangle {
                id: userProfileSection
                width: parent.width - 24
                height: 60
                color: "transparent"
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
                property string systemUser: Quickshell.env("USER") || "Admin"
                property string linuxDistro: "Linux"

                Component.onCompleted: {
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET", "file:///etc/os-release", true);
                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            if (xhr.status === 200 || xhr.status === 0) {
                                var lines = xhr.responseText.split("\n");
                                for (var i = 0; i < lines.length; i++) {
                                    if (lines[i].startsWith("NAME=")) {
                                        // Ambil teks setelah NAME= dan hapus tanda kutip dua (")
                                        var nameVal = lines[i].substring(5).replace(/"/g, "");
                                        userProfileSection.linuxDistro = nameVal.trim();
                                        break;
                                    }
                                }
                            }
                        }
                    };
                    xhr.send();
                }

                Row {
                    anchors.bottomMargin: 0
                    anchors.fill: parent
                    spacing: 12

                    // Bingkai Foto Profil Bulat
                    ClippingRectangle {
                        id: avatarFrame
                        width: 60
                        height: 60
                        radius: 32
                        color: "transparent"
                        border.color: "#00f0ff" // Garis tepi Neon Cyan
                        border.width: 1
                        clip: true

                        Image {
                            id: avatarImage
                            anchors.fill: parent
                            source: "file:///home/" + userProfileSection.systemUser + "/.face"
                            fillMode: Image.PreserveAspectCrop
                            visible: true
                            
                            // Fallback otomatis ke .face.icon kalau .face gak ada
                            onStatusChanged: {
                                if (status === Image.Error && source === "file:///home/" + userProfileSection.systemUser + "/.face") {
                                    source = "file:///home/" + userProfileSection.systemUser + "/.face.icon";
                                }
                            }
                        }
                    }

                    // Metadata User (Nama & Status Operator)
                    Column {
                        spacing: 2
                        width: parent.width - avatarFrame.width - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: userProfileSection.systemUser ? (userProfileSection.systemUser.charAt(0).toUpperCase() + userProfileSection.systemUser.slice(1)) : "Admin"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 16
                            font.family: "Google Sans Flex"
                        }

                        Text {
                            text: userProfileSection.linuxDistro.toUpperCase()
                            color: "#00f0ff" // Neon Magenta Cerah
                            font.pixelSize: 12
                            font.family: "Google Sans Flex"
                        }
                    }
                }
                

                // Garis Pembatas (Divider) Horizontal Neon Tipis di bawah profil
                Rectangle {
                    width: parent.width
                    height: 3
                    color: "#00f0ff" // Neon Cyan
                    anchors.bottomMargin: -12
                    anchors.bottom: parent.bottom
                }
            }

            // Preview workspace live keren, anjaayyy
            Flickable {
                anchors {
                    left: parent.left; right: parent.right
                    top: userProfileSection.bottom; bottom: parent.bottom
                    topMargin: 35; bottomMargin: 24
                }
                contentHeight: scrollColumn.implicitHeight
                clip: true

                Column {
                    id: scrollColumn
                    width: parent.width - 24
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 14

                    Repeater {
                        model: 10

                        delegate: Rectangle {
                            id: wsTile
                            readonly property int wsId: index + 1
                            property var workspace: Hyprland.workspaces.values.find(ws => ws.id === wsId) || null

                            property bool isActive: Hyprland.focusedWorkspace?.id === wsId
                            property bool hasWindows: workspace?.toplevels?.length > 0

                            width: parent.width
                            height: width * 0.5625
                            radius: 11
                            color: isActive ? "#16161f" : (hasWindows ? "#111118" : "#0c0c14")
                            border.color: isActive ? "#00f0ff" : "#25253a"
                            border.width: isActive ? 2.5 : 1

                            // Hover Line
                            Rectangle {
                                width: tileHover.hovered ? 5 : 0
                                height: parent.height - 20
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 3
                                color: "#00f0ff"
                                Behavior on width { NumberAnimation { duration: 150 } }
                            }
                            HoverHandler { id: tileHover }

                            // Refresh agar lebih live
                            Connections {
                                target: Hyprland
                                function onToplevelsChanged() { /* trigger refresh */ }
                            }

                            // ==================== PREVIEW AREA ====================
                            Item {
                                id: previewArea
                                anchors.fill: parent
                                anchors.margins: 9
                                clip: true

                                Text {
                                    text: wsTile.wsId
                                    color: isActive ? "#00f0ff" : "#555577"
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.margins: 6
                                    z: 10
                                }

                                Repeater {
                                    model: wsTile.workspace ? wsTile.workspace.toplevels : []

                                    delegate: ScreencopyView {
                                        id: liveWin
                                        required property var modelData

                                        live: true
                                        paintCursor: false

                                        property real scaleFactor: 4.1   // ubah sesuai kebutuhan (3.8 - 5.0)

                                        property bool isFullscreen: modelData.fullscreen || (modelData.lastIpcObject?.fullscreen ?? false)

                                        // FIX POSITIONING (penting buat multi window & floating)
                                        property real monX: wsTile.workspace?.monitor?.x ?? 0
                                        property real monY: wsTile.workspace?.monitor?.y ?? 0

                                        x: isFullscreen ? 4 : Math.max(0, ((modelData.lastIpcObject?.at?.[0] ?? 0) - monX) / scaleFactor)
                                        y: isFullscreen ? 4 : Math.max(0, ((modelData.lastIpcObject?.at?.[1] ?? 0) - monY) / scaleFactor)

                                        width:  isFullscreen ? previewArea.width - 8 :
                                            Math.max(wsTile.width, (modelData.lastIpcObject?.size?.[0] ?? 800) / scaleFactor)

                                        height: isFullscreen ? previewArea.height - 8 :
                                            Math.max(wsTile.height, (modelData.lastIpcObject?.size?.[1] ?? 600) / scaleFactor)

                                        captureSource: modelData.wayland

                                        Rectangle {
                                            anchors.fill: parent
                                            color: "transparent"
                                            border.color: modelData.active ? "#00f0ff" : "#444466"
                                            border.width: modelData.active ? 1.8 : 1
                                            radius: 5
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.lastIpcObject?.title || ""
                                            color: "#aabbdd"
                                            font.pixelSize: 9
                                            width: parent.width - 16
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignHCenter
                                            visible: !liveWin.hasContent
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("workspace " + wsTile.wsId)
                            }

                            DropArea {
                                anchors.fill: parent
                                keys: ["hyprland-window"]
                                onDropped: (drop) => {
                                    if (drop.source?.windowAddress)
                                        Hyprland.dispatch(`movetoworkspace ${wsTile.wsId},address:${drop.source.windowAddress}`)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
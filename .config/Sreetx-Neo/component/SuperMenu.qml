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

// ** The Prototype! ** //

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtCore

PanelWindow {
    id: superMenuVisualWindow
    
    // 1. GEOMETRI FULLSCREEN (Fix jendela kempes)
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    color: "#cc0f111a" 
    
    // 2. PROPERTI UTAMA
    property var controller: null
    property string currentCategory: "All"
    property var rawApps: [] 
    
    // Path Dinamis (Fix path nyasar)
    property string listerPath: String(StandardPaths.writableLocation(StandardPaths.ConfigLocation)).replace("file://", "") + "/Sreetx-Neo/component/app_list.py"
    property string appOutputBuffer: ""

    ListModel { id: displayModel }

    Component.onCompleted: {
        console.log("🔥 [DEBUG SREETX] Path Python: " + listerPath)
        appFetcher.running = false
        appFetcher.running = true // Paksa restart jalurnya
    }

    // =========================================================================
    // MESIN 1: APP FETCHER (Python JSON)
    // =========================================================================
    Process {
        id: appFetcher
        command: ["python3", listerPath]
        running: true
    }

    Connections {
        target: appFetcher.stdout
        function onData(data) { superMenuVisualWindow.appOutputBuffer += data }
    }

    Connections {
        target: appFetcher
        function onRunningChanged() {
            if (!appFetcher.running) { 
                try {
                    superMenuVisualWindow.rawApps = JSON.parse(superMenuVisualWindow.appOutputBuffer.trim());
                    superMenuVisualWindow.refreshAppGrid();
                    console.log("Berhasil meload " + superMenuVisualWindow.rawApps.length + " aplikasi!");
                } catch(e) {
                    console.log("Gagal parsing JSON: " + e);
                }
            }
        }
    }

    // =========================================================================
    // MESIN 2: FILE SEARCHER (GNOME STYLE)
    // =========================================================================
    Process {
        id: fileSearcher
        property string rawOutput: ""
    }

    Connections {
        target: fileSearcher.stdout
        function onData(data) { fileSearcher.rawOutput += data }
    }

    Connections {
        target: fileSearcher
        function onRunningChanged() {
            if (!fileSearcher.running && fileSearcher.rawOutput.trim() !== "") {
                var files = fileSearcher.rawOutput.trim().split("\n");
                for (var i = 0; i < files.length; i++) {
                    if (files[i] === "") continue;
                    
                    var filePath = files[i];
                    var fileName = filePath.split("/").pop(); 
                    
                    displayModel.append({
                        "name": fileName,
                        "icon": "󰈔", // Icon khusus dokumen
                        "exec": "xdg-open '" + filePath + "'",
                        "cat": "Files"
                    });
                }
                fileSearcher.rawOutput = "";
            }
        }
    }

    // =========================================================================
    // MESIN 3: HYPRLAND EXECUTOR
    // =========================================================================
    Process {
        id: appLauncher
    }

    // =========================================================================
    // LOGIKA FILTER & SEARCH
    // =========================================================================
    function refreshAppGrid() {
        displayModel.clear()
        if (!rawApps || rawApps.length === 0) return;

        var sorted = rawApps.slice().sort(function(a, b) {
            return a.name.localeCompare(b.name)
        })

        var query = searchInput.text.toLowerCase()
        
        // Looping pencarian Aplikasi
        for (var i = 0; i < sorted.length; i++) {
            var app = sorted[i]
            var matchSearch = app.name.toLowerCase().includes(query)
            var matchCategory = (currentCategory === "All" || app.cat === currentCategory)

            if (matchSearch && matchCategory) {
                displayModel.append(app)
            }
        }

        // Trigger pencarian File kalau ngetik lebih dari 2 huruf
        if (query.length > 2) {
            fileSearcher.rawOutput = "";
            // Mencari di Documents & Downloads (bisa lu tambah path lain)
            fileSearcher.command = ["bash", "-c", "find ~/Documents ~/Downloads -maxdepth 3 -iname '*" + query + "*' | head -n 6"]
            fileSearcher.running = true;
        }
    }

    onCurrentCategoryChanged: refreshAppGrid()

    // =========================================================================
    // UI LAYOUT
    // =========================================================================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 50
        spacing: 35

        // --- SEARCH BAR ---
        Rectangle {
            id: searchBarContainer
            Layout.alignment: Qt.AlignHCenter
            width: parent.width * 0.35
            height: 48
            color: "#1e1e2e"
            radius: 12
            border.color: searchInput.activeFocus ? "#00E5FF" : "#313244"
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 12
                
                Text { text: "󰍉"; color: searchInput.activeFocus ? "#00E5FF" : "#a6adc8"; font.pixelSize: 18 }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: "white"
                    font.pixelSize: 14
                    focus: superMenuVisualWindow.visible 
                    
                    Text {
                        text: "Search apps or files..."
                        color: "#585b70"
                        font.pixelSize: 14
                        visible: parent.text === "" && !parent.activeFocus
                    }

                    onTextChanged: superMenuVisualWindow.refreshAppGrid()
                }
            }
        }

        // --- ROW APP GRID & KATEGORI ---
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 40

            // GRID VIEW
            GridView {
                id: appGridView
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 140
                cellHeight: 140
                clip: true
                model: displayModel

                delegate: Item {
                    width: appGridView.cellWidth
                    height: appGridView.cellHeight

                    Rectangle {
                        id: appTile
                        anchors.fill: parent
                        anchors.margins: 8
                        color: "transparent"
                        radius: 16
                        border.color: "transparent"
                        border.width: 1.5

                        states: [
                            State {
                                name: "hovered"
                                when: tileMouseArea.containsMouse
                                PropertyChanges { target: appTile; color: "#26283d"; border.color: "#00E5FF"; scale: 1.05 }
                                PropertyChanges { target: appIcon; color: "#00E5FF"; scale: 1.1 }
                            }
                        ]

                        transitions: [
                            Transition {
                                NumberAnimation { properties: "scale"; duration: 120; easing.type: Easing.OutQuad }
                                ColorAnimation { duration: 100 }
                            }
                        ]

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            Text { id: appIcon; text: model.icon; font.pixelSize: 44; color: "#cdd6f4"; Layout.alignment: Qt.AlignHCenter }
                            
                            Text { 
                                text: model.name; 
                                color: "white"; 
                                font.pixelSize: 12; 
                                font.bold: true; 
                                Layout.alignment: Qt.AlignHCenter;
                                elide: Text.ElideRight;
                                // FIX: Jangan pake parent.width di dalem Layout!
                                Layout.maximumWidth: 120 
                            }
                        }

                        MouseArea {
                            id: tileMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                console.log("Mengeksekusi: " + model.exec)
                                appLauncher.command = ["hyprctl", "dispatch", "exec", "--", model.exec]
                                appLauncher.running = true
                                
                                searchInput.text = ""
                                if (superMenuVisualWindow.controller) {
                                    superMenuVisualWindow.controller.isOpen = false 
                                }
                            }
                        }
                    }
                }
            }

            // SIDEBAR KATEGORI
            Rectangle {
                id: categorySidebar
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                color: "#11121d"
                radius: 16
                border.color: "#1e1e2e"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 8

                    Text { text: "CATEGORIES"; color: "#585b70"; font.pixelSize: 11; font.bold: true; Layout.bottomMargin: 10; Layout.alignment: Qt.AlignHCenter }

                    Repeater {
                        model: ["All", "Development", "Internet", "Graphics", "Multimedia", "Games", "System", "Files"]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: 10
                            color: superMenuVisualWindow.currentCategory === modelData ? "#00E5FF" : (catMouse.containsMouse ? "#1e1e2e" : "transparent")
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: superMenuVisualWindow.currentCategory === modelData ? "#0f111a" : "#cdd6f4"
                                font.pixelSize: 13
                                font.bold: superMenuVisualWindow.currentCategory === modelData
                            }

                            MouseArea {
                                id: catMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    superMenuVisualWindow.currentCategory = modelData
                                    searchInput.forceActiveFocus()
                                }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -10
        onClicked: {
            if (superMenuVisualWindow.controller) {
                superMenuVisualWindow.controller.isOpen = false
            }
        }
    }
}
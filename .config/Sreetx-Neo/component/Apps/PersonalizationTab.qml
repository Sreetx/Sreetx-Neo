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

import Qt.labs.platform as Platform
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
import QtCore

ScrollView {
    id: personalizationRoot
    clip: true
    contentWidth: availableWidth

    function cleanPath(p) {
        if (!p) return "";
        var str = p.toString();
        return str.startsWith("file://") ? str.substring(7) : str;
    }

    // ==================== PROPERTIES ====================
    readonly property string configPath: cleanPath(StandardPaths.writableLocation(StandardPaths.ConfigLocation)) + "/Sreetx-Neo/wallpapers/wallpapers.json"
    
    property string currentDesktop: ""
    property string currentLockscreen: ""
    property var wallpaperPresets: []
    property string collectionDir: ""

    // Target mana yang mau diganti wallpapernya ("desktop" atau "lockscreen")
    property string activeSelection: "desktop" 
    
    // ==================== FUCKING LOADER CONFIG ====================
    function loadConfig() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", configPath + "?t=" + Date.now(), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 0) {
                    try {
                        var json = JSON.parse(xhr.responseText || "{}");
                        currentDesktop = json.current_desktop || "";
                        currentLockscreen = json.lockscreen || "";
                        wallpaperPresets = json.presets || [];
                        if (json.collection_dir) collectionDir = json.collection_dir;
                        console.log("[Settings] ✅ JSON berhasil dimuat");
                    } catch (e) {
                        console.error("[Settings] JSON parse gagal, buat default...");
                        createDefaultConfig();
                    }
                } else {
                    console.log("[Settings] File JSON belum ada, membuat default...");
                    createDefaultConfig();
                }
            }
        };
        xhr.send();
    }

    function createDefaultConfig() {
        currentDesktop = "/home/programmer/Gambar/Wallpapers/Columbina.jpg";
        currentLockscreen = "";
        wallpaperPresets = [];
        saveConfig(currentDesktop, currentLockscreen);
    }

    // ==================== ONE-SHOT TIMER ====================
    Timer {
        id: syncTimer
        interval: 1200 
        running: false
        repeat: false
        onTriggered: {
            console.log("[Settings] 🔄 Reload UI Grid dari JSON...");
            personalizationRoot.loadConfig();
        }
    }

   // ==================== SAVE & AUTO-SCAN VIA BASH ====================
    function saveConfig(newDesktop, newLockscreen, newCollectionDir) {
        if (newDesktop) currentDesktop = newDesktop;
        if (newLockscreen) currentLockscreen = newLockscreen;
        // Kalau parameter ke-3 (path folder) diisi, update collectionDir kita
        if (newCollectionDir !== undefined && newCollectionDir !== "") {
            collectionDir = newCollectionDir;
        }

        var realPath = configPath;
        
        // LOGIKA KELAS KAKAP: Gabungan Overwrite Paksa ('w') + Auto-Scan Konten Folder
        var cmd = `
            CONFIG_PATH="${realPath}";
            COL_DIR="${collectionDir}";
            DESKTOP="${currentDesktop}";
            LOCKSCREEN="${currentLockscreen}";

            # Buat folder induknya dulu kalau belum ada
            mkdir -p "$(dirname "$CONFIG_PATH")";

            # KOLEKTOR DIR: Cek apakah folder wallpaper eksis dan valid
            if [ -d "$COL_DIR" ] && [ -n "$COL_DIR" ]; then
                # Ambil semua gambar, sort biar rapi, lalu ubah jadi format Array JSON pake jq
                FILES=$(find "$COL_DIR" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | sort);
                if [ -z "$FILES" ]; then
                    PRESETS='[]';
                else
                    PRESETS=$(echo "$FILES" | jq -R . | jq -s .);
                fi;
            else
                PRESETS='[]';
            fi;

            # MODE PYTHON 'w': Paksa buat/tulis baru dari NOL menggunakan jq -n (Null Input)
            # Menghindari bug file kosong/corrupt, langsung dihantam overwrite pake operator '>'
            jq -n \\
                --arg desk "$DESKTOP" \\
                --arg lock "$LOCKSCREEN" \\
                --arg cdir "$COL_DIR" \\
                --argjson presets "$PRESETS" \\
                '{current_desktop: $desk, lockscreen: $lock, collection_dir: $cdir, presets: $presets}' > "$CONFIG_PATH"
        `;

        // Eksekusi asinkronus via Quickshell
        Quickshell.execDetached(["bash", "-c", cmd]);

        console.log("[Settings] 💾 Config + Auto-Scan sukses ditulis ke:", realPath);

        // Reload UI setelah save biar grid langsung update otomatis
        loadConfigTimer.restart();
    }

    // Timer untuk reload UI setelah save
    Timer {
        id: loadConfigTimer
        interval: 1200
        running: false
        repeat: false
        onTriggered: loadConfig()
    }

    Component.onCompleted: {
        loadConfig();
    }

    // ==================== LAYOUT UTAMA ====================
    ColumnLayout {
        width: parent.width - 40 
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 25 
        Layout.topMargin: 20
        Layout.bottomMargin: 20

        // ----------------------------------------------------
        // SECTION 1: TARGET SELECTION & PREVIEW (16:9)
        // ----------------------------------------------------
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 40
            
            // PREVIEW DESKTOP
            ColumnLayout {
                spacing: 8
                Label { 
                    text: "Desktop Workspace"
                    font.pixelSize: 12; font.bold: true
                    color: personalizationRoot.activeSelection === "desktop" ? "#a6e3a1" : "#a6adc8"
                    Layout.alignment: Qt.AlignHCenter 
                }
                Rectangle {
                    width: 256; height: 144 
                    radius: 12
                    color: "#1e1e2e"
                    border.color: personalizationRoot.activeSelection === "desktop" ? "#a6e3a1" : "#313244"
                    border.width: personalizationRoot.activeSelection === "desktop" ? 3 : 1
                    clip: true
                    
                    Image { 
                        anchors.fill: parent
                        source: currentDesktop ? "file://" + currentDesktop : ""
                        fillMode: Image.PreserveAspectCrop 
                        asynchronous: true
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: personalizationRoot.activeSelection = "desktop"
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // PREVIEW LOCKSCREEN
            ColumnLayout {
                spacing: 8
                Label { 
                    text: "Lockscreen"
                    font.pixelSize: 12; font.bold: true
                    color: personalizationRoot.activeSelection === "lockscreen" ? "#a6e3a1" : "#a6adc8"
                    Layout.alignment: Qt.AlignHCenter 
                }
                Rectangle {
                    width: 256; height: 144
                    radius: 12
                    color: "#1e1e2e"
                    border.color: personalizationRoot.activeSelection === "lockscreen" ? "#a6e3a1" : "#313244"
                    border.width: personalizationRoot.activeSelection === "lockscreen" ? 3 : 1
                    clip: true
                    
                    Image { 
                        anchors.fill: parent
                        source: currentLockscreen ? "file://" + currentLockscreen : ""
                        fillMode: Image.PreserveAspectCrop 
                        asynchronous: true
                    }
                    Label {
                        id: centerClock
                        text: Qt.formatTime(new Date(), "hh:mm")
                        font.bold: true; font.pixelSize: 28; color: "white"
                        style: Text.Outline; styleColor: "black" 
                        anchors.centerIn: parent
                        Timer {
                            interval: 1000 // Update tiap detik biar presisi
                            running: true
                            repeat: true
                            onTriggered: centerClock.text = Qt.formatTime(new Date(), "HH:mm")
                            }
                        }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: personalizationRoot.activeSelection = "lockscreen"
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        // Divider
        Rectangle { Layout.fillWidth: true; height: 1; color: "#313244"; Layout.topMargin: 10; Layout.bottomMargin: 10 }

        // ----------------------------------------------------
        // SECTION 2: SETTINGS PATH
        // ----------------------------------------------------
        Label { text: "Wallpaper Directory"; font.pixelSize: 14; font.bold: true; color: "#b4befe" }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            TextField {
                id: pathInput
                text: personalizationRoot.collectionDir
                Layout.fillWidth: true
                selectByMouse: true
                placeholderText: "Path folder wallpaper..."
                background: Rectangle { 
                    color: "#181825"; radius: 8
                    border.color: pathInput.activeFocus ? "#89b4fa" : "#313244" 
                    border.width: 1
                }
                color: "white"
                font.pixelSize: 13
                leftPadding: 15; topPadding: 10; bottomPadding: 10
            }

            Button {
                text: "Browse..."
                font.bold: true
                onClicked: dirDialog.open()
            }
            
            Button {
                text: "Scan / Refresh"
                font.bold: true
                onClicked: personalizationRoot.saveConfig(personalizationRoot.currentDesktop, personalizationRoot.currentLockscreen, pathInput.text);
            }
        }

        // ----------------------------------------------------
        // SECTION 3: GRID COLLECTION
        // ----------------------------------------------------
        Label { text: "Quick Presets Collection"; font.pixelSize: 14; font.bold: true; color: "#b4befe" }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 400
            color: "#11111b" 
            radius: 18
            border.color: "#313244"
            border.width: 1
            clip: true

            GridView {
                id: wallpaperGrid
                anchors.fill: parent
                anchors.margins: 15
                cellWidth: 180 
                cellHeight: 115 
                clip: true
                model: personalizationRoot.wallpaperPresets

                delegate: Item {
                    id: gridDelegate
                    width: 160 
                    height: 90 

                    required property string modelData

                    // 1. BACKGROUND (Biar gak bolong pas gambar lagi loading)
                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#1e1e2e"
                    }

                    // 2. LAYER GAMBAR (Pake ClippingRectangle andalan lu)
                    ClippingRectangle {
                        anchors.fill: parent
                        radius: 8
                        // Gak perlu clip: true lagi karena komponen ini udah nanganin itu secara native
                        
                        Image {
                            anchors.fill: parent
                            source: cleanPath(gridDelegate.modelData) 
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true 
                        }
                    }

                    // 3. LAYER BORDER (Tetep posisinya di atas gambar biar membingkai)
                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "transparent"
                        
                        // Logika Animasi Hover
                        border.color: gridMouse.containsMouse ? "#89b4fa" : "#45475a"
                        border.width: gridMouse.containsMouse ? 2 : 1
                        
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        Behavior on border.width { NumberAnimation { duration: 150 } }
                    }

                    // 4. LAYER HITBOX MOUSE
                    MouseArea {
                        id: gridMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (personalizationRoot.activeSelection === "desktop") {
                                personalizationRoot.saveConfig(gridDelegate.modelData, personalizationRoot.currentLockscreen, personalizationRoot.collectionDir);
                            } else {
                                personalizationRoot.saveConfig(personalizationRoot.currentDesktop, gridDelegate.modelData, personalizationRoot.collectionDir);
                            }
                        }
                    }
                }
            }
            
            Label {
                text: "Belum ada gambar, cek path lalu klik 'Scan / Refresh'."
                color: "#6c7086"
                font.italic: true
                visible: wallpaperGrid.count === 0
                anchors.centerIn: parent
            }
        }
    }

    // ==================== DIALOG CONTROLS ====================
    Platform.FolderDialog {
        id: dirDialog
        title: "Pilih Folder Koleksi Wallpaper"
        currentFolder: personalizationRoot.collectionDir
        onAccepted: {
            var path = dirDialog.folder.toString();
            if (path.startsWith("file://")) path = path.substring(7);
            pathInput.text = path;
            personalizationRoot.saveConfig(personalizationRoot.currentDesktop, personalizationRoot.currentLockscreen, path);
        }
    }
}
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
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

PanelWindow {
    id: notifWindow
    // Panel transparan di atas layar
    anchors { top: true; left: true; right: true }
    height: hasNotif || dynamicIsland.opacity > 0 ? 150 : 0
    
    color: "transparent"
    
    // Pastikan berada di atas aplikasi lain tanpa menggeser ruang kerja
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    // --- STATE DATA NOTIFIKASI ---
    property bool hasNotif: false
    property string currentSummary: ""
    property string currentBody: ""
    property string currentApp: ""
    property string currentIcon: ""

    property bool isVolumeActive: false
    property int volumeValue: 50

    property bool isBrightnessActive: false
    property int brightnessValue: 50

    property bool isMicMuted: false
    property bool isMicActive: false

    property var modelDatabase

    Timer {
        id: volumeHideTimer
        interval: 2000 // Hilang otomatis dalam 2 detik setelah tombol dilepas
        onTriggered: notifWindow.isVolumeActive = false
    }

    Timer {
        id: brightnessHideTimer
        interval: 2000 // Hilang otomatis dalam 2 detik setelah tombol dilepas
        onTriggered: notifWindow.isBrightnessActive = false
    }

    Timer {
        id: micHideTimer
        interval: 2000 // Hilang otomatis dalam 2 detik setelah tombol dilepas
        onTriggered: notifWindow.isMicActive = false
    }

    function triggerBrightnessUpdate(values) {
        brightnessValue = values;
        isBrightnessActive = true;
        brightnessHideTimer.restart();
    }

    // Fungsi global yang bakal ditembak dari mainRoot / hyprland script
    function triggerVolumeUpdate(valued) {
        volumeValue = valued;
        isVolumeActive = true;
        volumeHideTimer.restart();
    }

    function triggerMicUpdate(muted) {
        isMicMuted = muted;      // Menangkap status asli dari bash (true/false)
        isMicActive = true;      // Menyalakan visibility island mic
        isVolumeActive = false;  // Matikan yang lain biar ga tabrakan state
        isBrightnessActive = false;
        hasNotif = false;
        micHideTimer.restart();
    }
    // --- 1. ENGINE D-BUS PENANGKAP NOTIF ---
    NotificationServer {
        id: server
         
        onNotification: (notif) => {
            if (notif.appName === "Volume") {
                notifWindow.triggerVolumeUpdate(parseInt(notif.summary));
            }
            else if (notif.appName === "Brightness") {
                notifWindow.triggerBrightnessUpdate(parseInt(notif.summary));
            }
            else if (notif.appName === "Mic") {
                let status = notif.summary.trim().toLowerCase();
                notifWindow.triggerMicUpdate(status === "muted");
            }
            else {
                notifWindow.currentSummary = notif.summary;
                notifWindow.currentBody = notif.body;
                notifWindow.currentApp = notif.appName !== "" ? notif.appName : "Sistem";
                
                // Ganti .icon jadi .appIcon
                notifWindow.currentIcon = notif.appIcon ? notif.appIcon.toString() : "";
                
                notifWindow.hasNotif = true;
                hideTimer.restart();

                if (modelDatabase) {
                    modelDatabase.append({
                        summary: notif.summary,
                        body: notif.body,
                        appName: notif.appName !== "" ? notif.appName : "Sistem"
                    })
                }
            }
        }
    }

    // --- 2. TIMER AUTO-HIDE ---
    Timer {
        id: hideTimer
        interval: 5000 // Hilang otomatis dalam 5000ms (5 detik)
        onTriggered: notifWindow.hasNotif = false
    }
    
    // --- 3. UI DYNAMIC ISLAND ---
    Rectangle {
        id: dynamicIsland
        color: "#1A1B26" 
        border.color: "#00E5FF"
        border.width: 1
        clip: true 
        
        // TRIK: Radius otomatis ngikutin tinggi, auto-pill shape!
        radius: height / 2 

        anchors.top: parent.top
        anchors.topMargin: 50 // Berada tepat di bawah top bar
        anchors.horizontalCenter: parent.horizontalCenter

        // Variabel target final pas posisi ngelebar (State: "open")
        width: 0
        height: 0
        opacity: 0

        // Menentukan state aktif berdasarkan boolean hasNotif
        state: notifWindow.hasNotif ? "open" : (notifWindow.isVolumeActive ? "volume" : (notifWindow.isBrightnessActive ? "brightness" : (notifWindow.isMicActive ? "mic" : "closed")))

        states: [
            State {
                name: "closed"
                PropertyChanges { target: dynamicIsland; width: 0; height: 0; opacity: 0 }
                PropertyChanges { target: iconContainer; opacity: 0 }
                PropertyChanges { target: textContainer; opacity: 0 }
                PropertyChanges { target: volSliderContainer; opacity: 0 } // Tambahan
            },
            State {
                name: "open"
                PropertyChanges { target: dynamicIsland; width: 400; height: 64; opacity: 1 }
                PropertyChanges { target: iconContainer; opacity: 1 }
                PropertyChanges { target: textContainer; opacity: 1 }
                PropertyChanges { target: volSliderContainer; opacity: 0 } // Tambahan
            },
            // === SISIPKAN STATE VOLUME BARU ===
            State {
                name: "volume"
                PropertyChanges { target: dynamicIsland; width: 250; height: 38; opacity: 1 }
                PropertyChanges { target: iconContainer; opacity: 0 }
                PropertyChanges { target: textContainer; opacity: 0 }
                PropertyChanges { target: volSliderContainer; opacity: 1 }
            },
            State {
                name: "brightness"
                PropertyChanges { target: dynamicIsland; width: 250; height: 38; opacity: 1 } // Ukuran sama eksklusif dengan volume
                PropertyChanges { target: iconContainer; opacity: 0 }
                PropertyChanges { target: textContainer; opacity: 0 }
                PropertyChanges { target: volSliderContainer; opacity: 0 }
                PropertyChanges { target: brightSliderContainer; opacity: 1 }
            },
            State {
                name: "mic"
                PropertyChanges { target: dynamicIsland; width: 200; height: 38; opacity: 1 }
                PropertyChanges { target: iconContainer; opacity: 0 } 
                PropertyChanges { target: textContainer; opacity: 0 }
            },
        ]

        transitions: [
            // === ANIMASI MUNCUL (REVERSE TIMING) ===
            Transition {
                from: "closed"; to: "open"
                SequentialAnimation {
                    // Langkah 1: Muncul jadi Lingkaran Kecil dulu di tengah
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 52; duration: 250; easing.type: Easing.OutBack }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 52; duration: 250; easing.type: Easing.OutBack }
                        NumberAnimation { target: dynamicIsland; property: "opacity"; to: 1; duration: 150 }
                        NumberAnimation { target: iconContainer; property: "opacity"; to: 1; duration: 200 }
                    }
                    // Jeda sekejap biar mata sempet ngeliat buletannya
                    PauseAnimation { duration: 80 }
                    
                    // Langkah 2: Dari lingkaran melar ngelebar jadi Pill
                    ParallelAnimation {
                        // Menggunakan properti bawaan state "open" (lebar 400, tinggi 64)
                        NumberAnimation { target: dynamicIsland; property: "width"; duration: 400; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                        NumberAnimation { target: dynamicIsland; property: "height"; duration: 300; easing.type: Easing.OutBack }
                    }
                    
                    // Langkah 3: Teks fade-in tipis setelah wadahnya siap
                    NumberAnimation { target: textContainer; property: "opacity"; duration: 150 }
                }
            },
            // === ANIMASI NUTUP (REVERSE SAKLAR) ===
            Transition {
                from: "open"; to: "closed"
                SequentialAnimation {
                    // Langkah 1: Sembunyiin teks secepatnya biar ga numpuk pas nge-shrink
                    NumberAnimation { target: textContainer; property: "opacity"; to: 0; duration: 120 }
                    
                    // Langkah 2: Mengempis balik dari Pill lebar ke bentuk Lingkaran 52x52
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 52; duration: 350; easing.type: Easing.InBack }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 52; duration: 350; easing.type: Easing.InBack }
                    }
                    PauseAnimation { duration: 50 }
                    
                    // Langkah 3: Lingkaran amblas hilang total
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 0; duration: 200; easing.type: Easing.InQuad }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 0; duration: 200; easing.type: Easing.InQuad }
                        NumberAnimation { target: dynamicIsland; property: "opacity"; to: 0; duration: 200 }
                        NumberAnimation { target: iconContainer; property: "opacity"; to: 0; duration: 150 }
                    }
                }
            },

            Transition {
                from: "closed"; to: "volume"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 42; duration: 250; easing.type: Easing.OutBack }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 42; duration: 250; easing.type: Easing.OutBack }
                        NumberAnimation { target: dynamicIsland; property: "opacity"; to: 1; duration: 150 }
                    }
                    PauseAnimation { duration: 80 }
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 250; duration: 400; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 38; duration: 300; easing.type: Easing.OutBack }
                    }
                    NumberAnimation { target: volSliderContainer; property: "opacity"; duration: 150 }
                }
            },
            // Animasi Volume Nutup
            Transition {
                from: "volume"; to: "closed"
                SequentialAnimation {
                    NumberAnimation { target: volSliderContainer; property: "opacity"; to: 0; duration: 120 }
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 42; duration: 350; easing.type: Easing.InBack }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 42; duration: 350; easing.type: Easing.InBack }
                    }
                    PauseAnimation { duration: 50 }
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 0; duration: 200; easing.type: Easing.InQuad }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 0; duration: 200; easing.type: Easing.InQuad }
                        NumberAnimation { target: dynamicIsland; property: "opacity"; to: 0; duration: 200 }
                    }
                }
            },
            Transition {
                from: "closed"; to: "brightness"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 42; duration: 250; easing.type: Easing.OutBack }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 42; duration: 250; easing.type: Easing.OutBack }
                        NumberAnimation { target: dynamicIsland; property: "opacity"; to: 1; duration: 150 }
                    }
                    PauseAnimation { duration: 80 }
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 250; duration: 400; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 38; duration: 300; easing.type: Easing.OutBack }
                    }
                    NumberAnimation { target: brightSliderContainer; property: "opacity"; duration: 150 }
                }
            },
            // Animasi Brightness Nutup
            Transition {
                from: "brightness"; to: "closed"
                SequentialAnimation {
                    NumberAnimation { target: brightSliderContainer; property: "opacity"; to: 0; duration: 120 }
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 42; duration: 350; easing.type: Easing.InBack }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 42; duration: 350; easing.type: Easing.InBack }
                    }
                    PauseAnimation { duration: 50 }
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 0; duration: 200; easing.type: Easing.InQuad }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 0; duration: 200; easing.type: Easing.InQuad }
                        NumberAnimation { target: dynamicIsland; property: "opacity"; to: 0; duration: 200 }
                    }
                }
            },
            Transition {
                from: "closed"; to: "mic"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 42; duration: 250; easing.type: Easing.OutBack }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 42; duration: 250; easing.type: Easing.OutBack }
                        NumberAnimation { target: dynamicIsland; property: "opacity"; to: 1; duration: 150 }
                    }
                    PauseAnimation { duration: 80 }
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 200; duration: 400; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 38; duration: 300; easing.type: Easing.OutBack }
                    }
                }
            },
            // Animasi Mic nutup
            Transition {
                from: "mic"; to: "closed"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 42; duration: 350; easing.type: Easing.InBack }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 42; duration: 350; easing.type: Easing.InBack }
                    }
                    PauseAnimation { duration: 50 }
                    ParallelAnimation {
                        NumberAnimation { target: dynamicIsland; property: "width"; to: 0; duration: 200; easing.type: Easing.InQuad }
                        NumberAnimation { target: dynamicIsland; property: "height"; to: 0; duration: 200; easing.type: Easing.InQuad }
                        NumberAnimation { target: dynamicIsland; property: "opacity"; to: 0; duration: 200 }
                    }
                }
            }
        ]

        // --- LAYER KONTEN DI DALAM ISLAND ---

        // 1. Ikon Indikator Notif
        // GEOMETRI: Pas lebar island 52px & lebar ikon 24px, margin 14px bikin posisinya PAS di tengah buletan!

        // Ini Mic

        RowLayout {
                id: micSliderContainer
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                visible: dynamicIsland.state === "mic";

                Text {
                    text: isMicMuted ? "󰍭" : "󰍬" 
                    font.pixelSize: 18
                    color: isMicMuted ? "#FF5555" : "#00E5FF" // Merah kalau mute
                }

                Text {
                    anchors.centerIn: parent
                    text: isMicMuted ? "Mic Muted" : "Mic Unmuted"
                    color: "white"
                    font.bold: true
                    Layout.leftMargin: 10
                }
            }

        // Ini Brightness
        RowLayout {
            id: brightSliderContainer
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.right: parent.right
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
        
            // Hanya hidup & kelihatan pas di mode brightness biar ga tumpang tindih
            visible: dynamicIsland.state === "brightness"

            Text {
                // Menggunakan icon matahari NerdFont (Bisa diganti sesuai font icon-mu)
                text: brightnessValue < 30 ? "󰃞" : (brightnessValue < 70 ? "󰃟" : "󰃠")
                font.pixelSize: 15
                color: "#FFB300" // Warna kuning jingga khas matahari cerah mamen
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                id: brightTrack
                Layout.fillWidth: true
                height: 4
                color: "#2A2B36"
                radius: 2
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    width: parent.width * (brightnessValue / 100)
                    height: parent.height
                    color: "#FFB300"
                    radius: 2
                    
                    Behavior on width { NumberAnimation { duration: 80 } }
                }
            }

            Text {
                text: brightnessValue + "%"
                font.family: "Google Sans Flex"
                font.pixelSize: 11
                font.bold: true
                color: "#ffffff"
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Ini Volume
        RowLayout {
            id: volSliderContainer
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.right: parent.right
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            
            // Hanya hidup & kelihatan pas di mode volume biar ga tumpang tindih
            visible: dynamicIsland.state === "volume"

            Text {
                text: volumeValue === 0 ? "󰝟" : "󰕾"
                font.pixelSize: 15
                color: "#00E5FF"
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                id: track
                Layout.fillWidth: true
                height: 4
                color: "#2A2B36"
                radius: 2
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    width: parent.width * (volumeValue / 100)
                    height: parent.height
                    color: "#00E5FF"
                    radius: 2
                    Behavior on width { NumberAnimation { duration: 80 } }
                }
            }

            Text {
                text: volumeValue + "%"
                font.family: "Google Sans Flex"
                font.pixelSize: 11
                font.bold: true
                color: "#ffffff"
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Dismiss area bawaan kamu (paling bawah di dalam Rectangle)
        MouseArea {
            anchors.fill: parent
            onClicked: {
                notifWindow.hasNotif = false
                notifWindow.isVolumeActive = false
                notifWindow.isBrightnessActive = false
                hideTimer.stop()
                volumeHideTimer.stop()
                brightnessHideTimer.stop()
            }
        }
        
        // Ini Ikon
        Rectangle {
            id: iconContainer
            width: 40
            height: 40
            radius: width / 2
            
            // LOGIKA PINTAR WARNA BACKGROUND:
            // Kalau icon kosong -> Buletan Cyan murni sebagai fallback
            // Kalau icon terisi -> Background transparan biar logo aplikasinya bersih
            color: notifWindow.currentIcon === "" ? "#00E5FF" : "transparent"
            
            layer.enabled: true
            layer.smooth: true
            clip: true
            
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.centerIn: parent
                // Ukuran dikecilin dikit (misal 32) biar kalau logonya kotak gak kepotong pinggiran radius 40
                width: 32
                height: 32
                fillMode: Image.PreserveAspectFit

                source: {
                    if (!notifWindow.currentIcon) return "";
                    
                    if (notifWindow.currentIcon.startsWith("/") || notifWindow.currentIcon.startsWith("file://")) {
                        return notifWindow.currentIcon.startsWith("/") ? "file://" + notifWindow.currentIcon : notifWindow.currentIcon;
                    }
                    
                    return "image://icon/" + notifWindow.currentIcon;
                }
            }

            // Efek membal (pulse) tetep jalan, baik buat ikon asli maupun buletan cyan
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: notifWindow.hasNotif
                NumberAnimation { to: 0.4; duration: 700 }
                NumberAnimation { to: 1.0; duration: 700 }
            }
        }

        // 2. Container Teks (Dibuat melayang di sebelah kanan Ikon)
        Item {
            id: textContainer
            anchors.left: iconContainer.right
            anchors.leftMargin: 14
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            height: 40

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: notifWindow.currentSummary
                    color: "white"
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight 
                }

                Text {
                    Layout.fillWidth: true
                    text: notifWindow.currentBody
                    color: "#A0AEC0"
                    font.pixelSize: 11
                    elide: Text.ElideRight 
                }
            }

            // Nama Aplikasi di pojok kanan bawah container teks
            Text {
                text: notifWindow.currentApp.toUpperCase()
                color: "#00E5FF"
                font.pixelSize: 9
                font.bold: true
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2
            }
        }

        // Dismiss area kalau diklik langsung ilang
        MouseArea {
            anchors.fill: parent
            onClicked: {
                notifWindow.hasNotif = false
                hideTimer.stop()
            }
        }
    }
}
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

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick
import QtQuick.Layouts
import QtCore

ShellRoot {
    id: rootEntry

    // ==================== GLOBAL STATES ====================
    property string wallpaperPath: ""
    property string pendingPassword: ""
    property bool errorVisible: false
    property bool isAuthenticating: false

    readonly property string configPath:
        StandardPaths.writableLocation(StandardPaths.ConfigLocation)
        .toString().replace("file://", "")
        + "/Sreetx-Neo/wallpapers/wallpapers.json"

    // ==================== LOAD WALLPAPER DARI JSON ====================
    function loadWallpaper() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + configPath + "?t=" + Date.now(), true)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                try {
                    var json = JSON.parse(xhr.responseText)
                    wallpaperPath = json.lockscreen || ""
                } catch (e) {
                    wallpaperPath = ""
                }
            }
        }
        xhr.send()
    }

    Component.onCompleted: loadWallpaper()

    // ==================== ERROR RESET TIMER ====================
    Timer {
        id: errorTimer
        interval: 2000
        repeat: false
        onTriggered: rootEntry.errorVisible = false
    }

    // ==================== PAM AUTH (FIXED FOR QT6) ====================
    PamContext {
        id: pamAuth
        config: "hyprlock" 
        user: Quickshell.userName

        // FIX: Samain nama variabelnya sama yang dikirim PAM
        onPamMessage: function(message, echo, error, responseRequired) {
            console.log("🔍 [CCTV PAM] Pesan dari sistem:", pamAuth.message, "| Butuh respon?", pamAuth.responseRequired, " | echo: ", pamAuth.echo, " | error: ", pamAuth.error)
            console.log(" [CCTVc PAM] password: " + rootEntry.pendingPassword)
            
            if (pamAuth.responseRequired) {
                console.log("🔍 [CCTV PAM] Ngirim password...")
                console.log("🔍 [CCTV PAM] ISI PASSWORD YANG MAU DIKIRIM: '" + rootEntry.pendingPassword + "'")
                console.log("🔍 [CCTV PAM] Panjang karakter:", rootEntry.pendingPassword.length)
                pamAuth.respond(rootEntry.pendingPassword)
                rootEntry.pendingPassword = ""
            }
        }

        onCompleted: function(result) {
            console.log("🏁 [CCTV PAM] Selesai! Kode Hasil:", result)
            rootEntry.isAuthenticating = false
            
            if (result === PamResult.Success) {
                console.log("🔓 [CCTV PAM] SUKSES! Buka gembok...")
                lock.locked = false 
                Qt.quit()           
            } else {
                console.log("❌ [CCTV PAM] GAGAL!")
                rootEntry.errorVisible = true
                errorTimer.restart()
            }
        }
    }

    // ==================== WAYLAND SESSION LOCK ====================
    WlSessionLock {
        id: lock
        locked: true // FIX: Properti aslinya adalah locked, bukan active!

        // Di sini "magic"-nya. WlSessionLockSurface otomatis di-spawn 
        // ke semua layar (termasuk eGPU/external monitor) secara otomatis.
        WlSessionLockSurface {
            id: lockSurface

            Rectangle {
                id: rootItem
                anchors.fill: parent
                color: "#0d0d0d"

                // ── Wallpaper dari JSON ──
                Image {
                    anchors.fill: parent
                    source: rootEntry.wallpaperPath !== "" ? "file://" + rootEntry.wallpaperPath : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 1000       // Durasi efek fade-in (1000ms = 1 detik). Sesuaikan selera!
                            easing.type: Easing.OutCubic 
                            // Easing OutCubic bikin animasinya kerasa "snappy" tapi halus
                            // (cepat di awal, melambat secara elegan di akhir)
                        }
                    }
                }

                // ── Overlay gelap tipis ──
                Rectangle {
                    anchors.fill: parent
                    color: "#55000000"
                }

                // ==================== KONTEN TENGAH ====================
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    // ── Jam besar ──
                    Text {
                        id: clockText
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatTime(new Date(), "HH:mm")
                        font.pixelSize: 100
                        font.weight: Font.Bold
                        color: "#ffffff"
                        style: Text.Outline
                        styleColor: "#22000000"
                        renderType: Text.NativeRendering

                        opacity: status === clockText.Ready ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 1000       // Durasi efek fade-in (1000ms = 1 detik). Sesuaikan selera!
                                    easing.type: Easing.OutCubic 
                                    // Easing OutCubic bikin animasinya kerasa "snappy" tapi halus
                                    // (cepat di awal, melambat secara elegan di akhir)
                                }
                            }

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm")
                        }
                    }

                    // ── Tanggal ──
                    Text {
                        id: dateText
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(), "dddd, dd MMMM yyyy")
                        font.pixelSize: 18
                        color: "#dddddd"
                        renderType: Text.NativeRendering

                        Timer {
                            interval: 60000
                            running: true
                            repeat: true
                            onTriggered: dateText.text = Qt.formatDate(new Date(), "dddd, dd MMMM yyyy")
                        }
                    }

                    // ── Spacer ──
                    Item { Layout.preferredHeight: 28 }

                    // ── Password field ──
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 300
                        height: 42
                        radius: 6
                        color: "#33ffffff"
                        border.color: rootEntry.errorVisible
                            ? "#ff5555"
                            : passwordField.activeFocus
                                ? "#00e5ff"
                                : "#66ffffff"
                        border.width: 1.5

                        // Placeholder
                        Text {
                            anchors.centerIn: parent
                            text: "Masukkan password..."
                            color: "#99ffffff"
                            font.pixelSize: 14
                            visible: passwordField.text.length === 0 && !passwordField.activeFocus
                        }

                        // Cursor blinking
                        Rectangle {
                            id: cursor
                            visible: passwordField.activeFocus && passwordField.text.length === 0
                            width: 1.5
                            height: 20
                            color: "#ffffff"
                            anchors.centerIn: parent

                            SequentialAnimation on opacity {
                                running: cursor.visible
                                loops: Animation.Infinite
                                NumberAnimation { to: 0; duration: 500 }
                                NumberAnimation { to: 1; duration: 500 }
                            }
                        }

                        // Dots indikator password
                        Row {
                            anchors.centerIn: parent
                            spacing: 7
                            visible: passwordField.text.length > 0

                            Repeater {
                                model: Math.min(passwordField.text.length, 24)
                                delegate: Rectangle {
                                    width: 7
                                    height: 7
                                    radius: 4
                                    color: "#ffffff"
                                }
                            }
                        }

                        TextInput {
                            id: passwordField
                            anchors.fill: parent
                            echoMode: TextInput.Password
                            color: "transparent"
                            selectionColor: "transparent"
                            selectedTextColor: "transparent"
                            font.pixelSize: 1
                            focus: true
                            cursorVisible: false

                            Keys.onReturnPressed: {
                                // FIX: Gunakan passwordField.text secara eksplisit agar tidak salah scope
                                if (passwordField.text.length > 0) {
                                    
                                    // Pintu darurat dev
                                    if (passwordField.text === "dev") {
                                        console.log("🔓 Cheat code activated! Unlocking...");
                                        lock.locked = false;
                                        Qt.quit();
                                        return;
                                    }
                                    
                                    console.log("⌨️ [TEXTFIELD] Mencoba mengambil teks keyboard...")
                                    rootEntry.pendingPassword = passwordField.text
                                    
                                    // LOG DEBUG: Intip isi dan panjang karakter password sebelum dihapus
                                    console.log("⌨️ [TEXTFIELD] Password tersimpan di pending: '" + rootEntry.pendingPassword + "' (Panjang: " + rootEntry.pendingPassword.length + ")")
                                    
                                    passwordField.text = "" // Amankan field UI
                                    rootEntry.isAuthenticating = true
                                    rootEntry.errorVisible = false
                                    
                                    console.log("⏳ [TEXTFIELD] Menjalankan pamAuth.start()...")
                                    pamAuth.start()
                                }
                            }
                            Component.onCompleted: forceActiveFocus()
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: passwordField.forceActiveFocus()
                        }
                    }

                    // ── Pesan status / error ──
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: {
                            if (rootEntry.errorVisible) return "Salah Ngentod! Pegi sana jauh jauh, syuhh..."
                            if (rootEntry.isAuthenticating) return "Authentication..."
                            return ""
                        }
                        color: rootEntry.errorVisible ? "#ff5555" : "#aaaaaa"
                        font.pixelSize: 13
                        visible: text.length > 0

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }

                // ── Hint bawah ──
                Text {
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                        bottomMargin: 20
                    }
                    text: "Tekan Enter untuk unlock"
                    color: "#66ffffff"
                    font.pixelSize: 12
                }
            }
        }
    }
}
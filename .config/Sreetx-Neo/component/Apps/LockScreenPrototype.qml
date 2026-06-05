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

// ** Type: Prototype **
// ** Status: Don't Run This! **

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    // =========================================================
    // ⚠️ ATUR KONFIGURASI KAMU DI SINI
    // =========================================================
    property string username: "programmer" // Ganti pake username Linux kamu
    property string jsonPath: "file:///home/programmer/.config/Sreetx-Neo/wallpapers/wallpapers.json" // Sesuaikan path JSON kamu

    Window {
        id: lockWindow
        width: Screen.width
        height: Screen.height
        visible: true
        
        // Bikin window fullscreen, borderless, dan stays on top
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "#050505"

        // Tempat nyimpen path gambar hasil parsing JSON
        property string wallpaperPath: ""

        // =========================================================
        // 1. ENGINE AUTOMATION: BACKEND AUTHENTICATION (PAM)
        // =========================================================
        Process {
            id: pamAuth
            command: ["pamtester", root.username, "authenticate"]
            running: false
            
            // Fix Bug: Pake onRunningChanged buat deteksi proses selesai
            onRunningChanged: {
                if (!running) { 
                    if (exitCode === 0) {
                        console.log("🔓 Password Benar! Unlock session...");
                        Qt.quit(); // Matikan quickshell / tutup lockscreen
                    } else {
                        console.log("❌ Password Salah!");
                        errorText.visible = true;
                        passwordField.enabled = true;
                        passwordField.text = "";
                        passwordField.forceActiveFocus();
                    }
                }
            }
        }

        // =========================================================
        // 2. ENGINE PARSING: BACA FILE JSON WALLPAPER
        // =========================================================
        function loadWallpaperFromJson() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", root.jsonPath, true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200 || xhr.status === 0) {
                        try {
                            var data = JSON.parse(xhr.responseText);
                            // Memastikan key "lockscreen" ada di dalam JSON kamu
                            if (data.lockscreen) {
                                lockWindow.wallpaperPath = "file://" + data.lockscreen;
                            }
                        } catch (e) {
                            console.log("Error parsing JSON: " + e);
                        }
                    }
                }
            }
            xhr.send();
        }

        // Trigger loading data saat QML siap render
        Component.onCompleted: {
            loadWallpaperFromJson();
            timeTimer.start();
        }

        // =========================================================
        // 3. TAMPILAN UI (FRONTEND)
        // =========================================================
        
        // Layer Paling Bawah: Wallpaper Gambar
        Image {
            id: bgImage
            anchors.fill: parent
            source: lockWindow.wallpaperPath
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        // Layer Tengah: Dimmer Overlay (Biar teks gampang dibaca)
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.5) // Gelap transparan 50%
        }

        // Layer Atas: Konten Teks & Input
        Column {
            anchors.centerIn: parent
            spacing: 25

            // Widget Jam Big Size
            Text {
                id: clockText
                text: "00:00"
                font.pixelSize: 90
                font.bold: true
                color: "#ffffff"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Widget Tanggal Lengkap
            Text {
                id: dateText
                text: "Loading..."
                font.pixelSize: 22
                color: "#b5bfe2" // Warna teks soft pastel
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Spacer kosong biar gak terlalu mepet jam
            Item { width: 1; height: 15 }

            // Kolom Input Password
            TextField {
                id: passwordField
                width: 280
                height: 45
                anchors.horizontalCenter: parent.horizontalCenter
                echoMode: TextInput.Password
                placeholderText: "Masukkan Password..."
                horizontalAlignment: TextInput.AlignHCenter
                font.pixelSize: 16
                color: "#cdd6f4"
                
                background: Rectangle {
                    color: Qt.rgba(255, 255, 255, 0.08)
                    radius: 8
                    border.color: Qt.rgba(255, 255, 255, 0.15)
                    border.width: 1
                }
                
                // Otomatis fokus ke kolom teks pas lockscreen aktif
                Component.onCompleted: forceActiveFocus()
                
                onAccepted: {
                    if (text.length === 0) return;
                    errorText.visible = false;
                    enabled = false; // Matikan input sementara pas ngecek password
                    
                    pamAuth.running = true;
                    pamAuth.write(text + "\n"); // Lempar password ke stdin pamtester
                }
            }

            // Notifikasi Error (Default Tersembunyi)
            Text {
                id: errorText
                text: "Password salah, Sans. Coba lagi!"
                color: "#f38ba8" // Warna merah pastel
                font.pixelSize: 14
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // =========================================================
        // 4. TIMER UPDATE JAM & TANGGAL (REALTIME)
        // =========================================================
        Timer {
            id: timeTimer
            interval: 1000
            repeat: true
            onTriggered: {
                var date = new Date();
                clockText.text = date.toLocaleTimeString(Qt.locale("id_ID"), "hh:mm");
                dateText.text = date.toLocaleDateString(Qt.locale("id_ID"), Locale.LongFormat);
            }
        }
    }
}
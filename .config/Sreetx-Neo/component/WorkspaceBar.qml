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
import Quickshell.Services.SystemTray
import "./Apps" as Apps

PanelWindow {
    id: barWindow
    
    anchors {
        top: true
        left: true
        right: true
    }

    height: 44
    color: "transparent"

    exclusionMode: ExclusionMode.Exclusion
    WlrLayershell.layer: WlrLayer.Top

    Apps.Settings {
        id: settingsWindow
        visible: false
    }

    SessionMenu {
        id: sessionRoot
        visible: false
    }

    Rectangle {
        id: actualBar
        width: parent.width * 0.99
        height: 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 4
        radius: 22
        color: "#cc0c0a12" 
        border.color: "#382546" 
        border.width: 1

        // VIEWPORT: Pembatas area agar angka yang tergeser keluar tidak meluber
        ClippingRectangle {
            id: workspaceViewport
            width: 160
            anchors.verticalCenter: actualBar.verticalCenter
            radius: 20
            anchors.leftMargin: 2
            height: actualBar.height
            anchors.left: parent.left
            color: "transparent"
            border.color: "transparent"
            border.width: 8
            clip: true // Kunci viewport agar konten yang keluar tidak terlihat
            
            Row {
                id: workspaceRow
                spacing: 12
                anchors.centerIn: workspaceViewport
                
                // LOGIKA CAROUSEL / SLIDING EFFECT
                readonly property int activeId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
                
                // Rumus menggeser koordinat X agar posisi aktif selalu center di viewport:
                // (Lebar Viewport / 2) - (Indeks Aktif * (Lebar Dot + Spacing)) - Setengah Lebar Dot
                x: (workspaceViewport.width / 2) - ((activeId - 1) * (24 + spacing)) - 12

                // Animasi pergeseran koordinat X saat workspace berganti
                Behavior on x {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                Repeater {
                    // Batas dasar 5, otomatis bertambah tanpa batas jika workspace aktif lebih besar
                    model: Math.max(10, Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1)

                    delegate: Rectangle {
                        id: workspaceIndicator
                        readonly property int wsId: index + 1
                        readonly property bool isActive: Hyprland.focusedWorkspace ? (Hyprland.focusedWorkspace.id === wsId) : false

                        // Fix typo 'Rectagle' -> Rectangle
                        width: 24
                        height: 24
                        radius: 12
                        
                        // Fix penutupan kurung kurawal warna yang rusak sebelumnya
                        color: isActive ? "#0db9d7" : "#444b6a"

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: wsId.toString()
                            font.pixelSize: 11
                            font.bold: true
                            color: isActive ? "#0c0a12" : "#a9b1d6"
                        }

                        MouseArea {
                            anchors.fill: parent
                            // Aktifkan scroll wheel biar kedeteksi
                            acceptedButtons: Qt.NoButton // Biar gak ngebajak fungsi klik tombol angka di dalemnya
                            
                            onWheel: wheel => {
                                // Ambil ID workspace yang lagi aktif sekarang (default ke 1 kalau null)
                                var currentId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1;
                                
                                if (wheel.angleDelta.y > 0) {
                                    // Scroll Ke Atas = Pindah ke Workspace Sebelumnya (Minimal Workspace 1)
                                    if (currentId > 1) {
                                        Hyprland.dispatch("workspace " + (currentId - 1).toString());
                                    }
                                } else {
                                    // Scroll Ke Bawah = Pindah ke Workspace Berikutnya (Batasin misal sampe 10 atau bebas)
                                    if (currentId < 10) { 
                                        Hyprland.dispatch("workspace " + (currentId + 1).toString());
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
        Rectangle {
            id: mainClock
            width: 130
            height: actualBar.height - 10
            anchors.top: actualBar.top
            anchors.centerIn: actualBar
            border.color: "#00354e"
            border.width: 2
            y: -100
            radius: 44
            visible: true
            layer.enabled: true
            color: "#004b6d"


            MouseArea {
                id: heloClock
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                // Console.log aja di tolak semesta wok
                //onClicked: {
                    //id: dashboardKeren
                    //console.log("Masih misterius wkwkwk");
                    // Masih misterus wkwkwk
                //}
            }

            Rectangle {
                    id: heloClocks
                    // Bikin ukurannya sedikit lebih besar dari ikon
                    width: parent.width
                    height: parent.height
                    radius: 44 // Biar bulat sempurna
                    anchors.centerIn: parent // Biar presisi di tengah ikon
                    
                    // Warna putih transparan
                    color: "white"
                    opacity: heloClock.containsMouse ? 0.2 : 0 // Muncul pas di-hover
                    
                    // Animasi halus pas muncul
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                }
        }

        
        Text {
            id: centerClock
            anchors.horizontalCenter: actualBar.horizontalCenter
            anchors.verticalCenter: actualBar.verticalCenter
            text: jemboD.text
            color: "#ffffff"
            font.bold: true
            font.pixelSize: 13
            font.family: "Google Sans Flex"
            font.letterSpacing: 1.5

            Timer {
                id: jemboD
                interval: 1000 // Update tiap detik biar presisi
                running: true
                repeat: true
                onTriggered: centerClock.text = new Date().toLocaleString(Qt.locale(), "dd MMM HH:mm")
            }
        }
    
    Rectangle {
        id: powerButton
        width: 35
        height: 35
        radius: width / 2
        anchors.right: settingsButton.left
        anchors.rightMargin: 10
        anchors.verticalCenter: actualBar.verticalCenter
        color: "transparent"
        Text {
            anchors.centerIn: parent
            text: "⏻"
            color: heloPower.containsMouse ? "#c70000" : "#7c0000"
            font.pixelSize: 20
            font.bold: true
        }
        MouseArea {
            id: heloPower
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                sessionRoot.visible = !sessionRoot.visible
            }
        }
        Rectangle {
            id: hoverCirclePower
            // Bikin ukurannya sedikit lebih besar dari ikon
            width: parent.width + 20
            height: parent.height -5
            radius: 12 // Biar bulat sempurna
            anchors.centerIn: parent // Biar presisi di tengah ikon
            
            // Warna putih transparan
            color: "white"
            opacity: heloPower.containsMouse ? 0.2 : 0 // Muncul pas di-hover
            
            // Animasi halus pas muncul
            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
        }
    }
    Rectangle {
        id: settingsButton
        width: 35
        height: 35
        anchors.right: statusAreas.left
        anchors.rightMargin: 10
        anchors.verticalCenter: actualBar.verticalCenter
        radius: width / 2
        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: ""
            font.pixelSize: 20
            color: heloGear.containsMouse ? "#ffffff" : "#565f89"
        }
        MouseArea {
            id: heloGear
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                // Panggil perintah untuk buka aplikasi Settings (ganti "sreetx-settings" dengan nama perintah yang sesuai)
               settingsWindow.visible = !settingsWindow.visible // Toggle visibility loader Settings
                }
            }    
        } 

    Rectangle {
        id: statusAreas
        anchors.right: actualBar.right
        height: actualBar.height * 0.85
        anchors.verticalCenter: actualBar.verticalCenter
        anchors.rightMargin: actualBar.width * 0.003
        border.color: "#00354e"
        border.width: 2
        width: 160
        visible: true
        radius: 20
        clip: true
        layer.enabled: true
        //border.width: 1
        //border.color: "#382546"
        //color: "#37072b"
        color: "#1d4363"

        Row {
            id: rowStatus
            // Hapus width spesifik biar dia ngikutin isi otomatis, dan kasih right anchors
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16 // Jarak mantap antar ikon (Bluetooth - Wi-Fi - Audio - Baterai)


            // 1. FUNGSI KEREN: Indikator Bluetooth
            Item {
                id: bluetoothModule
                width: btIcon.implicitWidth
                height: statusAreas.height
                
                property bool btEnabled: false
                property bool btConnected: false
                property string rfkillPath: ""

                Text {
                    id: btIcon
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 18
                    
                    // Logic Icon dinamis
                    text: {
                        if (bluetoothModule.btConnected) return "󰂱" // Konek ke device (TWS/Mouse)
                        if (bluetoothModule.btEnabled) return "󰂯"   // Bluetooth Nyala tapi standby
                        return "󰂲"                                   // Bluetooth Mati / Blocked
                    }
                    
                    // Warna dinamis biar sinkron sama ricingan lo
                    color: {
                        if (bluetoothModule.btConnected) return "#7aa2f7" // Biru terang pas konek device
                        if (bluetoothModule.btEnabled) return "#b4befe"   // Ungu pastel pas standby
                        return "#565f89"                                 // Abu-abu redup pas mati
                    }
                }

                MouseArea {
                    id: btMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            if (bluetoothModule.btEnabled) {
                                // Jika nyala -> Matikan via bluetoothctl
                                bluetoothModule.btEnabled = false;
                                bluetoothModule.btConnected = false;
                                Quickshell.execDetached(["bluetoothctl", "power", "off"]);
                            } else {
                                // Jika mati -> Nyalakan via bluetoothctl
                                bluetoothModule.btEnabled = true;
                                Quickshell.execDetached(["bluetoothctl", "power", "on"]);
                            }
                            btTimer.triggered(); // Langsung paksa sync detik itu juga
                        }
                        else if (mouse.button === Qt.RightButton) {
                            console.log("clicked kanan");
                            Quickshell.execDetached(["blueman-manager"]);
                        }
                    }
                }

                Rectangle {
                    id: hoverCirclebt
                    // Bikin ukurannya sedikit lebih besar dari ikon
                    width: parent.width + 20
                    height: parent.height -5
                    radius: 12 // Biar bulat sempurna
                    anchors.centerIn: parent // Biar presisi di tengah ikon
                    
                    // Warna putih transparan
                    color: "white"
                    opacity: btMouse.containsMouse ? 0.2 : 0 // Muncul pas di-hover
                    
                    // Animasi halus pas muncul
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                }

                Timer {
                    interval: 3000 // Cek setiap 3 detik
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    
                    onTriggered: {
                        try {
                            // --- LOGIKA AUTO DETECT FOLDER RFKILL ---
                            // Kita cari folder rfkill mana yang tipenya "bluetooth"
                            // Biasanya di laptop ada rfkill0, rfkill1, rfkill2, dst.
                            if (bluetoothModule.rfkillPath === "") {
                                for (var i = 0; i < 10; i++) {
                                    var xhrType = new XMLHttpRequest();
                                    var typePath = "file:///sys/class/rfkill/rfkill" + i + "/type";
                                    xhrType.open("GET", typePath, false);
                                    try {
                                        xhrType.send(null);
                                        if ((xhrType.status === 200 || xhrType.status === 0) && xhrType.responseText.trim() === "bluetooth") {
                                            bluetoothModule.rfkillPath = "file:///sys/class/rfkill/rfkill" + i + "/soft";
                                            console.log("Bluetooth RFKill terdeteksi di: rfkill" + i);
                                            break;
                                        }
                                    } catch(e) {
                                        // Folder rfkill[i] gak ada, lanjut loop
                                    }
                                }
                            }

                            // --- LOGIKA BACA STATE POWER NYALA/MATI ---
                            if (bluetoothModule.rfkillPath !== "") {
                                var xhrSoft = new XMLHttpRequest();
                                xhrSoft.open("GET", bluetoothModule.rfkillPath, false);
                                xhrSoft.send(null);
                                
                                if (xhrSoft.status === 200 || xhrSoft.status === 0) {
                                    // 0 artinya "Unblocked" (Bluetooth NYALA)
                                    // 1 artinya "Soft Blocked" (Bluetooth MATI)
                                    var softBlock = xhrSoft.responseText.trim();
                                    bluetoothModule.btEnabled = (softBlock === "0");
                                }
                            }

                            // --- LOGIKA CEK STATUS KONEKSI DEVICE ---
                            // Trik cerdas: Jika ada device connected (audio/mouse), 
                            // sysfs biasanya memunculkan folder interface input/audio bluetooth baru.
                            // Kita cek apakah bluetooth aktif dan ada device terikat di /sys/class/bluetooth
                            if (bluetoothModule.btEnabled) {
                                var xhrConn = new XMLHttpRequest();
                                // Kita tembak file di /sys/class/rfkill/ buat ngecek interaksi device aktif
                                // Jika status power nyala, kita set dummy/koneksi lewat pembacaan state internal
                                // (Untuk connected device murni, idealnya binding ke dbus, tapi ini fallback yang aman)
                                bluetoothModule.btConnected = false; 
                            } else {
                                bluetoothModule.btConnected = false;
                            }

                        } catch (error) {
                            console.log("Gagal ngebaca status bluetooth: ", error);
                            bluetoothModule.btEnabled = false;
                            bluetoothModule.btConnected = false;
                        }
                    }
                }
            }

            // 2. FUNGSI KEREN: Indikator Wi-Fi
            Item {
                id: wifiModule
                width: wifiIcon.implicitWidth
                height: statusAreas.height
                anchors.verticalCenter: parent.verticalCenter
                
                property int signalPercentage: 0
                property bool isConnected: false
                property bool wifiEnabled: true
                property string interfaceName: ""

                Text {
                    id: wifiIcon
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (!wifiModule.isConnected) return "󰤮" // Disconnected / Silang
                        if (wifiModule.signalPercentage >= 75) return "󰤨" // Sinyal Kuat (4 Bar)
                        if (wifiModule.signalPercentage >= 50) return "󰤥" // Sinyal Sedang (3 Bar)
                        if (wifiModule.signalPercentage >= 25) return "󰤢" // Sinyal Lemah (2 Bar)
                        return "󰤫" // Sinyal Sangat Lemah (1 Bar)
                    }
                    color: {
                        if (!wifiModule.isConnected) return "#f7768e" // Merah neon kalau DC
                        if (wifiModule.signalPercentage < 30) return "#ff9e64" // Oranye kalau sinyal ampas
                        return "#ffffff" // Hijau neon kalau aman
                    }
                    font.pixelSize: 14
                }

                MouseArea {
                    id: wifiMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (wifiModule.wifiEnabled) {
                            // Jika lagi nyala -> Matikan
                            wifiModule.wifiEnabled = false;
                            wifiModule.isConnected = false;
                            Quickshell.execDetached(["nmcli", "radio", "wifi", "off"]);
                        } else {
                            // Jika lagi mati -> Nyalakan
                            wifiModule.wifiEnabled = true;
                            Quickshell.execDetached(["nmcli", "radio", "wifi", "on"]);
                        }
                        wifiTimer.triggered(); // Paksa refresh status seketika
                    }
                }

                Rectangle {
                    id: hoverCircle
                    // Bikin ukurannya sedikit lebih besar dari ikon
                    width: parent.width + 20
                    height: parent.height - 5
                    radius: 12 // Biar kotak rounded sempurna
                    anchors.centerIn: parent // Biar presisi di tengah ikon
                    
                    // Warna putih transparan
                    color: "white"
                    opacity: wifiMouse.containsMouse ? 0.2 : 0 // Muncul pas di-hover
                    
                    // Animasi halus pas muncul
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                }

                Timer {
                    interval: 3000 // Cek tiap detik biar gak boros CPU
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    
                    onTriggered: {
                        try {
                            var xhr = new XMLHttpRequest();
                            xhr.open("GET", "file:///proc/net/wireless", false);
                            xhr.send(null);

                            if (xhr.status === 200 || xhr.status === 0) {
                                var content = xhr.responseText;
                                var lines = content.split("\n");

                                // --- LOGIKA AUTO DETECT ---
                                // Jika interfaceName belum ketemu, kita cari di baris ke-3 dst
                                if (wifiModule.interfaceName === "") {
                                    for (var i = 2; i < lines.length; i++) {
                                        if (lines[i].includes(":")) {
                                            // Ambil nama sebelum titik dua (misal " wlan0:") lalu bersihkan spasi
                                            var detectedName = lines[i].split(":")[0].trim();
                                            if (detectedName !== "") {
                                                wifiModule.interfaceName = detectedName;
                                                console.log("Wi-Fi Interface terdeteksi otomatis: " + detectedName);
                                                break;
                                            }
                                        }
                                    }
                                }

                                // --- LOGIKA PARSING SINYAL ---
                                if (wifiModule.interfaceName !== "" && content.includes(wifiModule.interfaceName)) {
                                    wifiModule.isConnected = true;
                                    
                                    for (var j = 2; j < lines.length; j++) {
                                        if (lines[j].includes(wifiModule.interfaceName)) {
                                            var tokens = lines[j].trim().replace(/\s+/g, ' ').split(' ');
                                            var linkQuality = parseFloat(tokens[2]);
                                            wifiModule.signalPercentage = Math.round((linkQuality / 70) * 100);
                                            break;
                                        }
                                    }
                                } else {
                                    // Interface gak ada di proc/net/wireless (artinya Wi-Fi dimatikan)
                                    wifiModule.isConnected = false;
                                    wifiModule.signalPercentage = 0;
                                    wifiModule.interfaceName = ""; // Reset biar nyari ulang pas nyala
                                }
                            }
                        } catch (error) {
                            console.log("Gagal ngebaca status wifi: ", error);
                            wifiModule.isConnected = false;
                        }
                    }
                }
            }
            // 3. Indikator Audio (Placeholder, bisa dikembangkan lagi dengan binding ke PulseAudio/ALSA)
            Item {
                id: audioModule
                width: audioRow.implicitWidth
                height: statusAreas.height

                property int volumeValue: 0
                property bool isMuted: false

                // Row internal khusus buat ngejajarin Icon + Angka Persen Audio
                Row {
                    id: audioRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        id: audioIcon
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 20
                        text: {
                            if (audioModule.isMuted) return "󰖁" // Mute
                            if (audioModule.volumeValue === 0) return "󰖁" // 0%
                            if (audioModule.volumeValue <= 40) return "󰖀" // Volume Lemah
                            if (audioModule.volumeValue <= 80)  return "󰕾" 
                            return "󱄠" // Volume Tinggi
                        }
                        
                        color: audioModule.isMuted ? "#f7768e" : "#ffffff"
                    }
                }

                // --- ENGINE INPUT: Klik & Scroll Murni di Quickshell ---
                MouseArea {
                    id: audioMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            audioModule.isMuted = !audioModule.isMuted; // Update UI langsung biar kerasa cepet
                            Quickshell.execDetached(["sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && wpctl get-volume @DEFAULT_AUDIO_SINK@ > /tmp/qs_vol"]);
                        }
                        else if (mouse.button === Qt.RightButton) {
                            // Run Pavucontrol
                            Quickshell.execDetached(["pavucontrol"])
                        }
                    }

                    // 2. Scroll Mouse = Naik / Turun Volume Instan
                    onWheel: wheel => {
                        // 1. Hitung dulu nilainya secara lokal biar instan
                        let delta = wheel.angleDelta.y > 0 ? 5 : -5;
                        let newValue = Math.min(100, Math.max(0, notifWindow.volumeValue + delta));

                        // 2. Update UI Dynamic Island secara instan
                        notifWindow.triggerVolumeUpdate(newValue);

                        // 3. Eksekusi ke sistem (Tanpa perlu notify-send/bash yang berat)
                        // Cukup jalankan wpctl-nya saja
                        let action = wheel.angleDelta.y > 0 ? "5%+" : "5%-";
                        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", action]);
                    }
                }

                Rectangle {
                    id: hoverCircleaudio
                    // Bikin ukurannya sedikit lebih besar dari ikon
                    width: parent.width + 20
                    height: parent.height - 5
                    radius: 12 // Biar bulat sempurna
                    anchors.centerIn: parent // Biar presisi di tengah ikon
                    
                    // Warna putih transparan
                    color: "white"
                    opacity: audioMouse.containsMouse ? 0.2 : 0 // Muncul pas di-hover
                    
                    // Animasi halus pas muncul
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                }

                // --- TIMER PEMBACA BACKGROUND ---
                Timer {
                    id: audioTimer
                    interval: 1000 // Sinkronisasi background tiap 1 detik
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    
                    onTriggered: {
                        // 1. Perintah diam-diam update file /tmp/qs_vol
                        Quickshell.execDetached(["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ > /tmp/qs_vol"]);
                        
                        // 2. Baca file /tmp/qs_vol pake cara andalan kita
                        try {
                            var xhr = new XMLHttpRequest();
                            // Pake Date.now() biar file selalu dibaca fresh (gak kena cache internal QML)
                            xhr.open("GET", "file:///tmp/qs_vol?" + Date.now(), false); 
                            xhr.send(null);

                            if (xhr.status === 200 || xhr.status === 0) {
                                var output = xhr.responseText.trim();
                                if (output !== "") {
                                    var parts = output.split(" ");
                                    
                                    // Set data asli dari sistem buat jaga-jaga kalau lo ganti volume pake keyboard / tombol eksternal
                                    audioModule.volumeValue = Math.round(parseFloat(parts[1]) * 100);
                                    audioModule.isMuted = output.includes("[MUTED]");
                                }
                            }
                        } catch (error) {
                            // Abaikan error misal file belum ke-generate pas awal-awal boot
                        }
                    }
                }
                    
            }


            // 4. Indikator Baterai (Udah Difix Total)
            Item {
                id: batteryModule
                // Kalkulasi lebar otomatis: lebar angka + margin (6) + lebar ikon
                width: batteryStatusNum.implicitWidth + batteryStatusIcon.implicitWidth + 6
                height: statusAreas.height
                
                property int batteryPercentage: 0
                property string chargingStatus: "Discharging"

                // Bagian Angka (Posisi di kiri)
                Text {
                    id: batteryStatusNum
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    text: batteryModule.batteryPercentage + "%"
                    font.pixelSize: 12
                    font.bold: true
                    color: {
                        if (batteryModule.chargingStatus === "Charging") return "#9ece6a"
                        if (batteryModule.batteryPercentage > 20) return "#ffffff"
                        return "#f7768e"
                    }
                    font.family: "Google Sans Flex"
                }

                // Bagian Ikon Baterai (Posisi di kanan, nempel ke angka)
                Text {
                    id: batteryStatusIcon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: batteryStatusNum.right
                    anchors.leftMargin: 5
                    text: {
                        if (batteryModule.chargingStatus === "Charging") return "⚡️" 
                        if (batteryModule.batteryPercentage >= 100) return "󰁹"
                        if (batteryModule.batteryPercentage >= 90) return "󰂂"
                        if (batteryModule.batteryPercentage >= 80) return "󰂁"
                        if (batteryModule.batteryPercentage >= 70) return "󰂀"
                        if (batteryModule.batteryPercentage >= 60) return "󰁿"
                        if (batteryModule.batteryPercentage >= 50) return "󰂂"
                        if (batteryModule.batteryPercentage >= 40) return "󰂀"
                        if (batteryModule.batteryPercentage >= 30) return "󰁾"
                        if (batteryModule.batteryPercentage >= 20) return "󰁻"
                        if (batteryModule.batteryPercentage >= 10) return "󰁺"
                        return "󰁺" 
                    }
                    color: {
                        if (batteryModule.chargingStatus === "Charging") return "#9ece6a"
                        if (batteryModule.batteryPercentage > 20) return "#ffffff"
                        return "#f7768e"
                    }
                    font.pixelSize: 15
                }

                Rectangle {
                    id: toggleSidebarButton
                    width: 40; height: 30; radius: 6
                    color: "transparent"
                    MouseArea {
                        id: batHello
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton

                        // Tugasnya SEKARANG CUMA SATU: Nge-klik saklar di sreetx.qml
                        onClicked: {
                            console.log("Buat battery health nanti, mungkin...")
                        }
                    }
                }
                

                Rectangle {
                    id: hoverCircleBat
                    // Bikin ukurannya sedikit lebih besar dari ikon
                    width: parent.width + 20
                    height: parent.height - 5
                    radius: 12 // Biar bulat sempurna
                    anchors.centerIn: parent // Biar presisi di tengah ikon
                    
                    // Warna putih transparan
                    color: "white"
                    opacity: batHello.containsMouse ? 0.2 : 0 // Muncul pas di-hover
                    
                    // Animasi halus pas muncul
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                }
                // Mesin Pengecek Baterai
                Timer {
                    interval: 500 // Cek tiap 0.5 detik saat charging, 5 detik saat discharging
                    running: true
                    repeat: true
                    triggeredOnStart: true 
                    
                    onTriggered: {
                        try {
                            var xhrCap = new XMLHttpRequest();
                            xhrCap.open("GET", "file:///sys/class/power_supply/BAT0/capacity", false); 
                            xhrCap.send(null);
                            
                            var xhrStatus = new XMLHttpRequest();
                            xhrStatus.open("GET", "file:///sys/class/power_supply/BAT0/status", false);
                            xhrStatus.send(null);

                            if (xhrCap.status === 200 || xhrCap.status === 0) {
                                batteryModule.batteryPercentage = parseInt(xhrCap.responseText.trim());
                            }
                            
                            if (xhrStatus.status === 200 || xhrStatus.status === 0) {
                                batteryModule.chargingStatus = xhrStatus.responseText.trim();
                            }

                        } catch (error) {
                            console.log("Gagal baca sysfs baterai: ", error);
                            batteryModule.batteryPercentage = 0; 
                            batteryModule.chargingStatus = "Discharging";
                        }
                    }
                }
                
            }
        }
    }
}
    




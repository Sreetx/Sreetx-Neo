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
import QtCore

Window {
    id: settingsWindow
    
    width: 1100
    height: 650
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    // sumpah ini gk guna anjir
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2

    onClosing: (close) => {
        close.accepted = false
        settingsWindow.visible = false
    }

    // Background Utama Jendela Settings
    Rectangle {
        id: settingsPengaturan
        anchors.fill: parent
        radius: 14
        color: "#1e1d1d"
        border.color: "#00f0ff"
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#000000"
            radius: 20
            samples: 25
            verticalOffset: 4
        }
    }

    // Header Title Atas
    Text {
        id: titleText
        text: "Settings"
        font.pixelSize: 20
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 15
    }

    // Tombol Close Jendela (X)
    Text {
        id: closeButton
        text: "x"
        font.pixelSize: 24
        color: "white"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.topMargin: 10
        property bool hovered: false
        
        HoverHandler {
            id: closeHover
            onHoveredChanged: closeButton.hovered = hovered
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                settingsWindow.visible = false
            }
        }

        scale: closeButton.hovered ? 2 : 1.0
        Behavior on scale { NumberAnimation { duration: 150 } }
    }

    // =======================================================
    // LAYOUT UTAMA JENDELA (SIDEBAR KIRI & KONTEN KANAN)
    // =======================================================
    RowLayout {
        id: mainLayout
        anchors.top: titleText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 15
        spacing: 15

        // ---------------------------------------------------
        // SISI KIRI: VISUAL PANEL SIDEBAR KAMU
        // ---------------------------------------------------
        Rectangle {
            id: visualPanel
            
            // Kunci untuk RowLayout: Menggunakan properti Layout, bukan anchors fill!
            Layout.preferredWidth: 240  // Sifat lebar dasar sidebar kamu
            Layout.fillHeight: true     // Memanjang otomatis ke bawah
            
            color: "#0b0b11" 
            border.color: "#1b1b28"
            radius: 12
            
            // Animasi transisi lebar sidebar kamu tetap aman di sini
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 180 } }

            // Pembungkus komponen internal sidebar agar tersusun vertikal dari atas ke bawah
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // A. KODE PROFIL CYBERPUNK KAMU
                Item {
                    id: userProfileSection
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    Layout.topMargin: 8

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
                        anchors.fill: parent
                        spacing: 12

                        ClippingRectangle {
                            id: avatarFrame
                            width: 54
                            height: 54
                            radius: 27
                            color: "transparent"
                            border.color: "#00f0ff"
                            border.width: 1
                            clip: true

                            Image {
                                id: avatarImage
                                anchors.fill: parent
                                source: "file:///home/" + userProfileSection.systemUser + "/.face"
                                fillMode: Image.PreserveAspectCrop
                                
                                onStatusChanged: {
                                    if (status === Image.Error && source === "file:///home/" + userProfileSection.systemUser + "/.face") {
                                        source = "file:///home/" + userProfileSection.systemUser + "/.face.icon";
                                    }
                                }
                            }
                        }

                        Column {
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: userProfileSection.systemUser ? (userProfileSection.systemUser.charAt(0).toUpperCase() + userProfileSection.systemUser.slice(1)) : "Admin"
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 15
                                font.family: "Google Sans Flex"
                            }

                            Text {
                                text: userProfileSection.linuxDistro.toUpperCase()
                                color: "#00f0ff"
                                font.pixelSize: 11
                                font.family: "Google Sans Flex"
                            }
                        }
                    }
                }

                // B. GARIS PEMBATAS NEON CYAN KAMU
                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    color: "#00f0ff"
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                }

                // C. MENU LISTVIEW UTAMA (Nempel pas di bawah garis pembatas)
                ListView {
                    id: menuList
                    Layout.fillWidth: true
                    Layout.fillHeight: true // Menghabiskan sisa space ke bawah secara fleksibel
                    model: menuModel
                    spacing: 6
                    currentIndex: 0
                    clip: true

                    delegate: Rectangle {
                        id: delegateItem
                        width: menuList.width
                        height: 38
                        radius: 8
                        
                        color: ListView.isCurrentItem ? "#0a7178" : (itemMouseArea.containsMouse ? "#3a3939" : "transparent")

                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 15
                            spacing: 12 // <<< Jarak minimal setelah ikon kamu

                            // Penampung Ikon
                            Text {
                                text: ikon
                                color: "white"
                                font.pixelSize: 16
                            }

                            // Penampung Teks Judul
                            Text {
                                text: name
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true // <<< Auto tebal biar makin gahar!
                                font.family: "Google Sans Flex"
                            }
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 3
                            height: 18
                            color: "#00f0ff"
                            visible: ListView.isCurrentItem
                            radius: 1.5
                        }

                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: menuList.currentIndex = index
                        }
                    }
                }
            }
        }

        // ---------------------------------------------------
        // SISI KANAN: TEMPAT KONTEN HALAMAN (STACK LAYOUT)
        // ---------------------------------------------------
        StackLayout {
            id: pageContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: menuList.currentIndex 

            // Halaman 1: Connection
            Item {
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "Wi-Fi Settings"; color: "white"; font.pixelSize: 18; font.bold: true }
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

            Item {
                id: hotsPotPage
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "Hotspot Settings"; color: "white"; font.pixelSize: 18; font.bold: true }
                    Item { Layout.fillHeight: true }
                    Text {
                        text: "Dalam Pengembangan! <br />Nanti bakal ada opsi buat atur hotspot Wi-Fi, tethering, dan lain-lain."
                        color: "white"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        anchors.centerIn: parent
                        font.family: "Google Sans Flex"
                    }
                }
            }

            Item {
                id: powerPage
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "Power Settings"; color: "white"; font.pixelSize: 18; font.bold: true }
                    Item { Layout.fillHeight: true }
                    Text {
                        text: "Dalam Pengembangan! <br />Nanti bakal ada opsi buat atur pengaturan daya, sleep, dan lain-lain."
                        color: "white"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        anchors.centerIn: parent
                        font.family: "Google Sans Flex"
                    }
                }
            }


            // Halaman 2: Personalization
            Item {
                ColumnLayout {
                    id: personalizationRoot
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "Wallpaper Settings"; color: "white"; font.pixelSize: 18; font.bold: true }
                    Item { Layout.fillHeight: true }
                    PersonalizationTab {
                        id: personalizationPage
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Item {
                id: cursorThemesPage
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "Cursor Themes"; color: "white"; font.pixelSize: 18; font.bold: true }
                    Item { Layout.fillHeight: true }
                    Text {
                        text: "Dalam Pengembangan! <br />Nanti bakal ada opsi buat atur tema kursor."
                        color: "white"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        anchors.centerIn: parent
                        font.family: "Google Sans Flex"
                    }
                }
            }

            Item {
                id: cursorSettingsPage
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "Cursor Settings"; color: "white"; font.pixelSize: 18; font.bold: true }
                    Item { Layout.fillHeight: true }
                    Text {
                        text: "Dalam Pengembangan! <br />Nanti bakal ada opsi buat atur tema kursor."
                        color: "white"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        anchors.centerIn: parent
                        font.family: "Google Sans Flex"
                    }
                }
            }

            Item {
                id: aboutPage
                function getSystemInfo(cmd) {
                    // Pake execSync biar datanya langsung muncul pas dibuka
                    var result = Quickshell.exec(["sh", "-c", cmd]);
                    return result.stdout.trim();
                }

                property string model: "Unknown"
                property string ram: "Unknown"
                property string cpu: "Unknown"
                property string os: "Unknown"
                property string shell: "Unknown"
                property string windowing: Quickshell.env("XDG_SESSION_TYPE") ? Quickshell.env("XDG_SESSION_TYPE").toLowerCase() : "Wayland"
                property string hostname: Quickshell.env("USER") || "Unknown"
                property string disks: "Unknown"
                property string osIcon: "Unknown"

                // 2. FUNGSI HELPER SUPER CEPAT BUAT BACA FILE SISTEM
                function readSystemFile(path) {
                    var xhr = new XMLHttpRequest();
                    xhr.open("GET", "file://" + path, false); // false = Synchronous (langsung dapat hasil)
                    try {
                        xhr.send(null);
                        if (xhr.status === 200 || xhr.status === 0) {
                            return xhr.responseText.trim();
                        }
                    } catch(e) {
                        return ""; // Kalau file gak ada, return kosong
                    }
                    return "";
                }

                // 3. MESIN PENCARI DATA (Jalan otomatis pas jendela Settings dibuka pertama kali)
                Component.onCompleted: {
                    // A. BACA HOSTNAME
                    var osRelease = readSystemFile("/etc/os-release");
                    if (osRelease !== "") {
                        var osLines = osRelease.split("\n");
                        var osId = ""; // Variabel sementara buat nampung ID distro

                        for (var i = 0; i < osLines.length; i++) {
                            if (osLines[i].startsWith("PRETTY_NAME=")) {
                                os = osLines[i].substring(12).replace(/"/g, "");
                            }
                            if (osLines[i].startsWith("ID=")) {
                                osId = osLines[i].substring(3).replace(/"/g, "").toLowerCase();
                            }
                        }

                        // ENGINE PEMILIH LOGO NERD FONT DINAMIS
                        if (osId === "arch") {
                            osIcon = "󰣇"; // Logo Arch Linux
                        } else if (osId === "cachyos") {
                            osIcon = "󰣇"; // Bisa tetep Arch krn satu rumpun, atau pake "󰓅" (Tachometer/Speed khas Cachy)
                        } else if (osId === "ubuntu") {
                            osIcon = "󰣴"; // Logo Ubuntu
                        } else if (osId === "fedora") {
                            osIcon = "󰣛"; // Logo Fedora
                        } else if (osId === "debian") {
                            osIcon = "󰣚"; // Logo Debian
                        } else if (osId === "linuxmint") {
                            osIcon = "󰣭"; // Logo Mint
                        } else {
                            osIcon = ""; // Fallback ke Penguin Tux jika misterius
                        }
                    }

                    var hwModel = readSystemFile("/sys/class/dmi/id/product_name");
                    if (hwModel !== "") model = hwModel;

                    // D. BACA PROCESSOR (Ambil baris pertama 'model name' di cpuinfo)
                    var cpuInfo = readSystemFile("/proc/cpuinfo");
                    if (cpuInfo !== "") {
                        var cpuLines = cpuInfo.split("\n");
                        for (var c = 0; c < cpuLines.length; c++) {
                            if (cpuLines[c].startsWith("model name")) {
                                // Potong teks setelah titik dua (:)
                                cpu = cpuLines[c].split(":")[1].trim(); 
                                break;
                            }
                        }
                    }

                    // E. BACA KAPASITAS RAM (Konversi dari kB ke GiB)
                    var memInfo = readSystemFile("/proc/meminfo");
                    if (memInfo !== "") {
                        var memLines = memInfo.split("\n");
                        for (var m = 0; m < memLines.length; m++) {
                            if (memLines[m].startsWith("MemTotal:")) {
                                // Ambil angkanya aja
                                var kb = parseInt(memLines[m].replace(/[^0-9]/g, ""));
                                var gib = (kb / 1048576).toFixed(1); // Rumus konversi kB ke GiB
                                ram = gib + " GiB";
                                break;
                            }
                        }
                    }

                    // F. BACA KAPASITAS DISK (Bisa deteksi NVMe atau SSD biasa)
                    var targetDrives = ["nvme0n1", "nvme1n1", "sda", "sdb", "sdc"];
                    var detectedDrives = [];
                    var totalBytes = 0;

                    for (var d = 0; d < targetDrives.length; d++) {
                        var driveName = targetDrives[d];
                        var sizeRaw = readSystemFile("/sys/class/block/" + driveName + "/size");
                        
                        if (sizeRaw !== "") {
                            var sectors = parseInt(sizeRaw);
                            if (!isNaN(sectors) && sectors > 0) {
                                // 1 sector di Linux = 512 bytes
                                var bytes = sectors * 512;
                                var gb = Math.round(bytes / 1000000000); 
                                
                                if (gb > 0) {
                                    totalBytes += bytes;
                                    var typeLabel = driveName.startsWith("nvme") ? "NVMe" : "mSATA/USB";
                                    // UDAH DI-FIX: Sekarang beneran nge-push ke detectedDrives!
                                    detectedDrives.push(typeLabel);
                                }
                            }
                        }
                    }

                    // Format Output ke UI Jendela Settings
                    var totalGB = Math.round(totalBytes / 1000000000);
                    if (detectedDrives.length > 1) {
                        // Kalau nyolok dua-duanya: "512 GB (NVMe) + 128 GB (mSATA/USB) [640 GB]"
                        disks = detectedDrives.join(" + ") + " (" + totalGB + " GB)";
                    } else if (detectedDrives.length === 1) {
                        // Kalau cuma murni internal doang
                        disks = detectedDrives[0];
                    } else {
                        disks = "Unknown Storage";
                    }
                }

                // G. Distro logo icon
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 20
                    clip: true
                    
                    ColumnLayout {
                        width: aboutPage.width - 40 // Kurangi margin biar gak mentok
                        spacing: 30

                        // ==========================================
                        // 1. HEADER (LOGO & NAMA OS)
                        // ==========================================
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 10
                            spacing: 15

                            // Lingkaran Logo
                            Rectangle {
                                Layout.preferredWidth: 110
                                Layout.preferredHeight: 110
                                radius: 55
                                color: "transparent" // Warna gelap sidebar
                                border.color: "#00f0ff" // Cyan khas ricing lu
                                border.width: 2
                                Layout.alignment: Qt.AlignHCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: aboutPage.osIcon !== "Unknown" ? aboutPage.osIcon : ""
                                    font.pixelSize: 55
                                    color: "#00f0ff"
                                }
                            }

                            // Nama Sistem
                            Text {
                                text: aboutPage.os !== "Unknown" ? aboutPage.os : "Unknown Operating System"
                                color: "white"
                                font.pixelSize: 26
                                font.bold: true
                                font.family: "Google Sans Flex"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        // ==========================================
                        // 2. BLOK HARDWARE INFO
                        // ==========================================
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: hardwareLayout.implicitHeight + 30
                            color: "#252424" // Warna card agak terang dari background utama
                            radius: 12
                            border.color: "#007a9f"
                            border.width: 1

                            ColumnLayout {
                                id: hardwareLayout
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                // Hardware Model
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: "Hardware Model"; color: "#a9b1d6"; font.pixelSize: 14; font.family: "Google Sans Flex" }
                                    Item { Layout.fillWidth: true } // Spacer ajaib pendodorong ke kanan
                                    Text { text: aboutPage.model !== "Unknown" ? aboutPage.model : "Unknown Hardware Model"; color: "white"; font.pixelSize: 14; font.bold: true; font.family: "Google Sans Flex" }
                                }
                                Rectangle { Layout.fillWidth: true; height: 1; color: "#382546" } // Garis pemisah

                                // Memory (RAM)
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: "Memory"; color: "#a9b1d6"; font.pixelSize: 14; font.family: "Google Sans Flex" }
                                    Item { Layout.fillWidth: true }
                                    Text { text: aboutPage.ram !== "Unknown" ? aboutPage.ram : "Unknown RAM Capacity"; color: "white"; font.pixelSize: 14; font.bold: true; font.family: "Google Sans Flex" }
                                }
                                Rectangle { Layout.fillWidth: true; height: 1; color: "#382546" }

                                // Processor
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: "Processor"; color: "#a9b1d6"; font.pixelSize: 14; font.family: "Google Sans Flex" }
                                    Item { Layout.fillWidth: true }
                                    Text { text: aboutPage.cpu !== "Unknown" ? aboutPage.cpu : "Unknown Processor"; color: "white"; font.pixelSize: 14; font.bold: true; font.family: "Google Sans Flex" }
                                }
                                Rectangle { Layout.fillWidth: true; height: 1; color: "#382546" }

                                // Disk Capacity
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: "Disk Capacity"; color: "#a9b1d6"; font.pixelSize: 14; font.family: "Google Sans Flex" }
                                    Item { Layout.fillWidth: true }
                                    Text { text: aboutPage.disks !== "Unknown" ? aboutPage.disks : "Unknown Disk Capacity"; color: "white"; font.pixelSize: 14; font.bold: true; font.family: "Google Sans Flex" }
                                }
                            }
                        }

                        // ==========================================
                        // 3. BLOK SOFTWARE INFO
                        // ==========================================
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: softwareLayout.implicitHeight + 30
                            color: "#252424"
                            radius: 12
                            border.color: "#007a9f"
                            border.width: 1

                            ColumnLayout {
                                id: softwareLayout
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15

                                // OS Type
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: "Distro"; color: "#a9b1d6"; font.pixelSize: 14; font.family: "Google Sans Flex" }
                                    Item { Layout.fillWidth: true }
                                    Text { text: aboutPage.os !== "Unknown" ? aboutPage.os : "Unknown Operating System"; color: "white"; font.pixelSize: 14; font.bold: true; font.family: "Google Sans Flex" }
                                }
                                Rectangle { Layout.fillWidth: true; height: 1; color: "#382546" }

                                // WM Type
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: "WM Type"; color: "#a9b1d6"; font.pixelSize: 14; font.family: "Google Sans Flex" }
                                    Item { Layout.fillWidth: true }
                                    Text { text: "Hyprland"; color: "white"; font.pixelSize: 14; font.bold: true; font.family: "Google Sans Flex" }
                                }
                                Rectangle { Layout.fillWidth: true; height: 1; color: "#382546" }

                                // Windowing System
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: "Windowing System"; color: "#a9b1d6"; font.pixelSize: 14; font.family: "Google Sans Flex" }
                                    Item { Layout.fillWidth: true }
                                    Text { text: aboutPage.windowing !== "Unknown" ? aboutPage.windowing : "Unknown Windowing System"; color: "white"; font.pixelSize: 14; font.bold: true; font.family: "Google Sans Flex" }
                                }
                                Rectangle { Layout.fillWidth: true; height: 1; color: "#382546" }

                                // Desktop / Shell
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: "Shell Environment"; color: "#a9b1d6"; font.pixelSize: 14; font.family: "Google Sans Flex" }
                                    Item { Layout.fillWidth: true }
                                    Text { text: aboutPage.shell !== "Unknown" ? aboutPage.shell : "Quickshell"; color: "white"; font.pixelSize: 14; font.bold: true; font.family: "Google Sans Flex" }
                                }

                                Rectangle { Layout.fillWidth: true; height: 1; color: "#382546" }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: "Hyprland Configuration"; color: "#a9b1d6"; font.pixelSize: 14; font.family: "Google Sans Flex" }
                                    Item { Layout.fillWidth: true }
                                    Text { text: "Sreetx Neo Dots"; color: "white"; font.pixelSize: 14; font.bold: true; font.family: "Anurati" }
                                }
                            }
                        }

                        Rectangle {
                            id: dotsLogolabel
                            Layout.preferredWidth: 110
                            Layout.preferredHeight: 110
                            anchors.horizontalCenter: parent.horizontalCenter
                            Layout.fillWidth: true
                            height: 1
                            color: "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "SREETX NEO DOTS"
                                font.pixelSize: 55
                                color: "#00f0ff"
                                font.family: "Anurati"
                            }
                        }

                        RowLayout {
                            id: supportSection
                            Layout.fillWidth: true
                            Layout.topMargin: 20
                            Layout.bottomMargin: 30
                            spacing: 40 // Jarak horizontal pemisah antara kolom YT dan GitHub
                            Layout.alignment: Qt.AlignHCenter

                            // ------------------------------------------
                            // KOLOM KIRI: YOUTUBE SECTION (KODE CUSTOM SANS)
                            // ------------------------------------------
                            ColumnLayout {
                                spacing: 20 // Jarak vertikal Teks -> Foto -> Tombol
                                Layout.alignment: Qt.AlignTop

                                // 1. JUDUL SUPPORT
                                Text {
                                    text: "Support Development"
                                    color: "white"
                                    font.pixelSize: 22
                                    font.family: "Anurati" // Font estetik andalan
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                // 2. FOTO PROFILE SANS
                                Image {
                                    id: thumbnailImage
                                    source: "https://yt3.googleusercontent.com/Wf1GRdH26-lh9Oh3yHDtWo1Yo8ZG0CiVHEn4fV7eiwArfH_CxGLIwgCxzh19sEXXHEa0tJF3-w=s160-c-k-c0x00ffffff-no-rj" 
                                    
                                    // Rasio 1:1 (130x130) pas banget buat foto profil
                                    Layout.preferredWidth: 130  
                                    Layout.preferredHeight: 130 
                                    Layout.alignment: Qt.AlignHCenter
                                    fillMode: Image.PreserveAspectCrop 
                                    
                                    // Bikin foto profilnya agak melengkung estetik
                                    layer.enabled: true
                                }

                                // 3. TOMBOL SUBSCRIBE YOUTUBE
                                Rectangle {
                                    id: subsButton
                                    Layout.preferredWidth: 200
                                    Layout.preferredHeight: 40
                                    Layout.alignment: Qt.AlignHCenter
                                    
                                    // Logika Perubahan Warna: 
                                    // Kalau ditekan jadi Cyan Gelap, kalau di-hover jadi Cyan Terang, default Cyan Solid
                                    color: ytMouse.pressed ? "#0099a3" : (ytMouse.containsMouse ? "#33f3ff" : "#00f0ff")
                                    
                                    radius: 8
                                    border.color: "#00767f"
                                    border.width: 1
                                    
                                    // Efek mengecil dikit pas ditekan (opsional biar makin mantap)
                                    scale: ytMouse.pressed ? 0.96 : 1.0

                                    // Animasi transisi warna & scale biar smooth
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on scale { NumberAnimation { duration: 100 } }

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        
                                        Text { text: "󰗃"; color: "#ff0055"; font.pixelSize: 18 } 
                                        Text {
                                            text: "Subscribe on YouTube"
                                            color: "#11111b" 
                                            font.pixelSize: 14
                                            font.bold: true
                                            font.family: "Google Sans Flex"
                                        }
                                    }

                                    MouseArea {
                                        id: ytMouse // ID ini wajib ada buat dibaca sama properti color di atas
                                        anchors.fill: parent
                                        hoverEnabled: true // Wajib dinyalain biar bisa deteksi kursor
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Qt.openUrlExternally("https://www.youtube.com/@linggachannel4781");
                                        }
                                    }
                                }
                            } // Akhir Kolom Kiri

                            // ------------------------------------------
                            // KOLOM KANAN: GITHUB SECTION (FITUR TAMBAHAN)
                            // ------------------------------------------
                            ColumnLayout {
                                spacing: 20
                                Layout.alignment: Qt.AlignTop

                                // 1. JUDUL GITHUB
                                Text {
                                    text: "Contribute & Source"
                                    color: "white"
                                    font.pixelSize: 22
                                    font.family: "Anurati"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                // 2. LOGO GITHUB (Ukuran disamakan 130x130 biar simetris)
                                Item {
                                    Layout.preferredWidth: 130
                                    Layout.preferredHeight: 130
                                    Layout.alignment: Qt.AlignHCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "" 
                                        font.pixelSize: 100 // Ukuran raksasa
                                        color: "#00f0ff"
                                        opacity: 0.8
                                    }
                                }

                                // 3. TOMBOL GITHUB REPO
                                Rectangle {
                                    id: githubButton
                                    Layout.preferredWidth: 200
                                    Layout.preferredHeight: 40
                                    Layout.alignment: Qt.AlignHCenter
                                    
                                    // Logika Perubahan Warna:
                                    // Karena awalnya transparan, pas ditekan kita kasih warna cyan gelap transparan
                                    color: ghMouse.pressed ? "#1a00f0ff" : (ghMouse.containsMouse ? "#0a00f0ff" : "transparent")
                                    
                                    radius: 8
                                    // Bordernya nyala terang pas ditekan
                                    border.color: ghMouse.pressed ? "#33f3ff" : "#00f0ff"
                                    border.width: 1
                                    
                                    scale: ghMouse.pressed ? 0.96 : 1.0

                                    // Animasi transisi warna & scale
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                    Behavior on scale { NumberAnimation { duration: 100 } }

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        
                                        Text { text: ""; color: "#00f0ff"; font.pixelSize: 18 } 
                                        Text {
                                            text: "GitHub Repository"
                                            color: "white"
                                            font.pixelSize: 14
                                            font.bold: true
                                            font.family: "Google Sans Flex"
                                        }
                                    }

                                    MouseArea {
                                        id: ghMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Qt.openUrlExternally("https://github.com/Sreetx"); 
                                        }
                                    }
                                }
                            } // Akhir Kolom Kanan
                        }
                    }
                }        
            }
        }
    }

    // Data Menu Sidebar
    ListModel {
        id: menuModel
        ListElement { ikon: "🛜"; name: "Wi-Fi" }
        ListElement { ikon: "📡"; name: "Hotspot" }
        ListElement { ikon: "🔌"; name: "Power" }
        ListElement { ikon: "🎨"; name: "Wallpapers" }
        ListElement { ikon: "🖱️"; name: "Cursors Themes" }
        ListElement { ikon: "🖱️"; name: "Cursor Settings" }
        ListElement { ikon: ""; name: "About" }
    }
}
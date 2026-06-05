import QtQuick
import QtQuick.Layouts
import Quickshell

// ShellWindow buat nge-handle surface di Hyprland
ShellWindow {
    id: superMenu
    
    // Set up tipe window untuk layer shell Hyprland
    anchors.top: true
    anchors.left: true
    anchors.bottom: true // Bikin full height di sebelah kiri, atau sesuaikan kebutuhan
    width: 380
    
    // Menggunakan protokol eksklusif Hyprland/Wayland via Quickshell
    exclusionMode: ShellWindow.ExclusionMode.None
    layerMode: ShellWindow.LayerMode.Top
    
    // Supaya otomatis nutup pas klik di luar menu (Focus out)
    onActiveChanged: {
        if (!active) superMenu.close()
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e" // Warna dasar gelap (misal: Catppuccin Mocha flavor)
        radius: 12
        border.color: "#cba6f7" // Border warna aksen
        border.width: 2

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // 1. HEADER: Profil / Jam / System Status singkat
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "SYSTEM MENU"
                    color: "#cba6f7"
                    font.bold: true
                    font.pointSize: 16
                }
                Spacer { Layout.fillWidth: true }
                // Tambahin indikator uptime atau jam di sini nanti
            }

            // 2. SEARCH BAR: Input utama buat nyari aplikasi / command
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                color: "#313244"
                radius: 8
                
                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.margins: 10
                    verticalAlignment: TextInput.AlignVCenter
                    color: "#cdd6f4"
                    font.pointSize: 12
                    focus: true
                    
                    placeholderText: "Search apps or execute commands..."
                    
                    // Nanti kita hubungin onTextChanged nya ke model filter aplikasi
                    onTextChanged: {
                        // Logika filter aplikasi kamu di sini
                    }
                }
            }

            // 3. MAIN CONTENT: List Aplikasi / Hasil Pencarian
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                // model: appModel -> Hubungkan dengan data desktop entries nanti
                
                delegate: Rectangle {
                    width: parent.width
                    height: 40
                    color: "transparent"
                    // Desain row item aplikasi di sini
                }
            }

            // 4. FOOTER: Quick Power Menu (Lock, Suspend, Reboot, Shutdown)
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                // Contoh button power menu yang langsung nembak command Hyprland/Systemd
                IconButton { 
                    icon: "🔒" 
                    onClicked: Quickshell.execute(["hyprlock"]) 
                }
                IconButton { 
                    icon: "🔄" 
                    onClicked: Quickshell.execute(["systemctl", "reboot"]) 
                }
                IconButton { 
                    icon: "🛑" 
                    onClicked: Quickshell.execute(["systemctl", "poweroff"]) 
                }
            }
        }
    }
}

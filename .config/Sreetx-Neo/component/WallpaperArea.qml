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

Scope {
    id: root
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bgWindow
            required property var modelData
            screen: modelData

            anchors { top: true; bottom: true; left: true; right: true }

            color: "black"
            aboveWindows: false
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background

            // ==================== CONFIG ====================
            readonly property string configDir: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/Sreetx-Neo/wallpapers"
            readonly property string jsonPath: configDir + "/wallpapers.json"
            readonly property string defaultWallpaper: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/Sreetx-Neo/wallpapers/sreetx-neo.jpeg"

            property var wpConfig: null

            // ==================== CURRENT WORKSPACE ====================
            readonly property string currentWsId: {
                if (typeof Hyprland !== "undefined" && Hyprland.monitors) {
                    var mon = Hyprland.monitors.find(m => m.name === bgWindow.screen.name);
                    if (mon && mon.activeWorkspace) return mon.activeWorkspace.id.toString();
                }
                return Hyprland.activeWorkspace ? Hyprland.activeWorkspace.id.toString() : "1";
            }

            // ==================== LOAD CONFIG (ANTI ERROR) ====================
            function loadConfig() {
                var xhr = new XMLHttpRequest();
                xhr.open("GET", jsonPath + "?t=" + Date.now(), true);
                
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200 || xhr.status === 0) {
                            try {
                                if (xhr.responseText.trim() === "") {
                                    console.warn("[Wallpaper] JSON file is empty", jsonPath);
                                    wpConfig = createDefaultConfig();
                                    return;
                                }
                                wpConfig = JSON.parse(xhr.responseText);
                                console.log("[Wallpaper] ✅ Config loaded successfully");
                            } catch (e) {
                                console.error("[Wallpaper] ❌ JSON Parse Error:", e);
                                wpConfig = createDefaultConfig();
                            }
                        } else {
                            console.warn("[Wallpaper] ⚠️ Config file not found, creating default...");
                            wpConfig = createDefaultConfig();
                        }
                    }
                };
                xhr.send();
            }

            // Buat config default kalau file rusak/kosong
            function createDefaultConfig() {
                return {
                    "current_desktop": "/home/programmer/Gambar/Wallpapers/Columbina.jpg",
                    "lockscreen": "",
                    "workspaces": {}
                };
            }

            Component.onCompleted: loadConfig()

            Timer {
                interval: 2500
                running: true
                repeat: true
                onTriggered: bgWindow.loadConfig()
            }

            // WALLPAPER SOURCE
            ClippingRectangle {
                anchors.fill: parent
                radius: 18

                Image {
                    id: wallpaperImage
                    fillMode: Image.PreserveAspectCrop
                    width: parent.width * 1.12
                    height: parent.height
                    smooth: true

                    property int wsIndex: 1

                    Connections {
                        target: Hyprland
                        function onActiveWorkspaceChanged() {
                            if (Hyprland.activeWorkspace) {
                                wallpaperImage.wsIndex = Hyprland.activeWorkspace.id;
                                // Sengaja dikasih console.log biar kamu bisa cek di terminal
                                // apakah Quickshell benar-benar nerima perubahan ID-nya
                                console.log("[Wallpaper] Berpindah ke Workspace:", wallpaperImage.wsIndex);
                            }
                        }
                    }
    
                    source: {
                        if (!bgWindow.wpConfig) return bgWindow.defaultWallpaper;

                        let cfg = bgWindow.wpConfig;

                        if (Hyprland.locked && cfg.lockscreen) return "file://" + cfg.lockscreen;
                        
                        if (cfg.workspaces && cfg.workspaces[wallpaperImage.wsIndex]) {
                            return "file://" + cfg.workspaces[wallpaperImage.wsIndex];
                        }
                        
                        if (cfg.current_desktop) return "file://" + cfg.current_desktop;

                        return bgWindow.defaultWallpaper;
                    }

                    Behavior on source {
                        SequentialAnimation {
                            NumberAnimation { target: wallpaperImage; property: "opacity"; to: 0; duration: 180; }
                            PropertyAction { target: wallpaperImage; property: "source"; }
                            NumberAnimation { target: wallpaperImage; property: "opacity"; to: 1; duration: 220 }
                        }
                    }
                }
            }
        }
    }
}
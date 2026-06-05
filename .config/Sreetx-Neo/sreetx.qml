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
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick.Layouts
import "./component"

ShellRoot {
    id: root
    objectName: "mainRoot"
    
    ListModel {
        id: databaseNotif
    }

// ** The Prototype **
// ** Status: Pasif ***

    QtObject {
        id: menuSuper
        property bool isOpen: false

        function toggle() {
            isOpen = !isOpen
            console.log("Menu Super State: " + isOpen)
        }
    }
    SuperMenu {
        id: superMenuWindow
        visible: menuSuper.isOpen 
    }

    GlobalShortcut {
        name: "openSuper"
        description: "Instant Shortcut for hide/unhide SuperMenu"
        onPressed: {
            menuSuper.toggle()
        }
    }
// **

    WorkspaceBar {
        id: barWindow
    }
    VerticalWorkspace {
        id: leftDockWindow
    }
    WallpaperArea {
        id: bgWindow
    }
    Notification {
        id: notifWindow
        modelDatabase: databaseNotif
    }
}


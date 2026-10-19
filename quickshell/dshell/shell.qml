//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma IconTheme Papirus-Dark

import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.ipc
import qs.modules.bar
import qs.modules.launcher
import qs.modules.notifications
import qs.modules.osd
import qs.modules.session
import qs.modules.lock
import qs.modules.sidebar
import qs.modules.dashboard
import qs.modules.overview
import qs.modules.settings
import qs.modules.cheatsheet
import qs.modules.wallpaper

ShellRoot {
    id: root

    // Services that must start with the shell (singletons load lazily otherwise)
    Component.onCompleted: {
        Config.ready;
        Colors.ready;
        Notifs.ready;
        Wallpapers.ready;
        Apps.ready;
    }

    Bar {}
    Launcher {}
    NotificationPopups {}
    NotificationHistory {}
    Osd {}
    SessionMenu {}
    LockScreen {}
    Sidebar {}
    Dashboard {}
    Overview {}
    SettingsPanel {}
    Cheatsheet {}
    WallpaperPicker {}
    Ipc {}
}

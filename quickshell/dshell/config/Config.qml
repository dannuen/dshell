pragma Singleton

import Quickshell
import Quickshell.Io

// All user settings. Defaults live here. User changes are stored in
// ~/.config/dshell/settings.json and are picked up live.
Singleton {
    id: root

    readonly property bool ready: true
    readonly property string home: Quickshell.env("HOME")
    readonly property string configDir: `${home}/.config/dshell`
    readonly property string stateDir: `${home}/.local/state/dshell`
    readonly property string settingsPath: `${configDir}/settings.json`

    property alias appearance: adapter.appearance
    property alias theme: adapter.theme
    property alias bar: adapter.bar
    property alias launcher: adapter.launcher
    property alias notifications: adapter.notifications
    property alias osd: adapter.osd
    property alias lock: adapter.lock
    property alias sidebar: adapter.sidebar
    property alias dashboard: adapter.dashboard
    property alias wallpaper: adapter.wallpaper
    property alias weather: adapter.weather
    property alias hooks: adapter.hooks

    function save(): void {
        file.writeAdapter();
    }

    FileView {
        id: file

        path: root.settingsPath
        watchChanges: true
        printErrors: false
        // finish writing settings.json before wallpaper.sh reads it
        blockWrites: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter

            property JsonObject appearance: JsonObject {
                property string font: "CaskaydiaCove Nerd Font"
                property string iconFont: "Material Symbols Rounded"
                property int fontSize: 12
                property int rounding: 16
                property int padding: 8
                property real animationSpeed: 1.0
                property real panelOpacity: 0.92
            }

            property JsonObject theme: JsonObject {
                // "dark" or "light"
                property string mode: "dark"
                // matugen scheme: scheme-tonal-spot, scheme-vibrant, scheme-expressive, scheme-content ...
                property string scheme: "scheme-tonal-spot"
            }

            property JsonObject bar: JsonObject {
                property int height: 36
                property int margin: 8
                property bool floating: true
                property bool showOnAllMonitors: true
                property bool showWindowTitle: true
                property bool showInputMethod: true
                property bool showBattery: true
                property bool showTray: true
                property int workspaceCount: 5
                property bool workspaceNumbers: true
                property string clockFormat: "HH:mm"
                property string dateFormat: "ddd d MMM"
            }

            property JsonObject launcher: JsonObject {
                property int maxResults: 8
                property int width: 640
                property bool sortByUsage: true
                property string calcPrefix: "="
                property string shellPrefix: ">"
                property string emojiPrefix: ":"
                property string windowPrefix: "@"
                property string clipPrefix: ";"
                property string wallPrefix: "/"
            }

            property JsonObject notifications: JsonObject {
                property int timeout: 6000
                property int criticalTimeout: 0
                property int maxPopups: 4
                property int historySize: 100
                property bool dnd: false
            }

            property JsonObject osd: JsonObject {
                property int timeout: 1500
                property bool volume: true
                property bool brightness: true
                property bool inputMethod: true
            }

            property JsonObject lock: JsonObject {
                property bool blur: true
                property string clockFormat: "HH:mm"
                property string dateFormat: "dddd, d MMMM"
            }

            property JsonObject sidebar: JsonObject {
                property int width: 420
                property int nightTemperature: 4000
            }

            property JsonObject dashboard: JsonObject {
                property int width: 720
                property bool showWeather: true
                property bool showMedia: true
                property bool showStats: true
                property bool showCalendar: true
            }

            property JsonObject wallpaper: JsonObject {
                property string dir: `${root.home}/Pictures/Wallpapers`
                property string current: ""
                property string transition: "fade"
            }

            property JsonObject weather: JsonObject {
                // empty = auto by IP
                property string location: ""
                property bool celsius: true
                property int refreshMinutes: 30
            }

            property JsonObject hooks: JsonObject {
                property string wallpaperChanged: ""
                property string locked: ""
                property string unlocked: ""
            }
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.services
import qs.components
import qs.utils

// The launcher panel body: search field plus results for the active mode.
PanelFrame {
    id: root

    readonly property int rowHeight: 52
    property int selected: 0
    property string calcResult: ""

    // Mode asked for from outside, or switched by a typed prefix
    readonly property string baseMode: Visibilities.launcherMode
    readonly property string query: field.text

    readonly property string mode: {
        if (baseMode !== "apps")
            return baseMode;
        const q = query;
        const L = Config.launcher;
        if (L.calcPrefix && q.startsWith(L.calcPrefix))
            return "calc";
        if (L.shellPrefix && q.startsWith(L.shellPrefix))
            return "shell";
        if (L.emojiPrefix && q.startsWith(L.emojiPrefix))
            return "emoji";
        if (L.windowPrefix && q.startsWith(L.windowPrefix))
            return "windows";
        if (L.clipPrefix && q.startsWith(L.clipPrefix))
            return "clipboard";
        if (L.wallPrefix && q.startsWith(L.wallPrefix))
            return "wallpaper";
        return "apps";
    }

    // Query without the prefix
    readonly property string term: {
        if (baseMode !== "apps" || mode === "apps")
            return query.trim();
        return query.slice(1).trim();
    }

    readonly property string placeholder: {
        switch (mode) {
        case "clipboard":
            return "Clipboard history";
        case "windows":
            return "Switch to window";
        case "emoji":
            return "Search emoji";
        case "calc":
            return "Calculate";
        case "shell":
            return "Run a command";
        case "wallpaper":
            return "Pick a wallpaper";
        default:
            return "Search apps,  = calc,  > run,  : emoji,  @ windows,  ; clipboard,  / wallpaper";
        }
    }

    readonly property string fieldIcon: {
        switch (mode) {
        case "clipboard":
            return "content_paste";
        case "windows":
            return "select_window";
        case "emoji":
            return "mood";
        case "calc":
            return "calculate";
        case "shell":
            return "terminal";
        case "wallpaper":
            return "wallpaper";
        default:
            return "search";
        }
    }

    // Each result: { title, subtitle, icon, symbol, emoji, run: function, alt: function }
    readonly property list<var> results: {
        const t = term;
        switch (mode) {
        case "apps":
            return Apps.search(t).map(e => ({
                        title: e.name,
                        subtitle: e.comment || e.genericName || "",
                        icon: e.icon,
                        symbol: "apps",
                        emoji: "",
                        run: () => Apps.launch(e)
                    }));
        case "clipboard": {
            const items = t === "" ? Clipboard.entries : Fuzzy.sort(t, Clipboard.entries, e => e.text);
            return items.map(e => ({
                        title: e.image ? "Image" : e.text,
                        subtitle: e.image ? e.text : "",
                        icon: "",
                        symbol: e.image ? "image" : "content_paste",
                        emoji: "",
                        run: () => Clipboard.copy(e.id),
                        alt: () => Clipboard.remove(e.id)
                    }));
        }
        case "windows": {
            const wins = Hypr.toplevels.values.filter(w => w.title && w.title !== "");
            const items = t === "" ? wins : Fuzzy.sort(t, wins, w => `${w.title} ${w.lastIpcObject?.class ?? ""}`);
            return items.map(w => {
                const cls = w.lastIpcObject?.class ?? "";
                const entry = cls ? Apps.byId(cls) : null;
                return {
                    title: w.title,
                    subtitle: `${cls}  ·  workspace ${w.workspace?.id ?? "?"}`,
                    icon: entry?.icon ?? cls,
                    symbol: "select_window",
                    emoji: "",
                    run: () => Hypr.focusWindow(w.address),
                    alt: () => Hypr.closeWindow(w.address)
                };
            });
        }
        case "emoji": {
            const items = t === "" ? Emojis.list : Fuzzy.sort(t, Emojis.list, e => e[1]);
            return items.map(e => ({
                        title: e[1],
                        subtitle: "",
                        icon: "",
                        symbol: "",
                        emoji: e[0],
                        run: () => Quickshell.execDetached(["wl-copy", e[0]])
                    }));
        }
        case "wallpaper": {
            const items = t === "" ? Wallpapers.list : Fuzzy.sort(t, Wallpapers.list, p => p.split("/").pop());
            return items.map(p => ({
                        title: p.split("/").pop(),
                        subtitle: p,
                        icon: "",
                        symbol: "wallpaper",
                        emoji: "",
                        run: () => Wallpapers.set(p)
                    }));
        }
        case "calc":
            return t === "" ? [] : [
                {
                    title: calcResult !== "" ? calcResult : "...",
                    subtitle: t,
                    icon: "",
                    symbol: "calculate",
                    emoji: "",
                    run: () => Quickshell.execDetached(["wl-copy", calcResult])
                }
            ];
        case "shell":
            return t === "" ? [] : [
                {
                    title: t,
                    subtitle: "Run in shell",
                    icon: "",
                    symbol: "terminal",
                    emoji: "",
                    run: () => Quickshell.execDetached(["sh", "-c", t])
                }
            ];
        }
        return [];
    }

    onResultsChanged: selected = 0
    onModeChanged: {
        if (mode === "clipboard")
            Clipboard.refresh();
        if (mode === "wallpaper")
            Wallpapers.refresh();
    }

    onTermChanged: {
        if (mode === "calc")
            calcTimer.restart();
    }

    function activate(index: int): void {
        const r = results[index];
        if (!r)
            return;
        Visibilities.launcher = false;
        r.run();
    }

    function alternate(index: int): void {
        const r = results[index];
        if (r && r.alt)
            r.alt();
    }

    function move(delta: int): void {
        if (results.length === 0)
            return;
        selected = (selected + delta + results.length) % results.length;
        list.positionViewAtIndex(selected, ListView.Contain);
    }

    Component.onCompleted: {
        if (mode === "clipboard")
            Clipboard.refresh();
        field.focusInput();
    }

    Timer {
        id: calcTimer
        interval: 150
        onTriggered: {
            calcProc.running = false;
            calcProc.command = ["qalc", "-t", root.term];
            calcProc.running = true;
        }
    }

    Process {
        id: calcProc
        stdout: StdioCollector {
            onStreamFinished: root.calcResult = text.trim()
        }
    }

    Column {
        width: Config.launcher.width
        spacing: Appearance.spacing.normal

        StyledTextField {
            id: field
            width: parent.width
            icon: root.fieldIcon
            placeholder: root.placeholder

            onAccepted: root.activate(root.selected)
            onEscapePressed: Visibilities.launcher = false
            onUpPressed: root.move(-1)
            onDownPressed: root.move(1)
            onTabPressed: root.move(1)
        }

        ListView {
            id: list
            width: parent.width
            height: Math.min(count, Config.launcher.maxResults) * (root.rowHeight + spacing)
            visible: count > 0
            clip: true
            spacing: Appearance.spacing.tiny
            model: root.results
            currentIndex: root.selected
            boundsBehavior: Flickable.StopAtBounds

            delegate: ResultItem {
                required property var modelData
                required property int index

                width: list.width
                title: modelData.title
                subtitle: modelData.subtitle
                icon: modelData.icon
                symbol: modelData.symbol
                emoji: modelData.emoji
                selected: index === root.selected

                onClicked: root.activate(index)
                onMiddleClicked: root.alternate(index)
            }
        }

        StyledText {
            visible: root.results.length === 0 && root.term !== ""
            width: parent.width
            text: "No results"
            color: Colors.onSurfaceVariant
            horizontalAlignment: Text.AlignHCenter
            height: 40
        }
    }
}

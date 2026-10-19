pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config
import qs.utils

// Desktop apps, sorted by how often they were launched from the launcher.
Singleton {
    id: root

    readonly property bool ready: true
    property var usage: ({})

    readonly property list<DesktopEntry> all: DesktopEntries.applications.values

    readonly property list<DesktopEntry> list: {
        const arr = all.slice();
        if (Config.launcher.sortByUsage)
            arr.sort((a, b) => (usage[b.id] ?? 0) - (usage[a.id] ?? 0) || a.name.localeCompare(b.name));
        else
            arr.sort((a, b) => a.name.localeCompare(b.name));
        return arr;
    }

    function search(query: string): list<DesktopEntry> {
        if (!query || query.trim() === "")
            return list;
        return Fuzzy.sort(query, list, e => [e.name, e.genericName, e.comment, ...(e.keywords ?? [])].join(" "));
    }

    function launch(entry: DesktopEntry): void {
        if (!entry)
            return;
        usage[entry.id] = (usage[entry.id] ?? 0) + 1;
        usage = Object.assign({}, usage);
        usageFile.setText(JSON.stringify(usage));
        entry.execute();
    }

    function byId(id: string): DesktopEntry {
        return DesktopEntries.byId(id) ?? DesktopEntries.heuristicLookup(id);
    }

    FileView {
        id: usageFile
        path: `${Config.stateDir}/app-usage.json`
        printErrors: false
        blockLoading: true
        Component.onCompleted: {
            try {
                root.usage = JSON.parse(text());
            } catch (e) {
                root.usage = {};
            }
        }
    }
}

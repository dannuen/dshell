pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// cliphist wrapper. Entries are {id, text, image}.
Singleton {
    id: root

    property list<var> entries: []

    function refresh(): void {
        listProc.running = true;
    }

    function copy(id: string): void {
        Quickshell.execDetached(["sh", "-c", `cliphist decode ${id} | wl-copy`]);
    }

    function remove(id: string): void {
        Quickshell.execDetached(["sh", "-c", `printf '%s\\t' ${id} | cliphist delete`]);
        entries = entries.filter(e => e.id !== id);
    }

    function clear(): void {
        Quickshell.execDetached(["cliphist", "wipe"]);
        entries = [];
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.split("\n")) {
                    if (!line)
                        continue;
                    const tab = line.indexOf("\t");
                    if (tab < 0)
                        continue;
                    const id = line.slice(0, tab);
                    const body = line.slice(tab + 1);
                    out.push({
                        id,
                        text: body,
                        image: /^\[\[ binary data .* (png|jpg|jpeg|gif|webp|bmp) /.test(body)
                    });
                }
                root.entries = out;
            }
        }
    }
}

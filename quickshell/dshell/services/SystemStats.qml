pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// CPU, memory, GPU, disk and temperature. Polled every 2 seconds when
// something is watching (set `active` from the dashboard).
Singleton {
    id: root

    property bool active: false
    readonly property int interval: 2000

    property real cpu: 0          // 0..1
    property real cpuTemp: 0      // celsius
    property real mem: 0          // 0..1
    property real memUsedGb: 0
    property real memTotalGb: 0
    property real gpu: 0          // 0..1, 0 if unknown
    property string gpuName: ""
    property real disk: 0         // 0..1 for /
    property string diskText: ""
    property real netDown: 0      // bytes/s
    property real netUp: 0

    property var _lastCpu: null
    property var _lastNet: null
    property double _lastNetTime: 0

    function fmtBytes(b: real): string {
        if (b > 1048576)
            return `${(b / 1048576).toFixed(1)} MB/s`;
        if (b > 1024)
            return `${(b / 1024).toFixed(0)} KB/s`;
        return `${b.toFixed(0)} B/s`;
    }

    Timer {
        interval: root.interval
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload();
            memFile.reload();
            netFile.reload();
            gpuProc.running = true;
            miscProc.running = true;
        }
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        printErrors: false
        onLoaded: {
            const line = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = line[3] + line[4];
            const total = line.reduce((a, b) => a + b, 0);
            if (root._lastCpu) {
                const dt = total - root._lastCpu.total;
                const di = idle - root._lastCpu.idle;
                root.cpu = dt > 0 ? Math.max(0, Math.min(1, 1 - di / dt)) : 0;
            }
            root._lastCpu = {
                total,
                idle
            };
        }
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        printErrors: false
        onLoaded: {
            const t = text();
            const grab = key => parseInt((t.match(new RegExp(`${key}:\\s+(\\d+)`)) ?? [0, 0])[1]);
            const total = grab("MemTotal");
            const avail = grab("MemAvailable");
            root.memTotalGb = total / 1048576;
            root.memUsedGb = (total - avail) / 1048576;
            root.mem = total > 0 ? (total - avail) / total : 0;
        }
    }

    FileView {
        id: netFile
        path: "/proc/net/dev"
        printErrors: false
        onLoaded: {
            let rx = 0, tx = 0;
            for (const line of text().split("\n").slice(2)) {
                const p = line.trim().split(/\s+/);
                if (p.length < 10 || p[0].startsWith("lo"))
                    continue;
                rx += parseInt(p[1]) || 0;
                tx += parseInt(p[9]) || 0;
            }
            const now = Date.now();
            if (root._lastNet && now > root._lastNetTime) {
                const dt = (now - root._lastNetTime) / 1000;
                root.netDown = Math.max(0, (rx - root._lastNet.rx) / dt);
                root.netUp = Math.max(0, (tx - root._lastNet.tx) / dt);
            }
            root._lastNet = {
                rx,
                tx
            };
            root._lastNetTime = now;
        }
    }

    // GPU busy percent: NVIDIA through nvidia-smi, AMD and Intel through sysfs
    Process {
        id: gpuProc
        command: ["sh", "-c", "if command -v nvidia-smi >/dev/null 2>&1; then nvidia-smi --query-gpu=utilization.gpu,name --format=csv,noheader,nounits 2>/dev/null | head -n1; else for f in /sys/class/drm/card*/device/gpu_busy_percent; do [ -r \"$f\" ] && { printf '%s, %s\\n' \"$(cat \"$f\")\" \"$(cat \"$(dirname \"$f\")/../../device/label\" 2>/dev/null || echo GPU)\"; break; }; done; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split(",");
                if (p.length >= 1 && p[0].trim() !== "") {
                    root.gpu = (parseFloat(p[0]) || 0) / 100;
                    root.gpuName = (p[1] ?? "GPU").trim();
                }
            }
        }
    }

    // Disk usage for / and CPU package temperature
    Process {
        id: miscProc
        command: ["sh", "-c", "df -P / | awk 'NR==2{print $3, $2, $5}'; t=''; for z in /sys/class/thermal/thermal_zone*; do ty=$(cat \"$z/type\" 2>/dev/null); case \"$ty\" in x86_pkg_temp|k10temp|acpitz|cpu-thermal|coretemp*) t=$(cat \"$z/temp\" 2>/dev/null); break;; esac; done; [ -z \"$t\" ] && t=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null); echo \"${t:-0}\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const d = (lines[0] ?? "").split(/\s+/);
                if (d.length >= 3) {
                    root.disk = parseInt(d[2]) / 100;
                    root.diskText = `${(parseInt(d[0]) / 1048576).toFixed(0)} / ${(parseInt(d[1]) / 1048576).toFixed(0)} GB`;
                }
                const t = parseInt(lines[1] ?? "0") || 0;
                root.cpuTemp = t > 1000 ? t / 1000 : t;
            }
        }
    }
}

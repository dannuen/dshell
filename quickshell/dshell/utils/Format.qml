pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    function percent(v: real): string {
        return `${Math.round(v * 100)}%`;
    }

    function duration(secs: real): string {
        secs = Math.max(0, Math.floor(secs));
        const h = Math.floor(secs / 3600);
        const m = Math.floor((secs % 3600) / 60);
        const s = secs % 60;
        const pad = n => (n < 10 ? "0" : "") + n;
        return h > 0 ? `${h}:${pad(m)}:${pad(s)}` : `${m}:${pad(s)}`;
    }

    function capitalize(s: string): string {
        return s ? s[0].toUpperCase() + s.slice(1) : s;
    }

    // Strip pango/html tags from notification bodies for one line previews
    function plain(s: string): string {
        return (s ?? "").replace(/<[^>]*>/g, "").replace(/\s+/g, " ").trim();
    }
}

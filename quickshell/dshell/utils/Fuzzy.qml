pragma Singleton

import Quickshell
import QtQuick

// Small fuzzy matcher. Score is higher for prefix and consecutive matches.
Singleton {
    id: root

    function score(query: string, text: string): real {
        if (!text)
            return 0;
        const q = query.toLowerCase();
        const t = text.toLowerCase();
        if (q.length === 0)
            return 1;
        const idx = t.indexOf(q);
        if (idx === 0)
            return 1000 - t.length;
        if (idx > 0)
            return 500 - idx - (t.length - q.length) * 0.1;
        // subsequence match
        let ti = 0, s = 0, streak = 0;
        for (let qi = 0; qi < q.length; qi++) {
            const pos = t.indexOf(q[qi], ti);
            if (pos < 0)
                return 0;
            streak = pos === ti ? streak + 1 : 0;
            s += 10 + streak * 5 - (pos - ti);
            ti = pos + 1;
        }
        return Math.max(1, s);
    }

    // items: list, keyFn: item => string
    function sort(query: string, items: var, keyFn: var): var {
        const scored = [];
        for (const it of items) {
            const s = score(query, keyFn(it));
            if (s > 0)
                scored.push({
                    it,
                    s
                });
        }
        scored.sort((a, b) => b.s - a.s);
        return scored.map(x => x.it);
    }
}

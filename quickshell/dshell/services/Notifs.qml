pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import qs.config

// Notification daemon. Popups time out, history is kept in memory and in
// ~/.local/state/dshell/notifications.json so it survives a shell restart.
Singleton {
    id: root

    readonly property bool ready: true
    readonly property bool dnd: Config.notifications.dnd

    // Newest first
    property list<var> list: []
    readonly property list<var> popups: list.filter(n => n.popup)
    readonly property int unread: list.filter(n => !n.read).length

    component Notif: QtObject {
        required property int id
        property string appName
        property string appIcon
        property string summary
        property string body
        property string image
        property int urgency: NotificationUrgency.Normal
        property double time: Date.now()
        property bool popup: true
        property bool read: false
        property var actions: []
        property Notification notification: null
        property Timer timer: null

        function dismiss(): void {
            root.dismiss(id);
        }

        function invoke(identifier: string): void {
            if (!notification)
                return;
            const a = notification.actions.find(x => x.identifier === identifier);
            if (a)
                a.invoke();
            root.dismiss(id);
        }
    }

    function dismiss(id: int): void {
        const n = list.find(x => x.id === id);
        if (!n)
            return;
        if (n.notification)
            n.notification.dismiss();
        list = list.filter(x => x.id !== id);
        save();
        free(n);
    }

    // Notif objects come from createObject, so drop them by hand
    function free(n: var): void {
        n.timer?.destroy();
        n.destroy();
    }

    function hidePopup(id: int): void {
        const n = list.find(x => x.id === id);
        if (n)
            n.popup = false;
        // force dependents to refresh
        list = list.slice();
    }

    function hideAllPopups(): void {
        for (const n of list)
            n.popup = false;
        list = list.slice();
    }

    function clear(): void {
        for (const n of list)
            if (n.notification)
                n.notification.dismiss();
        const old = list;
        list = [];
        save();
        for (const n of old)
            free(n);
    }

    function markRead(): void {
        for (const n of list)
            n.read = true;
        list = list.slice();
    }

    function toggleDnd(): void {
        Config.notifications.dnd = !dnd;
        Config.save();
    }

    function save(): void {
        const out = list.slice(0, Config.notifications.historySize).map(n => ({
                    id: n.id,
                    appName: n.appName,
                    appIcon: n.appIcon,
                    summary: n.summary,
                    body: n.body,
                    image: n.image,
                    urgency: n.urgency,
                    time: n.time,
                    read: n.read
                }));
        historyFile.setText(JSON.stringify(out));
    }

    function load(): void {
        try {
            const data = JSON.parse(historyFile.text());
            const restored = [];
            for (const d of data) {
                const n = notifComp.createObject(root, {
                    // restored ids must never clash with new ones (the server restarts at 1)
                    id: -1 - restored.length,
                    appName: d.appName ?? "",
                    appIcon: d.appIcon ?? "",
                    summary: d.summary ?? "",
                    body: d.body ?? "",
                    image: d.image ?? "",
                    urgency: d.urgency ?? NotificationUrgency.Normal,
                    time: d.time ?? Date.now(),
                    popup: false,
                    read: d.read ?? true
                });
                restored.push(n);
            }
            list = restored;
        } catch (e) {
        }
    }

    Component {
        id: notifComp
        Notif {}
    }

    Component {
        id: timerComp
        Timer {
            property int notifId
            repeat: false
            onTriggered: root.hidePopup(notifId)
        }
    }

    FileView {
        id: historyFile
        path: `${Config.stateDir}/notifications.json`
        printErrors: false
        blockLoading: true
        Component.onCompleted: root.load()
    }

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;

            // Replace an existing one with the same id (progress updates)
            const dropped = root.list.filter(x => x.id === notification.id);
            root.list = root.list.filter(x => x.id !== notification.id);

            const timeout = notification.urgency === NotificationUrgency.Critical ? Config.notifications.criticalTimeout : (notification.expireTimeout > 0 ? notification.expireTimeout : Config.notifications.timeout);

            const n = notifComp.createObject(root, {
                id: notification.id,
                appName: notification.appName,
                appIcon: notification.appIcon,
                summary: notification.summary,
                body: notification.body,
                image: notification.image,
                urgency: notification.urgency,
                time: Date.now(),
                popup: !root.dnd || notification.urgency === NotificationUrgency.Critical,
                read: false,
                actions: notification.actions.map(a => ({
                            identifier: a.identifier,
                            text: a.text
                        })),
                notification: notification
            });

            if (timeout > 0 && n.popup) {
                n.timer = timerComp.createObject(n, {
                    notifId: n.id,
                    interval: timeout
                });
                n.timer.start();
            }

            // Closed by the sending app: keep it in history, hide the popup
            notification.closed.connect(() => {
                n.notification = null;
                n.popup = false;
                root.list = root.list.slice();
            });

            const all = [n, ...root.list];
            root.list = all.slice(0, Config.notifications.historySize);
            root.save();
            for (const x of dropped.concat(all.slice(Config.notifications.historySize)))
                root.free(x);
        }
    }
}

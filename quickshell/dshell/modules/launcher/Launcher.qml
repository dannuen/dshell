import QtQuick
import qs.config
import qs.services
import qs.components

// App launcher, also clipboard, window switcher, emoji picker and more
// through typed prefixes. Super+Space.
PopupPanel {
    name: "launcher"
    position: "top"

    content: Component {
        LauncherContent {}
    }
}

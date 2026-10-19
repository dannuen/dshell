pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

// Material You colors. matugen writes ~/.local/state/dshell/colors.json from
// templates/colors.json. Until that exists these dark defaults are used.
Singleton {
    id: root

    readonly property bool ready: true
    readonly property bool light: Config.theme.mode === "light"

    // fgX is the text and icon color on top of X (Material's "on X").
    // Not named onX: next to a property X, QML reads onX as X's change
    // handler and the color comes out black.

    readonly property color background: adapter.background
    readonly property color fgBackground: adapter.on_background
    readonly property color surface: adapter.surface
    readonly property color surfaceDim: adapter.surface_dim
    readonly property color surfaceBright: adapter.surface_bright
    readonly property color surfaceContainerLowest: adapter.surface_container_lowest
    readonly property color surfaceContainerLow: adapter.surface_container_low
    readonly property color surfaceContainer: adapter.surface_container
    readonly property color surfaceContainerHigh: adapter.surface_container_high
    readonly property color surfaceContainerHighest: adapter.surface_container_highest
    readonly property color fgSurface: adapter.on_surface
    readonly property color fgSurfaceVariant: adapter.on_surface_variant
    readonly property color surfaceVariant: adapter.surface_variant
    readonly property color primary: adapter.primary
    readonly property color fgPrimary: adapter.on_primary
    readonly property color primaryContainer: adapter.primary_container
    readonly property color fgPrimaryContainer: adapter.on_primary_container
    readonly property color secondary: adapter.secondary
    readonly property color fgSecondary: adapter.on_secondary
    readonly property color secondaryContainer: adapter.secondary_container
    readonly property color fgSecondaryContainer: adapter.on_secondary_container
    readonly property color tertiary: adapter.tertiary
    readonly property color fgTertiary: adapter.on_tertiary
    readonly property color tertiaryContainer: adapter.tertiary_container
    readonly property color fgTertiaryContainer: adapter.on_tertiary_container
    readonly property color error: adapter.error
    readonly property color fgError: adapter.on_error
    readonly property color errorContainer: adapter.error_container
    readonly property color fgErrorContainer: adapter.on_error_container
    readonly property color outline: adapter.outline
    readonly property color outlineVariant: adapter.outline_variant
    readonly property color shadow: adapter.shadow
    readonly property color inverseSurface: adapter.inverse_surface
    readonly property color inverseOnSurface: adapter.inverse_on_surface
    readonly property color inversePrimary: adapter.inverse_primary

    // Panel background with the configured opacity
    readonly property color panel: Qt.alpha(surface, Config.appearance.panelOpacity)
    readonly property color panelHigh: Qt.alpha(surfaceContainer, Config.appearance.panelOpacity)

    function alpha(c: color, a: real): color {
        return Qt.alpha(c, a);
    }

    // Layer a color over another, used for hover and press states
    function layer(base: color, over: color, amount: real): color {
        return Qt.tint(base, Qt.alpha(over, amount));
    }

    FileView {
        id: file

        path: `${Config.stateDir}/colors.json`
        watchChanges: true
        printErrors: false
        onFileChanged: reload()

        JsonAdapter {
            id: adapter

            property string background: "#131318"
            property string on_background: "#e4e1e9"
            property string surface: "#131318"
            property string surface_dim: "#131318"
            property string surface_bright: "#39383f"
            property string surface_container_lowest: "#0e0e13"
            property string surface_container_low: "#1b1b21"
            property string surface_container: "#1f1f25"
            property string surface_container_high: "#2a292f"
            property string surface_container_highest: "#35343a"
            property string on_surface: "#e4e1e9"
            property string on_surface_variant: "#c8c5d0"
            property string surface_variant: "#47464f"
            property string primary: "#c0c1ff"
            property string on_primary: "#262c9c"
            property string primary_container: "#3e46b2"
            property string on_primary_container: "#e0e0ff"
            property string secondary: "#c5c4dd"
            property string on_secondary: "#2e2f42"
            property string secondary_container: "#444559"
            property string on_secondary_container: "#e1e0f9"
            property string tertiary: "#e8b9d5"
            property string on_tertiary: "#46263b"
            property string tertiary_container: "#5f3c52"
            property string on_tertiary_container: "#ffd8ec"
            property string error: "#ffb4ab"
            property string on_error: "#690005"
            property string error_container: "#93000a"
            property string on_error_container: "#ffdad6"
            property string outline: "#918f9a"
            property string outline_variant: "#47464f"
            property string shadow: "#000000"
            property string inverse_surface: "#e4e1e9"
            property string inverse_on_surface: "#303036"
            property string inverse_primary: "#555dcb"
        }
    }
}

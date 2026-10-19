pragma ComponentBehavior: Bound

import QtQuick
import qs.config
import qs.services
import qs.components

// CPU, RAM, GPU, disk gauges plus network speed.
StyledRect {
    id: root

    implicitHeight: content.implicitHeight + Appearance.spacing.normal * 2
    color: Colors.surfaceContainer

    component Gauge: Item {
        id: gauge
        property string label: ""
        property string icon: ""
        property real value: 0
        property string sub: ""

        width: 76
        height: 100

        Canvas {
            id: canvas
            anchors.horizontalCenter: parent.horizontalCenter
            width: 60
            height: 60
            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const c = width / 2;
                const r = c - 4;
                ctx.lineWidth = 6;
                ctx.lineCap = "round";
                ctx.strokeStyle = Colors.surfaceContainerHighest;
                ctx.beginPath();
                ctx.arc(c, c, r, 0, Math.PI * 2);
                ctx.stroke();
                ctx.strokeStyle = gauge.value > 0.85 ? Colors.error : Colors.primary;
                ctx.beginPath();
                ctx.arc(c, c, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * Math.max(0, Math.min(1, gauge.value)));
                ctx.stroke();
            }

            Connections {
                target: gauge
                function onValueChanged(): void {
                    canvas.requestPaint();
                }
            }
            Connections {
                target: Colors
                function onPrimaryChanged(): void {
                    canvas.requestPaint();
                }
            }

            StyledText {
                anchors.centerIn: parent
                text: `${Math.round(gauge.value * 100)}%`
                font.pointSize: Appearance.fontSize.small
                font.weight: Font.DemiBold
            }
        }

        StyledText {
            anchors.top: canvas.bottom
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            text: gauge.label
            font.pointSize: Appearance.fontSize.small
        }

        StyledText {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: gauge.sub
            color: Colors.fgSurfaceVariant
            font.pointSize: Appearance.fontSize.small - 1
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: Appearance.spacing.normal
        spacing: Appearance.spacing.small

        Row {
            width: parent.width
            spacing: Appearance.spacing.small

            Gauge {
                label: "CPU"
                value: SystemStats.cpu
                sub: SystemStats.cpuTemp > 0 ? `${Math.round(SystemStats.cpuTemp)}°C` : ""
            }

            Gauge {
                label: "RAM"
                value: SystemStats.mem
                sub: `${SystemStats.memUsedGb.toFixed(1)} / ${SystemStats.memTotalGb.toFixed(0)} GB`
            }

            Gauge {
                visible: SystemStats.gpuName !== ""
                label: "GPU"
                value: SystemStats.gpu
                sub: SystemStats.gpuName.length > 14 ? SystemStats.gpuName.slice(0, 14) : SystemStats.gpuName
            }

            Gauge {
                label: "Disk"
                value: SystemStats.disk
                sub: SystemStats.diskText
            }
        }

        Row {
            spacing: Appearance.spacing.large

            Row {
                spacing: 4
                MaterialIcon {
                    text: "download"
                    color: Colors.fgSurfaceVariant
                    font.pointSize: Appearance.fontSize.normal
                }
                StyledText {
                    text: SystemStats.fmtBytes(SystemStats.netDown)
                    font.pointSize: Appearance.fontSize.small
                }
            }

            Row {
                spacing: 4
                MaterialIcon {
                    text: "upload"
                    color: Colors.fgSurfaceVariant
                    font.pointSize: Appearance.fontSize.normal
                }
                StyledText {
                    text: SystemStats.fmtBytes(SystemStats.netUp)
                    font.pointSize: Appearance.fontSize.small
                }
            }
        }
    }
}

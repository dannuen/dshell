pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.config

// Weather from wttr.in. Refreshes on an interval, result cached in memory.
Singleton {
    id: root

    property bool loaded: false
    property string temp: ""
    property string feelsLike: ""
    property string description: ""
    property string icon: "cloud"
    property string city: ""
    property string humidity: ""
    property string wind: ""
    property list<var> forecast: []

    function refresh(): void {
        proc.running = true;
    }

    function iconFor(code: int): string {
        // WWO weather codes
        if (code === 113)
            return "sunny";
        if (code === 116)
            return "partly_cloudy_day";
        if (code === 119 || code === 122)
            return "cloud";
        if (code === 143 || code === 248 || code === 260)
            return "foggy";
        if ([176, 263, 266, 293, 296, 353].includes(code))
            return "rainy_light";
        if ([299, 302, 305, 308, 356, 359].includes(code))
            return "rainy";
        if ([179, 182, 185, 281, 284, 311, 314, 317, 350, 362, 365, 374, 377].includes(code))
            return "weather_mix";
        if ([227, 230, 320, 323, 326, 329, 332, 335, 338, 368, 371, 395].includes(code))
            return "weather_snowy";
        if ([200, 386, 389, 392].includes(code))
            return "thunderstorm";
        return "cloud";
    }

    Process {
        id: proc
        command: ["curl", "-sf", "--max-time", "15", `https://wttr.in/${encodeURIComponent(Config.weather.location)}?format=j1`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text);
                    const c = j.current_condition[0];
                    const metric = Config.weather.celsius;
                    root.temp = metric ? `${c.temp_C}°` : `${c.temp_F}°`;
                    root.feelsLike = metric ? `${c.FeelsLikeC}°` : `${c.FeelsLikeF}°`;
                    root.description = c.weatherDesc[0].value;
                    root.icon = root.iconFor(parseInt(c.weatherCode));
                    root.humidity = `${c.humidity}%`;
                    root.wind = metric ? `${c.windspeedKmph} km/h` : `${c.windspeedMiles} mph`;
                    root.city = j.nearest_area[0].areaName[0].value;
                    root.forecast = j.weather.slice(0, 3).map(d => ({
                                date: d.date,
                                max: metric ? `${d.maxtempC}°` : `${d.maxtempF}°`,
                                min: metric ? `${d.mintempC}°` : `${d.mintempF}°`,
                                icon: root.iconFor(parseInt(d.hourly[4].weatherCode))
                            }));
                    root.loaded = true;
                } catch (e) {
                    root.loaded = false;
                }
            }
        }
    }

    Timer {
        interval: Math.max(5, Config.weather.refreshMinutes) * 60000
        running: Config.dashboard.showWeather
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}

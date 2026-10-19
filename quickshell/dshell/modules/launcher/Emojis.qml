pragma Singleton

import QtQuick

// Small built in emoji list for the launcher. Each entry: [emoji, name].
QtObject {
    readonly property list<var> list: [
        ["😀", "grinning face"], ["😃", "smiley"], ["😄", "smile"], ["😁", "grin"], ["😆", "laughing"],
        ["😅", "sweat smile"], ["🤣", "rofl"], ["😂", "joy tears"], ["🙂", "slightly smiling"], ["😉", "wink"],
        ["😊", "blush"], ["😇", "innocent halo"], ["🥰", "smiling hearts love"], ["😍", "heart eyes"], ["🤩", "star struck"],
        ["😘", "kissing heart"], ["😋", "yum"], ["😛", "tongue"], ["😜", "wink tongue"], ["🤪", "zany"],
        ["🤔", "thinking"], ["🤫", "shushing"], ["🤭", "hand over mouth"], ["😐", "neutral"], ["😑", "expressionless"],
        ["😶", "no mouth"], ["😏", "smirk"], ["😒", "unamused"], ["🙄", "eye roll"], ["😬", "grimace"],
        ["😴", "sleeping"], ["😷", "mask"], ["🤒", "thermometer sick"], ["🤕", "head bandage"], ["🤢", "nauseated"],
        ["🤮", "vomiting"], ["🥵", "hot face"], ["🥶", "cold face"], ["😵", "dizzy"], ["🤯", "exploding head mind blown"],
        ["🥳", "party face"], ["😎", "sunglasses cool"], ["🤓", "nerd"], ["🧐", "monocle"], ["😕", "confused"],
        ["😟", "worried"], ["🙁", "frown"], ["😮", "open mouth"], ["😲", "astonished"], ["😳", "flushed"],
        ["🥺", "pleading"], ["😢", "cry"], ["😭", "sob loudly crying"], ["😱", "scream"], ["😤", "triumph huff"],
        ["😡", "angry rage"], ["🤬", "cursing"], ["💀", "skull"], ["💩", "poop"], ["🤡", "clown"],
        ["👻", "ghost"], ["👽", "alien"], ["🤖", "robot"], ["😺", "cat smile"], ["🙈", "see no evil monkey"],
        ["🙉", "hear no evil monkey"], ["🙊", "speak no evil monkey"], ["❤️", "red heart love"], ["🧡", "orange heart"], ["💛", "yellow heart"],
        ["💚", "green heart"], ["💙", "blue heart"], ["💜", "purple heart"], ["🖤", "black heart"], ["🤍", "white heart"],
        ["💔", "broken heart"], ["💕", "two hearts"], ["💖", "sparkling heart"], ["💯", "hundred points"], ["💢", "anger"],
        ["💥", "collision boom"], ["💫", "dizzy star"], ["💦", "sweat droplets"], ["💨", "dash"], ["🔥", "fire lit"],
        ["✨", "sparkles"], ["⭐", "star"], ["🌟", "glowing star"], ["⚡", "zap lightning"], ["☀️", "sun"],
        ["🌙", "crescent moon"], ["🌈", "rainbow"], ["☁️", "cloud"], ["🌧️", "rain cloud"], ["❄️", "snowflake"],
        ["👋", "wave hello"], ["🤚", "raised back of hand"], ["✋", "raised hand"], ["👌", "ok hand"], ["✌️", "victory peace"],
        ["🤞", "crossed fingers"], ["🤟", "love you gesture"], ["🤘", "rock on horns"], ["🤙", "call me"], ["👈", "point left"],
        ["👉", "point right"], ["👆", "point up"], ["👇", "point down"], ["👍", "thumbs up"], ["👎", "thumbs down"],
        ["✊", "fist"], ["👊", "punch"], ["👏", "clap"], ["🙌", "raised hands praise"], ["🙏", "pray thanks please"],
        ["💪", "flex muscle strong"], ["🧠", "brain"], ["👀", "eyes look"], ["👁️", "eye"], ["🫡", "salute"],
        ["🎉", "party popper tada"], ["🎊", "confetti"], ["🎁", "gift present"], ["🎂", "birthday cake"], ["🏆", "trophy"],
        ["🥇", "gold medal"], ["🎯", "bullseye target"], ["🎮", "video game controller"], ["🎵", "music note"], ["🎶", "music notes"],
        ["🎧", "headphones"], ["🎤", "microphone"], ["📱", "phone"], ["💻", "laptop"], ["🖥️", "desktop computer"],
        ["⌨️", "keyboard"], ["🖱️", "mouse"], ["💾", "floppy save"], ["📷", "camera"], ["🔋", "battery"],
        ["🔌", "plug"], ["💡", "light bulb idea"], ["🔧", "wrench"], ["🔨", "hammer"], ["⚙️", "gear settings"],
        ["🔒", "lock"], ["🔓", "unlock"], ["🔑", "key"], ["📌", "pushpin"], ["📎", "paperclip"],
        ["✅", "check mark done"], ["❌", "cross mark no"], ["⚠️", "warning"], ["❓", "question"], ["❗", "exclamation"],
        ["➡️", "arrow right"], ["⬅️", "arrow left"], ["⬆️", "arrow up"], ["⬇️", "arrow down"], ["🔁", "repeat"],
        ["☕", "coffee"], ["🍕", "pizza"], ["🍔", "burger"], ["🍜", "noodles pho"], ["🍚", "rice"],
        ["🍺", "beer"], ["🍷", "wine"], ["🍎", "apple"], ["🍌", "banana"], ["🥑", "avocado"],
        ["🐶", "dog"], ["🐱", "cat"], ["🐭", "mouse animal"], ["🐼", "panda"], ["🦊", "fox"],
        ["🐸", "frog"], ["🐧", "penguin"], ["🦋", "butterfly"], ["🌸", "cherry blossom"], ["🌹", "rose"],
        ["🌻", "sunflower"], ["🌍", "earth globe"], ["🚀", "rocket"], ["✈️", "airplane"], ["🚗", "car"],
        ["🏠", "house home"], ["🇻🇳", "vietnam flag"], ["🏳️‍🌈", "rainbow flag"], ["⏰", "alarm clock"], ["📅", "calendar"],
        ["📝", "memo note"], ["📚", "books"], ["💰", "money bag"], ["💸", "money wings"], ["🛒", "shopping cart"]
    ]
}

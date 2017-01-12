# Description:
#   Rust bot replies with rust docs, links and execute code at rust playground
#
# Configuration:
#   BITLY_TOKEN
#
# Commands:
#   hubot tell @user <rustbook|wiki|std|spec|awesomeness> - tell user useful links
#   hubot rustc <version> <rust source code> - execute rust code on playground, main function is not needed

fs = require 'fs'
template = fs.readFileSync "scripts/template.rs", "utf8"

wrap_in_block = (code) -> "```\n" + code + "```"
trim_block = (code) ->
    (code.replace /^\s+|\s+$/g, "").replace /^`+|`+$/g, ""

module.exports = (robot) ->
    robot.hear /^good morning!/i, (res) ->
        res.send "Good morning, everyone!"

    robot.hear /^what's this app/i, (res) ->
        res.send "It's Rocket.Chat https://github.com/RocketChat/Rocket.Chat \nYou can download desktop app here: https://github.com/RocketChat/Rocket.Chat.Electron/releases \nOr install mobile app from Google Play / App Store"

    robot.respond /what's this app/i, (res) ->
        res.send "It's Rocket.Chat https://github.com/RocketChat/Rocket.Chat \nYou can download desktop app here: https://github.com/RocketChat/Rocket.Chat.Electron/releases \nOr install mobile app from Google Play / App Store"

    robot.respond /good/i, (res) ->
        res.send "Thank you!"

    robot.respond /thank you/i, (res) ->
        time = new Date
        seconds = time.getSeconds()
        if seconds % 2 == 0
            res.send "It's my pleasure"
        else
            res.send "You're welcome!"

    robot.respond /tell @([\w.-]*):? (.*)/, (res) ->
        user = res.match[1]
        what = res.match[2]
        if what == "rustbook"
            res.send "@#{user} Please read the [book](https://doc.rust-lang.org/book)"
        else if what == "wiki"
            res.send "@#{user} See our Wiki: https://wiki.rust-china.org"
        else if what == "awesomeness"
            res.send "@#{user} Here is a list of awesomeness: https://github.com/kud1ing/awesome-rust"
        else if what == "specification" or what == "reference" or what == "spec"
            res.send "@#{user} Here is Rust specification: https://doc.rust-lang.org/reference.html"
        else if what == "std"
            res.send "@#{user} Here is Rust standard library: https://doc.rust-lang.org/std"
        else if what == "example"
            res.send "@#{user} You can learn Rust by example: http://rustbyexample.com"
        else
            res.send "Sorry sir, but I couldn't understand your command."

    robot.respond /rustc (stable|beta|nightly)((.|\s)+)/, (res) ->
        version = "stable"
        if res.match[1]
            version = res.match[1]
        code_block = res.match[2]
        code = trim_block code_block
        if version == "nightly"
            match = code.match(/#!\[feature\(.*\)\]/)
            if match != null
                feature = match[0]
                code = trim_block code.replace(feature, "")
                template = feature + "\n" + template

        params =
            code: template.replace("snippet", code)
            test: false
            color: false
            separate_output: true
            version: version
            optimize: "0"
            backtrace: "0"
        data = JSON.stringify(params)
        robot.http("https://play.rust-lang.org/evaluate.json").
            header("Content-Type", "application/json").
            post(data) (err, resp, body) ->
                result = JSON.parse(body)
                if err
                    res.send err
                else if result["program"] == undefined # failed
                    res.send (wrap_in_block result["rustc"])
                else if result["program"] != undefined # success
                    res.send (wrap_in_block result["program"])
                else
                    res.send "Something strange happened, @tennix please fix it"

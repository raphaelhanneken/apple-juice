# Apple Juice #
An advanced battery gauge for macOS. *Apple Juice* can show you the estimated _battery time remaining_ right within the status bar and notify you about certain percentages, if you want.

![Apple Juice Appmenu](screenshot_appmenu.png)
![Apple Juice Notifications](screenshot_notifications.png)

__Today Widget__

Get even more information about your current battery status, without cluttering your screen, with the *Apple Juice Today Widget*. Just take a quick glance at your battery’s stats, whenever you want.

![Apple Juice Today Widget](screenshot_today.png)

### Ok, but how accurate is it? ###
Probably as accurate as it gets. The information come directly from macOS’s IO registry and are updated constantly.

## How do I install it? ##

You have three options:

1. Install using [brew](https://brew.sh/): `brew cask install apple-juice`

1. Install from published binary :Download the [latest binary](https://github.com/raphaelhanneken/apple-juice/releases/latest) and drop it into your `Applications folder`*.

1. Download the source code and build it yourself. You'll need to have [Carthage](https://github.com/Carthage/Carthage) instsalled, and run `carthage update` to pull in the [Sparkle Framework](https://github.com/sparkle-project/Sparkle), as I haven’t put it under version control.

*Since I don’t have an Apple Developer account, you have to allow unsigned third party apps within the system preferences.
 ```System Preferences: Security & Privacy: Allow apps downloaded from: Anywhere```. If you don't have the option to select `Anywhere` you'll have to loosen the Gate Keeper restrictions by running `sudo spctl --master-disable` in the Terminal. [OSXDaily](http://osxdaily.com/2016/09/27/allow-apps-from-anywhere-macos-gatekeeper/) have a great step by step guide. Afterwards you should be able to select Anywhere.

## Why does this project exist? ##
There are plenty of other solutions out there, so why make another one? I wanted an app that looks like it’s part of the system. As if it were built directly into macOS. Which can show me a lot of information, but only when I need them. And, most importantly, it should display notifications for several percentages. Since I haven’t found such an app, I made one myself.

## How do I contribute? ##
You can fork this project, make your changes and send me a pull request. Just make sure you fork the latest development version and that [SwiftLint](https://github.com/realm/SwiftLint) succeeds. Or, since the whole source code is licensed under the MIT License, fork *Apple Juice* and make your own thing. :-)

__________

### License ###
The MIT License (MIT)

Copyright (c) 2015 Raphael Hanneken

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

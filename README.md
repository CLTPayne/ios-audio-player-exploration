### iOS 13 Music Player

Simple iOS 13.2 app to try out a music player in iOS 13.2.

#### Aim

-   Apple's release of iOS 13.2 included an update where by an app will not be able to play background audio without explicit permissions. This means any audio will cut out 30 seconds after the app is sent into the background.
-   This impacts any webview (with javascript) or React native codebases that are not instantiating a native audio player.
-   Hypothesis is that simply enabling background permissions will not fix this issue (seems to simple and that Apple's change is part of a push for more native app development).

#### Approach

-   Build a tiny test mp3 player that works on iOS 13.2 and continues playing when the app is sent to the background using this [tutorial](https://www.ioscreator.com/tutorials/play-music-avaudioplayer-ios-tutorial?rq=audio)
-   Apply this minimal player to a more complex iOS app to recreate the same audio play in background mode.

#### Notes

-   How the AVAudioPlayer is instantiated in the tutorial does not work on iOS 13.2 / xcode 11.2.1.
-   Issue with background mode will not surface in a simulator, therefore, as with a lot of iOS features need to build for a device.

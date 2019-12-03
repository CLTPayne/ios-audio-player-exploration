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
-   Tested on iOS 13.2 device and player seems to work as the timer increases, but can't hear audio. Found note online with someone saying they need headphones? Next step - use the debug area to step add break points in the ViewController and step through the variables to ensure the mp3 is correctly found. See debug area [docs](https://help.apple.com/xcode/mac/current/#/dev9de24d52b)
-   For a audio via https (rather than an asset within the project) need an AVPlayer? This example from the Apple [docs](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/MediaPlaybackGuide/Contents/Resources/en.lproj/GettingStarted/GettingStarted.html) works in a simulator but seems to use an excessive player object as if for video.
-   Alternatively use a MediaPlayer item to access operating remote control events (in app delegate) and play without a full screen media player taking over the screen - reference [this](https://stackoverflow.com/questions/4771105/how-do-i-get-my-avplayer-to-play-while-app-is-in-background) for more on background play.
-   With background audio enabled you also need to have an audio session declared in the app delegate. This is needed to communicate with the underlying audio hardware on the device. I.e. to get sound. Note - the `AVAudioSession` default behaviour silences audio when the device is locked. Therefore would need to configure the session continuious audio play for background / locked states. Setting the category to [`playback`](https://developer.apple.com/documentation/avfoundation/avaudiosession/category/1616509-playback) indicates that audio is central to the app's functionality. When using this category, your app audio continues with the Silent switch set to silent or when the screen locks. This category also defaults to the audio being 'non mixable' i.e. it will interupt any other audio sessions (rather than play both).
-   `AVPlayer` can play and pause audio but also observe time changes, rate of playback. C

Hypothesis:

-   Use [`addPeriodicTimeObserver`](https://developer.apple.com/documentation/avfoundation/avplayer/1385829-addperiodictimeobserver) to listen for changes in time every minute and report this time code back to the UI.
-   use [`MPNowPlayingInfoCenter`](https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfocenter) to create a dictonary of values to be used on lock screen and in multitasking UI, even when plugged into to a car. E.g https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfopropertyelapsedplaybacktime

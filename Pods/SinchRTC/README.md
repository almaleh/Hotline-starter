Sinch iOS SDK
==========================
Welcome to Sinch iOS SDK, http://www.sinch.com

Copyright 2014-2017, Sinch AB (reg. no 556969-5397)


Features
========
- Sinch SDK for iOS
- PSTN Calling
 - Make data calls to regular phone numbers
- Web/app calling
 - Make and receive calls
 - Call both native (iOS and Android) and web clients
- Video Calling
 - Make video calls to both native (iOS and Android) and web clients
- Conference calling
- Instant messaging
 - Cross platform (iOS, Android, JavaScript)
 - Conversations with up to 10 participants
 - Delivery receipts

Should you encounter any bugs, glitches, lack of functionality or other problems
using  our SDK, please send us an email to dev@sinch.com.
Your help in this regard is greatly appreciated.


Quick start
===========

- Install Sinch via CocoaPod (pod 'SinchRTC') or download it on www.sinch.com/downloads

- Read the user-guide for introduction and the reference docs for details

- Look at the sample apps for inspiration


Documentation
=============
The user-guide is available in the docs/ folder.
Simply open index.html and read about:

- Instructions for first-time developers
- Using Sinch in your app for making app-to-phone, app-to-app and conference calls
- Using Sinch in your app for making video calls
- Using Sinch in your app for sending and receiving messages
- Other information about Sinch, such as creating your app, note on export
  regulations and more.

Reference documentation is available in docs/ folder.

The reference documentation is also available as an Xcode DocSet, located in
docs/reference/. To make it available in Xcode, copy the DocSet-bundle into
~/Library/Developer/Shared/Documentation/DocSets/


Samples
=============
Sample code is available under samples/

- App-to-App Calling sample: SinchCalling.xcodeproj

- App-to-Phone (PSTN) Calling sample: SinchPSTN.xcodeproj

- Instant-messaging sample: SinchIM.xcodeproj

-  App-to-App Calling sample using Push Notifications:
     SinchCallingPush.xcodeproj
     This sample requires you to create and upload Apple Push Notification
     certificates in the Sinch portal.

- App-to-App Calling sample using CallKit: SinchCallKit.xcodeproj

- App-to-App Video calling sample: SinchVideo.xcodeproj

- App-to-App Video calling sample using Push Notification:
     SinchVideoPush.xcodeproj
     This sample requires you to create and upload Apple Push Notification
     certificates in the Sinch portal.

- App-to-App Video calling sample with video filter applied: SinchVideoFilter.xcodeproj

-  App-to-App Calling sample using Push Notifications and SinchService:
     SinchCallingPushWithService.xcworkspace

     This sample require you to install 'SinchService' via CocoaPods.
     Please see http://cocoapods.org/ and http://cocoapods.org/?q=SinchService.
     A Podfile is included under samples/, so you can simply run `pod install`
     Remember to open the .xcworkspace file (not .xcodeproj)

     This sample require you to create and upload Apple Push Notification
     certificates in the Sinch portal.

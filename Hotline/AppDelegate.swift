/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import UserNotifications
import Intents
import PushKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, PKPushRegistryDelegate {

    
  
    var push: SINManagedPush?
    var window: UIWindow?
    var client: SINClient?
    var user = String()
//    var callKitProvider: SINCallKitProvider?
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
         user = UIDevice.current.userInterfaceIdiom == .pad ? "Besher's iPad" : "Besher's iPhone"
        configureAudioSession()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        self.voipRegistration()
        
        push = Sinch.managedPush(with: SINAPSEnvironment.development)
//        push = Sinch.managedPush(with: SINAPSEnvironment.production)
        push?.delegate = self
        push?.setDesiredPushType(SINPushTypeVoIP)
        push?.setDisplayName(user)
        
        // if logged in
        push?.registerUserNotificationSettings()
        
        return true
    }
    
    func voipRegistration() {
        let mainQueue = DispatchQueue.main
        // Create a push registry object
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        // Set the registry's delegate to self
        voipRegistry.delegate = self
        // Set the push type to VoIP
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        push?.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        push?.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\(error.localizedDescription)")
    }
    
    
    
    func pushRegistry(registry: PKPushRegistry!, didUpdatePushCredentials credentials: PKPushCredentials!, forType type: String!) {
        // Register VoIP push token (a property of PKPushCredentials) with server
    }
    
    func pushRegistry(registry: PKPushRegistry!, didReceiveIncomingPushWithPayload payload: PKPushPayload!, forType type: String!) {
        // Process the received push
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, forType type: PKPushType) {
        // todo
    }
    
}

extension AppDelegate: SINClientDelegate, SINCallClientDelegate, SINManagedPushDelegate  {
    
    func client(_ client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        let notification = SINLocalNotification()
        notification.alertBody = "Answer me!"
        notification.alertBody = "Incoming call from: \(call.remoteUserId)"
        return notification
    }
    
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        var status = ""
        if call.details.applicationStateWhenReceived == UIApplicationState.active {
            
            
            
            status = "YOLO"

            
            
            
        } else {
            
            status = "NOOOOOOOOOOOOO"
            
            // insert code for auto-answer
            
        }
        
        print(status)
        
        CallManager.sharedInstance.currentCall = call
        ProviderDelegate.sharedInstance.reportIncomingCall(call)
        
        print("Received a call from: \(call.remoteUserId ?? "")")
    }
    
    func clientDidStart(_ client: SINClient!) {
        print("Sinch client started successfully (version: \(Sinch.version)")
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("Error starting Sinch: \(error.localizedDescription)")
    }
    
    func client(_ client: SINClient!, logMessage message: String!, area: String!, severity: SINLogSeverity, timestamp: Date!) {
        if let message = message {
            print("**SINCH-LOG**: \(message)")
        }
    }
    
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        ProviderDelegate.sharedInstance.reportIncomingCall(call)
    }
    
    func handleRemoteNotification(userInfo: [AnyHashable : Any]) {
        
        let result = client?.relayRemotePushNotification(userInfo)
        guard let resultIsCall = result?.isCall(), let callCancelled = result?.call().isCallCanceled else { return }
        if resultIsCall && callCancelled {
            presentMissedCallNotificationWithRemoteUserId(remoteUserID: result?.call().remoteUserId ?? "")
        }
        
    }
    
    func presentMissedCallNotificationWithRemoteUserId(remoteUserID: String) {
        
    }
    
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        handleRemoteNotification(userInfo: payload)
    }

    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    
}

extension AppDelegate {
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
//
//        let intent = userActivity.interaction?.intent
//        if intent is INStartAudioCallIntent {
//
//            let person = (intent as! INStartAudioCallIntent).contacts?.first
//            let phoneNumber = person?.personHandle?.value
//            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//            let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: CallsViewController.self)) as! CallsViewController
//            //            viewController.phoneNumber = phoneNumber
//
//            let mainViewController = window?.rootViewController
//            mainViewController?.present(viewController, animated: true, completion: nil)
//        }
//        return true
//    }
}

//
//  ExtensionDelegate.swift
//  MonochromeBattery WatchKit Extension
//
//  Created by David Smith on 9/28/18.
//  Copyright © 2018 Cross Forward Consulting, LLC. All rights reserved.
//

import WatchKit

class Refresher {
    static func scheduleUpdate(scheduledCompletion: @escaping (Error?) -> Void) {
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date().addingTimeInterval(15 * 60), userInfo: nil, scheduledCompletion: scheduledCompletion)
    }
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        Refresher.scheduleUpdate { (error) in
            print("Scheduled in applicationDidFinishLaunching")
        }
    }

    func applicationDidBecomeActive() {
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                Refresher.scheduleUpdate { (error) in
                    print("Scheduled in WKApplicationRefreshBackgroundTask")
                    if let active = CLKComplicationServer.sharedInstance().activeComplications {
                        for complication in active {
                            CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
                        }
                    }
                    backgroundTask.setTaskCompletedWithSnapshot(false)
                }

                
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}

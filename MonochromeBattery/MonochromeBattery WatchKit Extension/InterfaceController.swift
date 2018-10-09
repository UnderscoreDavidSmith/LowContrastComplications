//
//  InterfaceController.swift
//  MonochromeBattery WatchKit Extension
//
//  Created by David Smith on 9/28/18.
//  Copyright © 2018 Cross Forward Consulting, LLC. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var batteryLabelText: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        let batteryPercent = WKInterfaceDevice.current().batteryLevel
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = false
        self.batteryLabelText.setText("\("\(Int(batteryPercent * 100))%")")
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

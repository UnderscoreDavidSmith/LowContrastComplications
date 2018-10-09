//
//  ComplicationController.swift
//  MonochromeBattery WatchKit Extension
//
//  Created by David Smith on 9/28/18.
//  Copyright © 2018 Cross Forward Consulting, LLC. All rights reserved.
//

import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: self.getTemplateForComplication(complication: complication)))
        Refresher.scheduleUpdate { (error) in
            print("Scheduled in getCurrentTimelineEntry")
        }
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(getTemplateForComplication(complication: complication, override: 0.7))
    }
    
    func getTemplateForComplication(complication:CLKComplication, override:Float? = nil) -> CLKComplicationTemplate {
        
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        var batteryPercent = WKInterfaceDevice.current().batteryLevel
        var batteryState = WKInterfaceDevice.current().batteryState
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = false
        
        if let overrideValue = override {
            batteryPercent = overrideValue;
            batteryState = .charging
        }
        if batteryPercent > 1.0 {
            batteryPercent = 1.0
        }
        if batteryPercent < 0.0 {
            batteryPercent = 0.0
        }
        
        let percentTextProvider = CLKSimpleTextProvider(text: "\(Int(batteryPercent * 100))%", shortText:"\(Int(batteryPercent * 100))")

        var batteryStateString = "Unknown"
        switch batteryState {
        case .unknown:
            batteryStateString = "Unknown"
        case .unplugged:
            batteryStateString = "Unplugged"
        case .charging:
            batteryStateString = "Charging"
        case .full:
            batteryStateString = "Full"
        }
        let stateTextProvider = CLKSimpleTextProvider(text: batteryStateString)

        var gaugeColor = UIColor(white: 0.25, alpha: 1.0)
        if batteryPercent <= 0.1 {
            gaugeColor = UIColor(hue: 0.0, saturation: 1.0, brightness: 0.4, alpha: 1.0)
        }
        let gauge = CLKSimpleGaugeProvider(style: .fill, gaugeColor:gaugeColor, fillFraction: batteryPercent)

        
        switch(complication.family) {
            
        case .modularSmall:
            let modularSmall = CLKComplicationTemplateModularSmallRingText()
            modularSmall.fillFraction = batteryPercent
            modularSmall.textProvider = percentTextProvider
            return modularSmall;
        case .modularLarge:
            let modularLarge = CLKComplicationTemplateModularLargeStandardBody()
            modularLarge.headerTextProvider = percentTextProvider
            modularLarge.body1TextProvider = stateTextProvider
            return modularLarge
        case .utilitarianSmall:
            let utilitarianSmall = CLKComplicationTemplateUtilitarianSmallRingText()
            utilitarianSmall.fillFraction = batteryPercent
            utilitarianSmall.textProvider = percentTextProvider
            return utilitarianSmall
        case .utilitarianSmallFlat:
            let utilitarianSmallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianSmallFlat.textProvider = percentTextProvider
            return utilitarianSmallFlat
        case .utilitarianLarge:
            let utilitarianLarge = CLKComplicationTemplateUtilitarianLargeFlat()
            utilitarianLarge.textProvider = percentTextProvider
            return utilitarianLarge
        case .circularSmall:
            let circularSmall = CLKComplicationTemplateCircularSmallRingText()
            circularSmall.fillFraction = batteryPercent
            circularSmall.textProvider = percentTextProvider
            return circularSmall
        case .extraLarge:
            let extraLarge = CLKComplicationTemplateExtraLargeRingText()
            extraLarge.fillFraction = batteryPercent
            extraLarge.textProvider = percentTextProvider
            return extraLarge
        case .graphicCorner:
            let graphicCorner = CLKComplicationTemplateGraphicCornerGaugeImage()
            graphicCorner.imageProvider = CLKFullColorImageProvider(fullColorImage: self.batteryImage(batteryPercent: batteryPercent))
            graphicCorner.gaugeProvider = gauge
            return graphicCorner
        case .graphicBezel:
            let graphicCircular = CLKComplicationTemplateGraphicCircularClosedGaugeImage()
            graphicCircular.imageProvider = CLKFullColorImageProvider(fullColorImage: self.batteryWithTextImage(batteryPercent: batteryPercent))
            graphicCircular.gaugeProvider = gauge
            graphicCircular.tintColor = UIColor(white: 0.25, alpha: 1.0)

            let graphicBezel = CLKComplicationTemplateGraphicBezelCircularText()
            graphicBezel.circularTemplate = graphicCircular
            graphicBezel.textProvider = percentTextProvider
            return graphicBezel
        case .graphicCircular:
            let graphicCircular = CLKComplicationTemplateGraphicCircularClosedGaugeImage()
            graphicCircular.imageProvider = CLKFullColorImageProvider(fullColorImage: self.batteryWithTextImage(batteryPercent: batteryPercent))
            graphicCircular.gaugeProvider = gauge
            graphicCircular.tintColor = UIColor(white: 0.25, alpha: 1.0)
            return graphicCircular
            
        case .graphicRectangular:
            let graphicRectangular = CLKComplicationTemplateGraphicRectangularTextGauge()
            graphicRectangular.headerTextProvider = stateTextProvider
            graphicRectangular.body1TextProvider = percentTextProvider
            graphicRectangular.gaugeProvider = gauge;
            return graphicRectangular
        }
        
        
    }
    
    func batteryWithTextImage(batteryPercent:Float) -> UIImage {

        let width:CGFloat = 32.0
        let height:CGFloat = 32.0;
        
        let batteryHeight = height * 0.2
        let batteryWidth  = width * 0.5
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width:width, height:height), false, 2.0)
        
        var attributes = [
            NSAttributedString.Key.foregroundColor : UIColor(white: 0.45, alpha: 1.0),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0, weight: .bold)
        ]
        
        let string = "\(Int(batteryPercent * 100))"
        var size = string.size(withAttributes: attributes)
        if(size.width > width) {
            attributes = [
                NSAttributedString.Key.foregroundColor : UIColor(white: 0.45, alpha: 1.0),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0, weight: .bold)
            ]
            size = string.size(withAttributes: attributes)
        }
        
        let contentHeight = batteryHeight  + size.height + 3
        let contentOrigin = height / 2.0 - contentHeight / 2.0
        
        string.draw(at:CGPoint(x: width / 2 - size.width / 2.0, y:contentOrigin), withAttributes:attributes)
        
        let batteryOrigin = CGPoint(x: (width - batteryWidth) / 2.0, y: contentOrigin + size.height - 1)
        
        UIColor(white: 0.3, alpha: 1.0).setStroke()
        let outerPath = UIBezierPath(roundedRect: CGRect(x: batteryOrigin.x, y: batteryOrigin.y, width: batteryWidth, height: batteryHeight), cornerRadius: 1)
        outerPath.stroke()
        
        let positiveTerminal = UIBezierPath(roundedRect: CGRect(x: batteryOrigin.x + batteryWidth, y: batteryOrigin.y + batteryHeight / 2.0 - 1.5, width: 2, height: 3), cornerRadius: 1)
        positiveTerminal.fill()
        
        let batteryColor = UIColor(hue: CGFloat(batteryPercent * 120) / 360.0, saturation: 1.0, brightness: 0.35, alpha: 1.0)
        
        let colorPath = UIBezierPath(roundedRect: CGRect(x: batteryOrigin.x + 1, y: batteryOrigin.y + 1, width: (batteryWidth - 2) * CGFloat(batteryPercent), height: batteryHeight - 2), cornerRadius: 0)
        batteryColor.setFill()
        colorPath.fill()
        
        let imageConverted: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return imageConverted
    }
    
    func batteryImage(batteryPercent:Float) -> UIImage {
        
        let width:CGFloat = 44.0
        let height:CGFloat = 44.0;
        
        let batteryHeight = height * 0.2
        let batteryWidth  = width * 0.35
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width:width, height:height), false, 2.0)
        
        let batteryOrigin = CGPoint(x: (width - batteryWidth) / 2.0, y: (height - batteryHeight) / 2.0)
        
        UIColor(white: 0.3, alpha: 1.0).setStroke()
        UIColor(white: 0.3, alpha: 1.0).setFill()
        let outerPath = UIBezierPath(roundedRect: CGRect(x: batteryOrigin.x, y: batteryOrigin.y, width: batteryWidth, height: batteryHeight), cornerRadius: 1)
        outerPath.stroke()
        
        let positiveTerminal = UIBezierPath(roundedRect: CGRect(x: batteryOrigin.x + batteryWidth, y: batteryOrigin.y + batteryHeight / 2.0 - 1.5, width: 2, height: 3), cornerRadius: 1)
        positiveTerminal.fill()
        
        let batteryColor = UIColor(hue: CGFloat(batteryPercent * 120) / 360.0, saturation: 1.0, brightness: 0.35, alpha: 1.0)
        
        let colorPath = UIBezierPath(roundedRect: CGRect(x: batteryOrigin.x + 1, y: batteryOrigin.y + 1, width: (batteryWidth - 2) * CGFloat(batteryPercent), height: batteryHeight - 2), cornerRadius: 0)
        batteryColor.setFill()
        colorPath.fill()
        
        let imageConverted: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return imageConverted
    }
}

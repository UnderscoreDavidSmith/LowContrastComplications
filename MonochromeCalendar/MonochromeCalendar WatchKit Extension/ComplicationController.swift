//
//  ComplicationController.swift
//  MonochromeCalendar WatchKit Extension
//
//  Created by David Smith on 9/28/18.
//  Copyright © 2018 Cross Forward Consulting, LLC. All rights reserved.
//

import ClockKit


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
        let width:CGFloat = 32.0
        let height:CGFloat = 32.0;
        
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEE"
        let dayOfWeek = dayOfWeekFormatter.string(from: Date()).uppercased()
        
        let dayOfMonthFormatter = DateFormatter()
        dayOfMonthFormatter.dateFormat = "d"
        let dayOfMonth = dayOfMonthFormatter.string(from: Date())

        let fullFormatter = DateFormatter()
        fullFormatter.timeStyle = .none
        fullFormatter.dateStyle = .short
        let fullDate = fullFormatter.string(from: Date())
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width:width, height:height), false, 2.0)

        let weekdayFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        let weekdayAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(hue: 0.0, saturation: 1.0, brightness: 0.45, alpha: 1.0),
            NSAttributedString.Key.font : weekdayFont
        ]
        let weekdaySize = dayOfWeek.size(withAttributes: weekdayAttributes)

        let dayFont = UIFont.systemFont(ofSize: 24.0, weight: .medium)
        let dayAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(white: 0.45, alpha: 1.0),
            NSAttributedString.Key.font : dayFont
        ]
        let daySize = dayOfMonth.size(withAttributes: dayAttributes)

        let contentHeight = daySize.height + weekdaySize.height + weekdayFont.descender + dayFont.descender
        let contentOffset = (height - contentHeight) / 2.0
        
        dayOfWeek.draw(at:CGPoint(x: width / 2.0 - weekdaySize.width / 2.0, y: contentOffset), withAttributes:weekdayAttributes)
        dayOfMonth.draw(at:CGPoint(x: width / 2.0 - daySize.width / 2.0,    y: contentOffset + weekdaySize.height + weekdayFont.descender + dayFont.descender + 2), withAttributes:dayAttributes)

        let imageConverted: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let imageProvider = CLKImageProvider(onePieceImage: imageConverted)
        
        
        switch(complication.family) {
            
        case .modularSmall:
            let modularSmall = CLKComplicationTemplateModularSmallSimpleImage()
            modularSmall.imageProvider = imageProvider
            return modularSmall;
        case .modularLarge:
            let modularLarge = CLKComplicationTemplateModularLargeStandardBody()
            modularLarge.headerTextProvider = CLKSimpleTextProvider(text: dayOfWeek)
            modularLarge.body1TextProvider = CLKSimpleTextProvider(text: dayOfMonth)
            return modularLarge
        case .utilitarianSmall:
            let utilitarianSmall = CLKComplicationTemplateUtilitarianSmallSquare()
            utilitarianSmall.imageProvider = imageProvider
            return utilitarianSmall
        case .utilitarianSmallFlat:
            let utilitarianSmallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianSmallFlat.textProvider = CLKSimpleTextProvider(text: fullDate)
            return utilitarianSmallFlat
        case .utilitarianLarge:
            let utilitarianLarge = CLKComplicationTemplateUtilitarianLargeFlat()
            utilitarianLarge.textProvider = CLKSimpleTextProvider(text: fullDate)
            return utilitarianLarge
        case .circularSmall:
            let circularSmall = CLKComplicationTemplateCircularSmallSimpleImage()
            circularSmall.imageProvider = imageProvider
            return circularSmall
        case .extraLarge:
            let extraLarge = CLKComplicationTemplateExtraLargeStackText()
            extraLarge.line1TextProvider = CLKSimpleTextProvider(text: dayOfWeek)
            extraLarge.line2TextProvider = CLKSimpleTextProvider(text: dayOfMonth)
            return extraLarge
        case .graphicCorner:
            let graphicCorner = CLKComplicationTemplateGraphicCornerCircularImage()
            graphicCorner.imageProvider = CLKFullColorImageProvider(fullColorImage: imageConverted)
            return graphicCorner
        case .graphicBezel:
            let circle = CLKComplicationTemplateGraphicCircularImage()
            circle.imageProvider = CLKFullColorImageProvider(fullColorImage: imageConverted)
            
            let graphicBezel = CLKComplicationTemplateGraphicBezelCircularText()
            graphicBezel.circularTemplate = circle
            graphicBezel.textProvider = nil
            return graphicBezel
            
        case .graphicCircular:
            let graphicCircular = CLKComplicationTemplateGraphicCircularImage()
            graphicCircular.imageProvider = CLKFullColorImageProvider(fullColorImage: imageConverted)
            return graphicCircular
            
        case .graphicRectangular:
            let graphicRectangular = CLKComplicationTemplateGraphicRectangularStandardBody()
            graphicRectangular.headerTextProvider = CLKSimpleTextProvider(text: dayOfWeek)
            graphicRectangular.body1TextProvider = CLKSimpleTextProvider(text: dayOfMonth)
            return graphicRectangular
        }
        
        
    }
    
}

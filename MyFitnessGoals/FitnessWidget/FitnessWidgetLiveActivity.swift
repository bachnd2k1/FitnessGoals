//
//  FitnessWidgetLiveActivity.swift
//  FitnessWidget
//
//  Created by Nghiem Dinh Bach on 11/3/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FitnessWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FitnessAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                FitnessLiveActivityView(context: context)
            }
            .activityBackgroundTint(Color.white)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {

                }
                DynamicIslandExpandedRegion(.trailing) {

                }
                DynamicIslandExpandedRegion(.bottom) {
            
                }
            } compactLeading: {
                Text(context.state.elapsedTime)
                    .font(.caption2)
            } compactTrailing: {
                Image(systemName: context.state.icon)
            } minimal: {
                
            }
            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint(Color.red)
        }
    }
}

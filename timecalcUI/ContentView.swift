//
//  ContentView.swift
//  timecalcUI
//
//  Created by Robert Dodson on 3/2/24.
//

import SwiftUI
import Time

struct ContentView: View
{
    @State var calendar = Calendar.current
    @State var timeZone = TimeZone.current
    @State var locale = Locale.current
    
    @State var startSecond : Fixed<Second> = Clocks.system.currentSecond
    @State var endSecond   : Fixed<Second> = Clocks.system.currentSecond + .days(1)
    
    var startColor = Color.green
    var endColor = Color.cyan
    
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            ClockPicker(calendar: $calendar,timeZone: $timeZone,locale: $locale)
            
            Spacer()
            
            Text("From:")
                .font(.largeTitle)
                .foregroundColor(startColor)
            CalenderView(selectedSecond:$startSecond,color:startColor)
            
            Spacer()
            
            Text("To:")
                .font(.largeTitle)
                .foregroundColor(endColor)
            CalenderView(selectedSecond:$endSecond,color:endColor)
           
            Spacer()
            
            Text("Differences:")
                .font(.largeTitle)
            DifferencesView(startSecond:$startSecond,endSecond:$endSecond,startColor: startColor,endColor: endColor)
        }
        .onAppear { update() }
        .onChange(of: calendar, { update() })
        .onChange(of: timeZone, { update() })
        .onChange(of: locale, { update() })
        .frame(width: 400,height: 800)
        .padding()
    }

    
    func update()
    {
        let clock = Clocks.system(in: Region(calendar: calendar, timeZone: timeZone, locale: locale))
        startSecond = clock.currentSecond
        endSecond = clock.currentSecond.nextDay
    }
    
}




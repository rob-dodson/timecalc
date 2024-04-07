//
//  ClockView.swift
//  timecalcUI
//
//  Created by Robert Dodson on 3/27/24.
//

import SwiftUI

import Time


struct ClockView: View
{
    @Binding var selectedSecond : Fixed<Second>
    
    @State var hourName : Int = Clocks.system.currentHour.hour
    @State var ampm : String = Clocks.system.calendar.amSymbol
    @State var hourType : String = HOUR24
    
    static let HOUR24 : String = "24"
    static let HOUR12 : String = "12"
    
    var body: some View
    {
        HStack
        {
            Stepper(selectedSecond.format(hour: .naturalDigits(dayPeriod: .none)))
            {
                selectedSecond = selectedSecond.nextHour
            }
        onDecrement:
            {
                selectedSecond = selectedSecond.previousHour
            }
            
            Text(":")
            
            Stepper(selectedSecond.format(minute: .twoDigits))
            {
                selectedSecond = selectedSecond.nextMinute
            }
        onDecrement:
            {
                selectedSecond = selectedSecond.previousMinute
            }
            
            Text(":")
            
            Stepper(selectedSecond.format(second: .twoDigits))
            {
                selectedSecond = selectedSecond.nextSecond
            }
        onDecrement:
            {
                selectedSecond = selectedSecond.previousSecond
            }
            
            if hourType == ClockView.HOUR12
            {
                Text(ampm)
            }
            
            Picker("",selection: $hourType)
            {
                Text(ClockView.HOUR24)
                    .tag(ClockView.HOUR24)
                Text(ClockView.HOUR12)
                    .tag(ClockView.HOUR12)
            }
            .frame(width: 70)
            .onChange(of: hourType)
            { oldValue, newValue in
                hourType = newValue
                update()
            }
            
            Button("Now")
            {
                setnow()
            }
        }
        .onChange(of: selectedSecond)
        {
            update()
        }
    }
    
    
    func setnow()
    {
        do
        {
            let now  = Clocks.system.currentSecond
            selectedSecond = try selectedSecond.setting(hour: now.hour,
                                                        minute: now.minute,
                                                        second: now.second)
        }
        catch
        {
            print("setnow error: \(error)")
        }
    }
    
    
    func update()
    {
        ampm = selectedSecond.hour >= 12 ? selectedSecond.calendar.pmSymbol : selectedSecond.calendar.amSymbol
        
        hourName = selectedSecond.hour
        if hourType == ClockView.HOUR12
        {
            hourName = selectedSecond.hour > 12 ? selectedSecond.hour - 12 : selectedSecond.hour
            if hourName == 0
            {
                hourName = 12
            }
        }
    }
}


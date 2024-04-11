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
            
            if selectedSecond.locale.hourCycle == .oneToTwelve || selectedSecond.locale.hourCycle == .zeroToEleven 
            {
                Text(selectedSecond.hour < 12 ? selectedSecond.calendar.amSymbol : selectedSecond.calendar.pmSymbol)
            }
            
            Button("Now")
            {
                do
                {
                    let now  = Clocks.system.currentSecond
                    selectedSecond = try selectedSecond.setting(hour: now.hour,minute: now.minute,second: now.second)
                }
                catch
                {
                    print("setnow error: \(error)")
                }
            }
        }
    }
}


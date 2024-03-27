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
    @State var ampm : String = "am"
    @State var hourType : String = "24"
    
    
    var body: some View
    {
        HStack
        {
            Stepper(String(format:"%02d",hourName))
            {
                selectedSecond = selectedSecond.nextHour
                update()
            }
        onDecrement:
            {
                selectedSecond = selectedSecond.previousHour
                update()
            }
            
            Text(":")
            
            Stepper(String(format:"%02d",selectedSecond.minute))
            {
                selectedSecond = selectedSecond.nextMinute
                update()
            }
        onDecrement:
            {
                selectedSecond = selectedSecond.previousMinute
                update()
            }
            
            Text(":")
            
            Stepper(String(format:"%02d",selectedSecond.second))
            {
                selectedSecond = selectedSecond.nextSecond
                update()
            }
        onDecrement:
            {
                selectedSecond = selectedSecond.previousSecond
                update()
            }
            
            if hourType == "12"
            {
                Text(ampm)
            }
            
            Picker("",selection: $hourType)
            {
                Text("24")
                    .tag("24")
                Text("12")
                    .tag("12")
            }
            .frame(width: 70)
            .onChange(of: hourType)
            { oldValue, newValue in
                hourType = newValue
                update()
            }
            
            Button("Now")
            {
                selectedSecond = Clocks.system.currentSecond // FIX - change time only?
                update()
            }
        }
        .onChange(of: selectedSecond) 
        { oldValue, newValue in
            selectedSecond = newValue
            update()
        }
    }
    
    func update()
    {
        ampm = selectedSecond.hour >= 12 ? "pm" : "am"
        hourName = selectedSecond.hour
        if hourType == "12"
        {
            hourName = selectedSecond.hour > 12 ? selectedSecond.hour - 12 : selectedSecond.hour
            if hourName == 0
            {
                hourName = 12
            }
        }
    }
}


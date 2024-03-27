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
    @State var startSecond : Fixed<Second> = Clocks.system.currentSecond
    @State var endSecond   : Fixed<Second> = Clocks.system.currentSecond + .days(1)
    
    var startColor = Color.green
    var endColor = Color.cyan
    
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Text("From:")
                .font(.largeTitle)
                .foregroundColor(startColor)
            CalView(selectedSecond:$startSecond,color:startColor)
            
            Spacer()
            
            Text("To:")
                .font(.largeTitle)
                .foregroundColor(endColor)
            
            CalView(selectedSecond:$endSecond,color:endColor)
           
            Spacer()
            
            Text("Differences:")
                .font(.largeTitle)
            
            calcdiff(start_second:$startSecond,end_second:$endSecond)
        }
        .frame(width: 400,height: 800)
        .padding()
    }

    
    func plural(count:Int,amount:String) -> String
    {
        if count == 1
        {
            return "\(count) \(amount)"
        }
        else
        {
            return "\(count) \(amount)s"
        }
    }
    
    
    func calcdiff(start_second:Binding<Fixed<Second>>,end_second:Binding<Fixed<Second>>) -> some View
    {
        let diffyears   = startSecond.differenceInWholeYears(to: endSecond).years
        let diffmonths  = startSecond.differenceInWholeMonths(to: endSecond).months
        let diffdays    = startSecond.differenceInWholeDays(to: endSecond).days
        let diffhours   = startSecond.differenceInWholeHours(to: endSecond).hours
        let diffminutes = startSecond.differenceInWholeMinutes(to: endSecond).minutes
        let diffseconds = startSecond.differenceInWholeSeconds(to: endSecond).seconds
        
        let plusmonths = diffmonths % 12
        let plusdays = diffdays % 30 // FIX - make smarter
        let plushours = diffhours % 24
        let plusminutes = diffminutes % 60
        let plusseconds = diffseconds % 60
        
        let minus : String = startSecond.isAfter(endSecond) ? "-" : ""

            
        return VStack(alignment: .leading)
        {
            Text("\(startSecond.fixedDay.description)")
                .foregroundColor(startColor)
                .font(.headline)
            
            Text("\(endSecond.fixedDay.description)")
                .foregroundColor(endColor)
                .font(.headline)
            
            HStack
            {
                Stepper("\(minus)\(plural(count:diffyears, amount:"year"))")     { endSecond = endSecond.nextYear } onDecrement: { endSecond = endSecond.previousYear }
                Text("+ \(plural(count:plusmonths, amount:"month"))").foregroundStyle(.gray)
            }
            
            HStack
            {
                Stepper("\(minus)\(plural(count:diffmonths, amount:"month"))")   { endSecond = endSecond.nextMonth } onDecrement:  { endSecond = endSecond.previousMonth }
                Text("+ \(plural(count:plusdays, amount:"day"))").foregroundStyle(.gray)
            }
            
            HStack
            {
                Stepper("\(minus)\(plural(count:diffdays, amount:"day"))")       { endSecond = endSecond.nextDay } onDecrement: { endSecond = endSecond.previousDay }
                Text("+ \(plural(count:plushours, amount:"hour"))").foregroundStyle(.gray)
            }
            
            HStack
            {
                Stepper("\(minus)\(plural(count:diffhours, amount:"hour"))")     { endSecond = endSecond.nextHour } onDecrement:   { endSecond = endSecond.previousHour }
                Text("+ \(plural(count:plusminutes, amount:"minute"))").foregroundStyle(.gray)
            }
            
            HStack
            {
                Stepper("\(minus)\(plural(count:diffminutes, amount:"minute"))") { endSecond = endSecond.nextMinute } onDecrement: { endSecond = endSecond.previousMinute }
                Text("+ \(plural(count:plusseconds, amount:"second"))").foregroundStyle(.gray)
            }
            
            Stepper("\(minus)\(plural(count:diffseconds, amount:"second"))") { endSecond = endSecond.nextSecond } onDecrement: { endSecond = endSecond.previousSecond }

        }
        .font(.body)
        .foregroundColor(.white)
        .padding()
        .background()
        .cornerRadius(5.0)
    }
}




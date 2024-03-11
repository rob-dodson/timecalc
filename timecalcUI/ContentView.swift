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
    @State var endSecond   : Fixed<Second> = Clocks.system.nextSecond + .days(1)
    @State var startMonth  : Fixed<Month> = Clocks.system.currentMonth
    @State var startDay    : Fixed<Day> = Clocks.system.currentDay
    @State var endMonth    : Fixed<Month> = Clocks.system.currentMonth
    @State var endDay      : Fixed<Day> = Clocks.system.currentDay + .days(1)
    
    var startColor = Color.green
    var endColor = Color.cyan
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            CalView(selectedMonth:$startMonth,
                    selectedDay:$startDay,
                    selectedSecond:$startSecond,
                    color:startColor)
            
            CalView(selectedMonth:$endMonth,
                    selectedDay:$endDay,
                    selectedSecond:$endSecond,
                    color:endColor)
            
            calcdiff(start_second:$startSecond,
                     end_second:$endSecond)
        }
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
        let diffyears   = startSecond.differenceInWholeYears(to: endSecond)
        let diffmonths  = startSecond.differenceInWholeMonths(to: endSecond)
        let diffdays    = startSecond.differenceInWholeDays(to: endSecond)
        let diffhours   = startSecond.differenceInWholeHours(to: endSecond)
        let diffminutes = startSecond.differenceInWholeMinutes(to: endSecond)
        let diffseconds = startSecond.differenceInWholeSeconds(to: endSecond)
        
        var diffmonthextradays = endDay.dayOfMonth
        let minus : String = startSecond.isAfter(endSecond) ? "-" : ""
        
        if diffmonths.months == 0
        {
            diffmonthextradays = diffdays.days
        }
            
        return VStack(alignment: .leading)
        {
            Text("From: \(startDay.description)")
                .foregroundColor(startColor)
                .font(.headline)
            
            Text("To: \(endDay.description)")
                .foregroundColor(endColor)
                .font(.headline)
            
            Text("\(minus)\(diffyears.years) years + \(plural(count:diffmonths.months % 12, amount:"month"))")
            Text("\(minus)\(diffmonths.months) months + \(plural(count:diffmonthextradays, amount:"day"))")
            Text("\(minus)\(diffdays.days) days + \(plural(count:diffhours.hours % 24, amount:"hour"))")
            Text("\(minus)\(diffhours.hours) hours + \(plural(count:diffminutes.minutes % 60, amount:"minute"))")
            Text("\(minus)\(diffminutes.minutes) minutes + \(plural(count:diffseconds.seconds % 60, amount:"second"))")
            Text("\(minus)\(plural(count:diffseconds.seconds,amount:"second"))")
        }
        .font(.body)
        .foregroundColor(.white)
        .padding()
        .background()
        .cornerRadius(5.0)
    }
}




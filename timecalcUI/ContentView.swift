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
    @State var endSecond : Fixed<Second> = Clocks.system.nextSecond + .days(1)
    @State var startMonth : Fixed<Month> = Clocks.system.currentMonth
    @State var startDay : Fixed<Day> = Clocks.system.currentDay
    @State var endMonth : Fixed<Month> = Clocks.system.currentMonth
    @State var endDay : Fixed<Day> = Clocks.system.currentDay + .days(1)
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            CalView(selectedMonth: $startMonth,selectedDay: $startDay,selectedSecond:$startSecond,color: Color.blue)
            CalView(selectedMonth: $endMonth,selectedDay: $endDay,selectedSecond:$endSecond,color: Color.cyan)
            calcdiff(start_second:$startSecond,end_second:$endSecond)
        }
        .padding()
    }
    
    
    func calcdiff(start_second:Binding<Fixed<Second>>,end_second:Binding<Fixed<Second>>) -> some View
    {
        let diffyears   = startSecond.differenceInWholeYears(to: endSecond)
        let diffmonths  = startSecond.differenceInWholeMonths(to: endSecond)
        let diffdays    = startSecond.differenceInWholeDays(to: endSecond)
        let diffhours   = startSecond.differenceInWholeHours(to: endSecond)
        let diffminutes = startSecond.differenceInWholeMinutes(to: endSecond)
        let diffseconds = startSecond.differenceInWholeSeconds(to: endSecond)
        
        return VStack(alignment: .leading)
        {
            Text("From: \(startDay.description)").foregroundColor(.blue)
            Text("To: \(endDay.description)").foregroundColor(.cyan)
            Text("\(diffyears.years) years \(diffmonths.months % 12) months")
            Text("\(diffmonths.months) months \(endDay.dayOfMonth) days")
            Text("\(diffdays.days) days \(diffhours.hours % 24) hours")
            Text("\(diffhours.hours) hours \(diffminutes.minutes % 60) minutes")
            Text("\(diffminutes.minutes) minutes \(diffseconds.seconds % 60) seconds")
            Text("\(diffseconds.seconds) seconds")
        }
        .font(.headline)
        .foregroundColor(.green)
    }
}




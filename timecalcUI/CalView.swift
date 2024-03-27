//
//  CalView.swift
//  timecalcUI
//
//  Created by Robert Dodson on 3/2/24.
//
import Foundation
import SwiftUI

import Time


struct CalView: View
{
    @Binding var selectedSecond : Fixed<Second>
   
    var color : Color = Color.white
    
    @State var selectedMonth : Fixed<Month> = Clocks.system.currentMonth
    @State var selectedDay : Fixed<Day> = Clocks.system.currentDay
    @State var monthName : String = Clocks.system.currentMonth.format(month:.naturalName)
    @State var hourName : Int = Clocks.system.currentHour.hour
    @State var ampm : String = "am"
    @State var hourType : String = "24"
    
    let consistentNumberOfWeeks = true
    
    var body: some View
    {
        VStack
        {
            calendarView
            clockView
        }
        .onAppear()
        {
            calcTime()
        }
        .onChange(of: selectedSecond) // changes from the differences view
        { oldValue, newValue in
            selectedSecond = newValue
            calcTime()
        }
    }
    
    
    func calcTime()
    {
        selectedMonth = selectedSecond.fixedMonth
        monthName = selectedMonth.format(month:.naturalName)
        selectedDay = selectedSecond.fixedDay
        if hourType == "12"
        {
            hourName = selectedSecond.hour > 12 ? selectedSecond.hour - 12 : selectedSecond.hour
            if hourName == 0
            {
                hourName = 12
            }
        }
        else
        {
            hourName = selectedSecond.hour
        }
        ampm = selectedSecond.hour >= 12 ? "pm" : "am"
    }
    
    
    func setdate(day:Fixed<Day>,month:String)
    {
        do
        {
            selectedSecond = try Fixed<Second>(region: .current,
                                               year: selectedSecond.year,
                                               month: try Fixed<Month>(stringValue: month, rawFormat: "MMMM", region: Region.current).month,
                                               day: day.day,
                                               hour: selectedSecond.hour,
                                               minute: selectedSecond.minute,
                                               second: selectedSecond.second)
        }
        catch
        {
            print("setdate error: \(error)")
        }
    }
   
    
    private var clockView: some View
    {
        return HStack
        {
            Stepper(String(format:"%02d",hourName))
            {
                selectedSecond = selectedSecond.nextHour
                calcTime()
            }
            onDecrement:
            {
                selectedSecond = selectedSecond.previousHour
                calcTime()
            }
            
            Text(":")
            
            Stepper(String(format:"%02d",selectedSecond.minute))
            {
                selectedSecond = selectedSecond.nextMinute
                calcTime()
            }
            onDecrement:
            {
                selectedSecond = selectedSecond.previousMinute
                calcTime()
            }
            
            Text(":")
            
            Stepper(String(format:"%02d",selectedSecond.second))
            {
                selectedSecond = selectedSecond.nextSecond
                calcTime()
            }
            onDecrement:
            {
                selectedSecond = selectedSecond.previousSecond
                calcTime()
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
                calcTime()
            }
            
            Button("Now")
            {
                selectedSecond = Clocks.system.currentSecond // FIX - just change time?
                calcTime()
            }
        }
    }
    

    private var weeksForCurrentMonth: Array<[Fixed<Day>]>
    {
        var allDays = Array(selectedMonth.days)
        
        // pad out the front of the array with any additional days
        while allDays[0].dayOfWeek != selectedMonth.calendar.firstWeekday
        {
            allDays.insert(allDays[0].previous, at: 0)
        }
        
        if consistentNumberOfWeeks
        {
            // Apple Calendar shows 6 weeks at a time, so all views have the same vertical height
            // this eliminates complexity around dynamically resizing the month view
            while allDays.count < 42
            {
                allDays.append(allDays.last!.next)
            }
        }
        else
        {
            repeat
            {
                let proposedNextDay = allDays.last!.next
                if proposedNextDay.dayOfWeek != selectedMonth.calendar.firstWeekday
                {
                    allDays.append(proposedNextDay)
                }
                else
                {
                    break
                }
            } while true
        }
        
        // all supported calendars have weeks of seven days
        assert(allDays.count.isMultiple(of: 7))
        
        // slice the array into groups of seven
        let numberOfWeeks = allDays.count / 7
        
        return (0 ..< numberOfWeeks).map
        { weekNumber in
            let dayRange = (weekNumber * 7) ..< ((weekNumber + 1) * 7)
            return Array(allDays[dayRange])
        }
    }
    
    
    private var calendarView: some View
    {
        let weeks = self.weeksForCurrentMonth
        
        return VStack {
            
            // current month + movement controls
            HStack
            {
                // month picker
                Picker("", selection: $monthName)
                {
                    ForEach(Calendar.current.monthSymbols, id: \.self)
                    { month in
                        Text("\(month)")
                            .foregroundColor(color)
                    }
                }
                .pickerStyle(.automatic)
                .frame(width: 120)
                .onChange(of: monthName)
                { oldValue, newValue in
                    setdate(day:selectedSecond.fixedDay,month:newValue)
                    calcTime()
                }
                
                // year stepper
                Stepper
                {
                    Text("\(selectedSecond.year.description)")
                        .foregroundColor(color)
                }
                onIncrement:
                {
                    selectedSecond = selectedSecond.nextYear
                    calcTime()
                }
                onDecrement:
                {
                    selectedSecond = selectedSecond.previousYear
                    calcTime()
                }
                
                Spacer()
                
                // Month Back
                Button(action:
                {
                    selectedSecond = selectedSecond.previousMonth
                    calcTime()
                })
                {
                    Image(systemName: "arrowtriangle.backward.fill")
                }
                
                // Month today
                Button(action:
                {
                    selectedSecond = Clocks.system.currentSecond
                    calcTime()
                })
                {
                    Text("Today")
                }
                
                // month forward
                Button(action:
                {
                    selectedSecond = selectedSecond.nextMonth
                    calcTime()
                })
                {
                    Image(systemName: "arrowtriangle.forward.fill")
                }
            }
           
            
            // weekday name headers
            HStack
            {
                ForEach(weeks[0], id: \.self)
                { day in
                    Text(day.format(weekday: .abbreviatedName))
                        .fixedSize() // prevent the text from wrapping
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .font(.subheadline)
            
            Divider()
            
            // weeks
            ForEach(weeks, id: \.self) 
            { week in
                HStack
                {
                    ForEach(week, id: \.self) 
                    { theday in
                        Toggle(isOn: Binding(get: { selectedDay == theday },
                                             set: { _ in setdate(day:theday,month: monthName);calcTime() }))
                        {
                            Text(theday.format(day: .naturalDigits))
                                .fixedSize() // prevent the text from wrapping
                                .monospacedDigit()
                                .opacity(theday.month == selectedMonth.month ? 1.0 : 0.2)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .toggleStyle(DayToggleStyle())
                    }
                }
            }
        }
    }
    
   
    
}


struct DayToggleStyle: ToggleStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        Button(action: { configuration.$isOn.wrappedValue = !configuration.isOn })
        {
            configuration.label
                .foregroundStyle(configuration.isOn ? AnyShapeStyle(.selection) : AnyShapeStyle(.primary))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background 
        {
            if configuration.isOn 
            {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.accentColor)
            }
        }
    }
    
}

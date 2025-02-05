//
//  CalenderView.swift
//  timecalcUI
//
//  Created by Robert Dodson on 3/2/24.
//
import Foundation
import SwiftUI

import Time


struct CalenderView: View
{
    @Binding var selectedSecond : Fixed<Second>
    @Binding var monthName : String
    @Binding var region : Region
    
    var color : Color = Color(.controlTextColor)
    
    @State var selectedMonth : Fixed<Month> = Clocks.system.currentMonth
    @State var selectedDay : Fixed<Day> = Clocks.system.currentDay

    let consistentNumberOfWeeks = true
    
    
    var body: some View
    {
        VStack
        {
            calendarView
            ClockView(selectedSecond: $selectedSecond)
        }
        .onAppear()
        {
            update()
        }
        .onChange(of: selectedSecond) // changes from the differences view
        { oldValue, newValue in
            selectedSecond = newValue
            monthName = selectedSecond.format(month: .naturalName)
        }
    }
   
    
    
    func update()
    {
        selectedMonth = selectedSecond.fixedMonth
        monthName = selectedMonth.format(month:.naturalName)
        selectedDay = selectedSecond.fixedDay
    }
    
    
    func setdate(day:Fixed<Day>,month:String)
    {
        do
        {
            selectedSecond = try Fixed<Second>(region: region,
                                               year: selectedSecond.year,
                                               month: getMonthNum(month: month),
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
    
    
    func getMonthNum(month:String) -> Int
    {
        return selectedMonth.calendar.monthSymbols.firstIndex(of: month)! + 1
    }
    
    
    private var calendarView: some View
    {
        let weeks = self.weeksForCurrentMonth
        
        return VStack {
            
            // current month + movement controls
            HStack
            {
                // Month back
                Button(action:
                        {
                    selectedSecond = selectedSecond.previousMonth
                })
                {
                    Image(systemName: "arrowtriangle.backward.fill")
                }
                
                // month picker
                Picker("", selection: $monthName)
                {
                    ForEach(selectedMonth.calendar.monthSymbols,id:\.self)
                    { month in
                        Text("\(month)")
                            .foregroundColor(color)
                    }
                }
                .pickerStyle(.automatic)
                .frame(width: 120)
                .onChange(of: monthName)
                { oldValue, newValue in
                    setdate(day:selectedSecond.fixedDay,month: newValue)
                }
                
                // month forward
                Button(action:
                        {
                    selectedSecond = selectedSecond.nextMonth
                })
                {
                    Image(systemName: "arrowtriangle.forward.fill")
                }
                
                Spacer()
                
                // year stepper
                Stepper
                {
                    Text("\(selectedSecond.year.description)")
                        .foregroundColor(color)
                }
                onIncrement:
                {
                    selectedSecond = selectedSecond.nextYear
                }
                onDecrement:
                {
                    selectedSecond = selectedSecond.previousYear
                }
                
                Spacer()
                
                // day back
                Button(action:
                {
                    selectedSecond = selectedSecond.previousDay
                })
                {
                    Image(systemName: "arrowtriangle.backward.fill")
                }
                
                // today
                Button(action:
                {
                    selectedSecond = Clocks.custom(startingFrom:.init(date: .now),rate: 1.0,region: region).currentSecond    //Clocks.system.currentSecond
                })
                {
                    Text("Today")
                }
                
                // day forward
                Button(action:
                {
                    selectedSecond = selectedSecond.nextDay
                })
                {
                    Image(systemName: "arrowtriangle.forward.fill")
                }
            }
            .onChange(of: selectedSecond)
            { oldValue, newValue in
                update()
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
                                             set: { _ in setdate(day:theday, month:monthName);update() }))
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

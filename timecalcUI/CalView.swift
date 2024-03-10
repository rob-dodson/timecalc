//
//  CalendarView.swift
//  Examples
//

import Foundation
import SwiftUI
import Time

struct CalView: View 
{
    @Binding var selectedMonth : Fixed<Month>
    @Binding var selectedDay : Fixed<Day>
    @Binding var selectedSecond : Fixed<Second>
   
    var color : Color = Color.white
    
    @State var year : Int = 2000
    @State var month : String = "January"
    @State var day : String = "Sunday"
    @State var hour : Int = 0
    @State var minute : Int = 0
    @State var second : Int = 0
    @State var ampm : String = "am"
    @State var hour24 = true
    
    
    let hourrange12 = 1...12
    let hourrange24 = 0...23
    let minuterange = 0...59
    let secondrange = 0...59
    
    let consistentNumberOfWeeks = true
    
    var body: some View
    {
        VStack
        {
            calendarView
            clockView
            Spacer()
        }
        .onAppear()
        {
            year = selectedSecond.year
            day = selectedDay.dayOfMonth.description
            month = selectedMonth.format(month:.naturalName)
            hour = selectedSecond.hour
            minute = selectedSecond.minute
            second = selectedSecond.second
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
    
    
    private var clockView: some View
    {
                
        return HStack
        {
            Stepper(String(format:"%2d",hour), value: $hour, in: hour24 == true ? hourrange24 : hourrange12)
            {_ in
                calcTime()
            }
            
            Text(":")
            
            Stepper(String(format:"%02d",minute), value: $minute, in: minuterange)
            {_ in
                calcTime()
            }
            
            Text(":")
            
            Stepper(String(format:"%02d",second), value: $second, in: secondrange)
            {_ in
                calcTime()
            }
            
            Picker("", selection: $ampm)
            {
                Text("am")
                    .tag("am")
                Text("pm")
                    .tag("pm")
            }
            .pickerStyle(.automatic)
            .frame(width: 75)
            .onChange(of: ampm)
            { oldValue, newValue in
                calcTime()
            }
        }
    }
    
    
    func calcTime()
    {
        do
        {
            selectedSecond = try Fixed<Second>(region: .current,
                                               year: try Fixed<Year>(stringValue: String(year), rawFormat: "y", region: Region.current).year,
                                               month: try Fixed<Month>(stringValue: month, rawFormat: "MMMM", region: Region.current).month,
                                               day: try Fixed<Day>(stringValue: day, rawFormat: "d", region: Region.current).day,
                                               hour: hour,
                                               minute: minute,
                                               second: second)
            
            selectedMonth = selectedSecond.fixedMonth
            selectedDay = selectedSecond.fixedDay
        }
        catch
        {
            print("calcTime error: \(error)")
        }
    }
    
    
    private var calendarView: some View
    {
        let weeks = self.weeksForCurrentMonth
        
        return VStack {
            
            // current month + movement controls
            HStack
            {
                Picker("", selection: $month)
                {
                    ForEach(Calendar.current.monthSymbols, id: \.self)
                    { month in
                        Text("\(month)")
                            .foregroundColor(color)
                    }
                }
                .pickerStyle(.automatic)
                .frame(width: 120)
                .onChange(of: month) 
                { oldValue, newValue in
                    calcTime()
                }
                
                
                Stepper 
                {
                    Text("\(year.description)")
                        .foregroundColor(color)
                }
                onIncrement:
                {
                    year = year + 1
                    calcTime()
                }
                onDecrement:
                {
                    year = year - 1
                    calcTime()
                }
                
                Spacer()
                
                Button(action: 
                {
                    selectedMonth = selectedMonth.previous
                    year = selectedMonth.year
                    month = selectedMonth.format(month:.naturalName)
                    calcTime()
                })
                {
                    Image(systemName: "arrowtriangle.backward.fill")
                }
                
                Button(action: 
                {
                    selectedMonth = Clocks.system.currentMonth
                    selectedDay = Clocks.system.currentDay
               
                    year = Clocks.system.currentYear.year
                    month = selectedMonth.format(month:.naturalName)
                    day = String(selectedDay.dayOfMonth)
                    
                    calcTime()
                })
                {
                    Text("Today")
                }
                
                Button(action: 
                {
                    selectedMonth = selectedMonth.next
                    year = selectedMonth.year
                    month = selectedMonth.format(month:.naturalName)
                    calcTime()
                })
                {
                    Image(systemName: "arrowtriangle.forward.fill")
                }
            }
            .font(.headline)
            
            // weekday name headers
            HStack
            {
                ForEach(weeks[0], id: \.self) { day in
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
                                             set: { _ in selectedDay = theday; day = String(selectedDay.dayOfMonth);calcTime() }))
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

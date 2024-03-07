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
   
    var color : Color = Color.green
    
    @State var hours : String = ""
    @State var minutes : String = ""
    @State var seconds : String = ""
    
    
    let consistentNumberOfWeeks = true
    
    
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
            hours = selectedSecond.hour.formatted()
            minutes = selectedSecond.minute.formatted()
            seconds = selectedSecond.second.formatted()
        }
    }

    private var clockView: some View
    {
        return HStack
        {
            TextField("", text:$hours)
                .frame(width: 25)
                .disableAutocorrection(true)
                .onSubmit
            {
                calcTime()
            }
            
            
            Text(":")
            TextField("", text:$minutes)
                .frame(width: 25)
                .disableAutocorrection(true)
                .onSubmit
            {
                calcTime()
            }
            Text(":")
            TextField("", text:$seconds)
                .frame(width: 25)
                .disableAutocorrection(true)
                .onSubmit
            {
                calcTime()
            }
        }
    }
    
    func calcTime()
    {
        do
        {
            selectedSecond = try Fixed<Second>(region: .current,
                                               year: selectedMonth.year,
                                               month: selectedMonth.month,
                                               day: selectedDay.day,
                                               hour: try Fixed<Hour>(stringValue: hours, rawFormat: "hh", region: .current).hour,
                                               minute: try Fixed<Minute>(stringValue: minutes, rawFormat: "mm", region: .current).minute,
                                               second: try Fixed<Second>(stringValue: seconds, rawFormat: "ss", region: .current).second)
        }
        catch
        {
            print(error)
        }
    }
    
    private var calendarView: some View
    {
        let weeks = self.weeksForCurrentMonth
        
        return VStack {
            
            // current month + movement controls
            HStack
            {
                Text(selectedMonth.format(year: .naturalDigits, month: .naturalName))
                    .fixedSize() // prevent the text from wrapping
                    .foregroundColor(color)
                
                Spacer()
                
                Button(action: 
                {
                    selectedMonth = selectedMonth.previous
                })
                {
                    Image(systemName: "arrowtriangle.backward.fill")
                }
                
                Button(action: 
                {
                    selectedMonth = Clocks.system.currentMonth
                    selectedDay = Clocks.system.currentDay
                    calcTime()
                })
                {
                    Text("Today")
                }
                
                Button(action: { selectedMonth = selectedMonth.next })
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
                    { day in
                        Toggle(isOn: Binding(get: { selectedDay == day },
                                             set: { _ in selectedDay = day;calcTime() }))
                        {
                            Text(day.format(day: .naturalDigits))
                                .fixedSize() // prevent the text from wrapping
                                .monospacedDigit()
                                .opacity(day.month == selectedMonth.month ? 1.0 : 0.2)
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

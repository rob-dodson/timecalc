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
    
    @State var year : Int = 2000
    @State var month : String = ""
    @State var day : String = ""
    @State var hours : String = ""
    @State var minutes : String = ""
    @State var seconds : String = ""
    
    
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
            hours = selectedSecond.hour.formatted()
            minutes = selectedSecond.minute.formatted()
            seconds = selectedSecond.second.formatted()
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
                                               year: try Fixed<Year>(stringValue: String(year), rawFormat: "y", region: Region.current).year,
                                               month: try Fixed<Month>(stringValue: month, rawFormat: "MMMM", region: Region.current).month,
                                               day: try Fixed<Day>(stringValue: day, rawFormat: "d", region: Region.current).day,
                                               hour: try Fixed<Hour>(stringValue: hours, rawFormat: "hh", region: .current).hour,
                                               minute: try Fixed<Minute>(stringValue: minutes, rawFormat: "mm", region: .current).minute,
                                               second: try Fixed<Second>(stringValue: seconds, rawFormat: "ss", region: .current).second)
            selectedMonth = selectedSecond.fixedMonth
            selectedDay = selectedSecond.fixedDay
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
                Picker("", selection: $month)
                {
                    ForEach(Calendar.current.monthSymbols, id: \.self)
                    { month in
                        Text("\(month)")
                            .foregroundColor(color)
                    }
                }
                .pickerStyle(.automatic)
                .frame(width: 100)
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
                                             set: { _ in selectedDay = theday; calcTime() }))
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

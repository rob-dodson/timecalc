//
//  ClockPicker.swift
//  timecalcUI
//
//  ClocksView.swift
//  Examples
//

import Foundation
import SwiftUI
import Time

struct ClockPicker: View
{
    @Binding var calendar : Calendar
    @Binding var timeZone : TimeZone
    @Binding var locale : Locale
    @Binding var region : Region
    
    @State var now: Fixed<Second>?
    
    var clock: any RegionalClock
    {
        Clocks.system(in: region)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if let now {
                Text(now.format(date: .full))
                    .font(.title)
                
                Text(now.format(time: .long))
                    .font(.title)
                
                Divider()
            }
            
            Form {
                CalendarPicker(calendar: $calendar)
                TimeZonePicker(timeZone: $timeZone)
                LocalePicker(locale: $locale)
            }
            
            Spacer()
        }
        .onReceive(clock.strike(every: Second.self).publisher.receive(on: DispatchQueue.main), perform: { now = $0 })
        .font(.body)
        .foregroundColor(.white)
        .padding()
        .frame(width:350,alignment: .leading)
        .background()
        .cornerRadius(5.0)
    }
    
    
}

struct CalendarPicker: View {
    @Binding var calendar: Calendar
    
    let ids = [Calendar.Identifier.gregorian,
               .buddhist,
               .chinese,
               .coptic,
               .ethiopicAmeteMihret,
               .ethiopicAmeteAlem,
               .hebrew,
               .iso8601,
               .indian,
               .islamic,
               .islamicCivil,
               .japanese,
               .persian,
               .republicOfChina,
               .islamicTabular,
               .islamicUmmAlQura
    ]
    
    var body: some View {
        Picker("Calendar", selection: $calendar) {
            Text("System (\(Calendar.current.identifier.debugDescription))")
                .tag(Calendar.current)
            
            ForEach(ids, id: \.self) { calendarID in
                Text("\(calendarID.debugDescription)")
                    .tag(Calendar(identifier: calendarID))
            }
        }
    }
}

struct TimeZonePicker: View {
    
    @Binding var timeZone: TimeZone
    
    var body: some View {
        
        Picker("Time Zone", selection: $timeZone) {
            Text("System (\(TimeZone.current.description))")
                .tag(TimeZone.current)
            
            ForEach(TimeZone.knownTimeZoneIdentifiers.sorted(by: <), id: \.self) { id in
                Text(id)
                    .tag(TimeZone(identifier: id)!)
            }
        }
        
    }
    
}

struct LocalePicker: View {
    
    @Binding var locale: Locale
    
    var body: some View {
        
        Picker("Locale", selection: $locale) {
            Text("System (\(Locale.current.description))")
                .tag(Locale.current)
            
            ForEach(Locale.availableIdentifiers.sorted(by: <), id: \.self) { id in
                Text(Locale.current.localizedString(forIdentifier: id) ?? id)
                    .tag(Locale(identifier: id))
            }
        }
        
    }
}

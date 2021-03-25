//
//  ContentView.swift
//  BeaFiftyCalChallenge
//
//  Created by Sabrina Bea on 3/21/21.
//

import SwiftUI

struct ContentView: View {
    @State var daySlideEdge: Edge = .leading
    @State var day = Date.practicalToday()
    
    var canGoRight: Bool {
        return day < Date.practicalToday()
    }
    
    var body: some View {
        VStack {
            // Begin Date header
            HStack {
                Spacer()
                Image(systemName: "chevron.left")
                    .padding(.leading, 50)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        daySlideEdge = .leading
                        withAnimation {
                            day = day.addDays(-1).noon
                        }
                    }
                    .accessibility(identifier: "Previous Week")
                
                
                Text(day.formatted())
                    .foregroundColor(.primary)
                    .accessibility(identifier: "Date Label")
                
                Image(systemName: "chevron.right")
                    .foregroundColor(canGoRight ? .primary : .secondary)
                    .padding(.trailing, 50)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if canGoRight {
                            // Using jumpTo causes the date to be scrolled into view
                            daySlideEdge = .trailing
                            withAnimation {
                                day = day.addDays(1).noon
                            }
                        }
                    }
                    .accessibility(identifier: "Next Week")
                Spacer()
            }
            .font(.headline)
            .padding(.top)
            
            DayView(day: $day)
                .transition(.asymmetric(insertion: .move(edge: daySlideEdge), removal: .move(edge: daySlideEdge == .leading ? .trailing : .leading)))
                .padding(.top)
        
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

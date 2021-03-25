//
//  DayView.swift
//  BeaFiftyCalChallenge
//
//  Created by Sabrina Bea on 3/21/21.
//

import SwiftUI

struct DayView: View {
    @EnvironmentObject var model: AppModel
    @Binding var day: Date
    
    var entry: Binding<Entry> {
        if let idx = model.index(for: day) {
            return $model.entries[idx]
        }
        print("Failed to find or create day")
        exit(1) // This shouldn't happen
    }
    
    var fullStr: String {
        if entry.wrappedValue.goal > 0 || entry.wrappedValue.calories > 0 {
            return "\(entry.wrappedValue.calories) / \(entry.wrappedValue.goal)"
        } else {
            return "No Data For Day"
        }
    }
    
    var body: some View {
        VStack {
            Text(fullStr)
                .font(.system(size: 60))
                .contextMenu(menuItems: {
                    Button("Recalculate Goal", action: {
                        entry.wrappedValue.goal = model.computeGoal(for: entry.wrappedValue.date)
                    })
                })
            Spacer()
            HStack {
                Image(systemName: "minus.circle.fill")
                    .padding()
                    .onTapGesture {
                        if entry.wrappedValue.calories >= 50 {
                            entry.wrappedValue.calories -= 50
                        }
                    }
                Image(systemName: "plus.circle.fill")
                    .padding()
                    .onTapGesture {
                        entry.wrappedValue.calories += 50
                    }
            }
            .font(.system(size: 80))
            .padding(.bottom, 50)
        }
    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DayView(day: .constant(Date()))
                .environmentObject(AppModel())
                .padding(.top, 50)
            Spacer()
        }
    }
}

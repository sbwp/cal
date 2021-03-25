//
//  AppModel.swift
//  BeaFiftyCalChallenge
//
//  Created by Sabrina Bea on 3/21/21.
//

import Foundation
import Combine

class AppModel: ObservableObject {
    @Published var entries: [Entry]
    var database = Database()!
    var cancellables = Set<AnyCancellable>()
    
    init() {
        entries = database.load()
        
        $entries
            .pairwise()
            .sink { [database] (old, new) in
                // Assumes only one change was made
                // Since creating/deleting is done through functions, only run if count is the same
                if new.count == old.count {
                    for entryIndex in old.indices {
                        if !Entry.propertiesEqual(old[entryIndex], new[entryIndex]) {
                            database.update(new[entryIndex])
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func index(for date: Date, create: Bool = true) -> Int? {
        if let idx = entries.firstIndex(where: {$0.date.isSameDay(as: date)}) {
            return idx
        } else {
            return create ? createEntry(date: date) : nil
        }
    }
    
    // Returns index of created entry or nil if unsuccessful
    func createEntry(date: Date, goal: Int64? = nil) -> Int? {
        if let entry = database.createEntry(date: date, goal: computeGoal(for: date, overrideGoal: goal)) {
            entries.append(entry)
            return entries.count - 1
        }
        print("failed to create entry for \(date.formatted())")
        return nil
    }
    
    func computeGoal(for date: Date, overrideGoal: Int64? = nil) -> Int64 {
        var goal: Int64
        
        if let overrideGoal = overrideGoal {
            goal = overrideGoal
        } else {
            var total = Int64(0)
            var count = Int64(0)
            for i in 1..<10 {
                if let idx = index(for: date.addDays(-i), create: false), entries[idx].calories > 0  {
                    count += 1
                    total += entries[idx].calories
                }
            }
            goal = count > 0 ? total / count : 100
        }
        
        var calculatedGoal = max(goal, 100)
        let remainder = calculatedGoal % 50
        if remainder >= 25 {
            calculatedGoal += 50
        }
        return calculatedGoal - remainder
    }
    
}

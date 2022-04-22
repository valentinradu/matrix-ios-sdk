// 
// Copyright 2022 The Matrix.org Foundation C.I.C
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// MXBeaconInfoSummary memory store
public class MXBeaconInfoSummaryMemoryStore: NSObject, MXBeaconInfoSummaryStoreProtocol {
    
    // MARK: - Properties
    
    private var beaconInfoSummaries: [String: [MXBeaconInfoSummary]] = [:]
    
    // MARK: - Public
    
    public func addOrUpdateBeaconInfoSummary(_ beaconInfoSummary: MXBeaconInfoSummary, inRoomWithId roomId: String) {
        
        var beaconInfoSummaries: [MXBeaconInfoSummary] = self.beaconInfoSummaries[roomId] ?? []
        
        let existingIndex = beaconInfoSummaries.firstIndex { summary in
            return summary.identifier == beaconInfoSummary.identifier
        }
        
        if let existingIndex = existingIndex {
            beaconInfoSummaries.insert(beaconInfoSummary, at: existingIndex)
        } else {
            beaconInfoSummaries.append(beaconInfoSummary)
        }
        
        self.beaconInfoSummaries[roomId] = beaconInfoSummaries
    }
    
    public func getBeaconInfoSummary(withIdentifier identifier: String, inRoomWithId roomId: String) -> MXBeaconInfoSummary? {
        guard let roomBeaconInfoSummaries = self.beaconInfoSummaries[roomId] else {
            return nil
        }
        
        return roomBeaconInfoSummaries.first { beaconInfoSummary in
            return beaconInfoSummary.identifier == identifier
        }
    }
    
    public func deleteAllBeaconInfoSummaries(inRoomWithId roomId: String) {
        self.beaconInfoSummaries[roomId] = nil
    }
    
    public func deleteAllBeaconInfoSummaries() {
        self.beaconInfoSummaries = [:]
    }
}


//
//  PumpManagerUI.swift
//  Loop
//
//  Created by Pete Schwamb on 10/18/18.
//  Copyright © 2018 LoopKit Authors. All rights reserved.
//

import Foundation
import LoopKitUI


let allPumpManagerUIs = Bundle.linkedPumpManagerUIs

private let managersByIdentifier: [String: PumpManagerUI.Type] = allPumpManagerUIs.reduce(into: [:]) { (map, Type) in
    map[Type.managerIdentifier] = Type
}

func PumpManagerUITypeFromRawValue(_ rawValue: [String: Any]) -> PumpManagerUI.Type? {
    guard let managerIdentifier = rawValue["managerIdentifier"] as? String else {
        return nil
    }
    
    return managersByIdentifier[managerIdentifier]
}

func PumpManagerHUDViewsFromRawValue(_ rawValue: [String: Any]) -> [BaseHUDView]? {
    guard let rawState = rawValue["hudProviderViews"] as? HUDProvider.HUDViewsRawState,
        let Manager = PumpManagerUITypeFromRawValue(rawValue)
        else {
            return nil
    }
    
    return Manager.createHUDViews(rawValue: rawState)
}

extension HUDProvider {
    var rawHUDProviderViewsValue: [String: Any] {
        return [
            "managerIdentifier": self.managerIdentifier,
            "hudProviderViews": self.hudViewsRawState
        ]
    }
}



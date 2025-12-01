//
//  File.swift
//  ClientApp
//
//  Created by Jordi Pereira Gil on 24/11/25.
//

import Foundation

enum CarStatus {
    case inGarage
    case leavingRequested
    case exitingGarage
    case leavingCancelled
    case storingCancelled
    case waitingPickup
    case storingRequested
    case toGarage
    case outside
    case unavailable

    var text: String {
        switch self {
        case .inGarage:
            return NSLocalizedString("In garage", comment: "in garage key")
        case .leavingRequested:
            return NSLocalizedString("Leaving requested", comment: "leaving requested key")
        case .exitingGarage:
            return NSLocalizedString("leaving the garage", comment: "leaving the garage")
        case .leavingCancelled:
            return NSLocalizedString("Leaving cancelled", comment: "leaving cancel key")
        case .storingCancelled:
            return NSLocalizedString("Storing cancelled", comment: "storing cancel key")
        case .waitingPickup:
            return NSLocalizedString("Waiting pickup", comment: "waiting pick up key")
        case .storingRequested:
            return NSLocalizedString("Storing requested", comment: "storing requested key")
        case .toGarage:
            return NSLocalizedString("Taking to the garage", comment: "to garage key")
        case .outside:
            return NSLocalizedString("Outside", comment: "outside key")
        case .unavailable:
            return NSLocalizedString("Unavailable", comment: "unavailable key")
        }

    }

    var value: String {
        switch self {
        case .inGarage:
            return "in_garage"
        case .leavingRequested:
            return "leaving_requested"
        case .exitingGarage:
            return "exiting_garage"
        case .leavingCancelled:
            return "leaving_cancelled"
        case .storingCancelled:
            return "storing_cancelled"
        case .waitingPickup:
            return "waiting_pickup"
        case .storingRequested:
            return "storing_requested"
        case .toGarage:
            return "to_garage"
        case .outside:
            return "outside"
        case .unavailable:
            return "unavailable"
        }

    }

    var buttonText: String {
        switch self {
        case .leavingRequested, .storingRequested: return "Accept Request"
        case .exitingGarage, .storingCancelled: return "Wait for owner"
        case .waitingPickup: return "Picked up"
        case .toGarage, .leavingCancelled: return "In garage"
        default: return ""
        }
    }

    var nextStatus: CarStatus {
        switch self {
        case .leavingRequested: .exitingGarage
        case .exitingGarage, .storingCancelled: .waitingPickup
        case .storingRequested: .toGarage
        case .toGarage, .leavingCancelled: .inGarage
        case .waitingPickup: .outside
        default: .unavailable
        }
    }

    func statusHaveToDismmiss() -> Bool {
        [.outside, .inGarage].contains(self)
    }




    static func getCarStatus(status: String) -> CarStatus {
        switch status {
        case "in_garage":
                return .inGarage
        case "leaving_requested":
            return .leavingRequested
        case "exiting_garage":
            return .exitingGarage
        case "leaving_cancelled":
            return .leavingCancelled
        case "storing_cancelled":
            return .storingCancelled
        case "waiting_pickup":
            return .waitingPickup
        case "storing_requested":
            return .storingRequested
        case "to_garage":
            return .toGarage
        case "outside":
            return .outside
        case "unavailable":
            return .unavailable
        default:
            return .unavailable
        }
    }

    
}

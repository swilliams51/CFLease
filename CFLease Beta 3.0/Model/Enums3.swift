//
//  Enums3.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 12/1/21.
//

import Foundation

enum DayCountMethod {
    case Thirty_ThreeSixty_ConvUS
    case Actual_ThreeSixtyFive
    case Actual_Actual
    case Actual_ThreeSixty
    
    func toString() -> String {
        switch self {
        case .Thirty_ThreeSixty_ConvUS:
            return "30/360"
        case .Actual_ThreeSixtyFive:
            return "Actual/365"
        case .Actual_Actual:
            return "Actual/Actual"
        case .Actual_ThreeSixty:
            return "Actual/360"
        }
    }
    
    static let dayCountMethods: [DayCountMethod] = [.Thirty_ThreeSixty_ConvUS, .Actual_ThreeSixtyFive, .Actual_Actual, .Actual_ThreeSixty]
}

extension String {
    func toDayCountMethod () -> DayCountMethod {
        switch self {
        case "30/360":
            return .Thirty_ThreeSixty_ConvUS
        case "Actual/365":
            return .Actual_ThreeSixtyFive
        case "Actual/Actual":
            return .Actual_Actual
        case "Actual/360":
            return .Actual_ThreeSixty
        default:
            return DayCountMethod.Actual_ThreeSixty
        }
    }
}

enum Frequency: Int, CaseIterable {
    case monthly = 12
    case quarterly = 4
    case semiannual = 2
    case annual = 1
    
    func toString () -> String {
        switch self {
        case .monthly:
            return "Monthly"
        case .quarterly:
            return "Quarterly"
        case .semiannual:
            return "Semiannual"
        case .annual:
            return "Annual"
        }
        
    }
    
    static let three: [Frequency] = [.monthly, .quarterly, .semiannual]
    static let two: [Frequency] = [.monthly, .quarterly]
    static let one: [Frequency] = [.monthly]
}

extension String {
    func toFrequency () -> Frequency {
        switch self {
        case "Monthly":
            return .monthly
        case "Quarterly":
            return .quarterly
        case "Semiannual":
            return .semiannual
        case "Annual":
            return .annual
        default:
            return .monthly
        }
    }
}

enum MaximumBaseTerm: Int {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    
    func toString() -> String {
        switch self {
        case .one:
            return "120"
        case .two:
            return "132"
        case .three:
            return "144"
        case .four:
            return "156"
        case .five:
            return "168"
        default:
            return "180"
        }
    }
}

extension String {
    func toMaximumBaseTerm() -> MaximumBaseTerm {
        switch self {
        case "120":
            return MaximumBaseTerm.one
        case "132":
            return MaximumBaseTerm.two
        case "144":
            return MaximumBaseTerm.three
        case "156":
            return MaximumBaseTerm.four
        case "168":
            return MaximumBaseTerm.five
        default:
            return MaximumBaseTerm.six
            
        }
    }
}


enum PaymentType: CaseIterable {
    case balloon
    case deAll
    case deNext
    case funding
    case interest
    case payment
    case principal
    case residual
    
    func toString() -> String {
        switch self {
        case .balloon:
            return "Balloon"
        case .deAll:
            return "DeAll"
        case .deNext:
            return "DeNext"
        case .funding:
            return "Funding"
        case .interest:
            return "Interest"
        case .payment:
            return "Payment"
        case .principal:
            return "Principal"
        case .residual:
            return "Residual"
        }
    }
    
    static let allPayments: [PaymentType] = [.balloon, .deAll, .deAll, .interest, .payment, .principal, .residual]
    
    static let interimTypes:[PaymentType] =  [.deNext, .deAll, .interest, .payment, .principal]
    
    static let residualTypes: [PaymentType] = [.balloon, .interest, .payment, .principal, .residual]
    
    static let defaultTypes: [PaymentType] = [.interest, .payment, .principal]
}

extension String {
    func stringToPaymentType () -> PaymentType {
        switch self {
        case "Balloon":
            return PaymentType.balloon
        case "DeAll":
            return PaymentType.deAll
        case "DeNext":
            return PaymentType.deNext
        case "Funding":
            return PaymentType.funding
        case "Interest":
            return PaymentType.interest
        case "Payment":
            return PaymentType.payment
        case "Principal":
            return PaymentType.principal
        case "Residual":
            return PaymentType.residual
        default:
            return PaymentType.payment
        }
    }
}

enum PaymentTiming {
    case all
    case advance
    case arrears
    case equals
    
    static let residualCases: [PaymentTiming] = [.equals]
    static let interestCases: [PaymentTiming] = [.arrears]
    static let paymentCases: [PaymentTiming] = [.advance, .arrears]
    static let allCases: [PaymentTiming] = [.advance, .arrears, .equals]
    
    func toString () -> String {
        switch self {
        case .advance:
            return "Advance"
        case .arrears:
            return "Arrears"
        default:
            return "Equals"
        
        }
    }
}

extension String {
    func stringToPaymentTiming() -> PaymentTiming {
        switch self {
        case "Advance":
            return .advance
        case "Arrears":
            return .arrears
        default:
            return .equals
        }
    }
}

enum eboPremiumType {
    case specified
    case calculated
    
    func toString() -> String {
        switch self {
        case .specified:
            return "Specified"
        case .calculated:
            return "Calculated"
        }
    }
}

extension String {
    func toEBOPremiumType() -> eboPremiumType {
        switch self {
        case "Specified":
            return .specified
        case "Calculated" :
            return .calculated
        default:
            return .specified
        }
    }
}



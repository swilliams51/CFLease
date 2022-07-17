//
//  Help.swift
//  CFLease Beta 3.0
//
//  Created by Steven Williams on 2/17/22.
//

import Foundation

struct Help {
    let title: String
    let instruction: String
}

let paymentAmountHelp: Help =
    Help(title: "Payment Amount", instruction: "A valid payment amount must be a decimal equal to or greater than 0.00 and less than the Lease Amount. Any decimal amount entered less than 1.00 will be interpretted as a percent of Lease Amount.  For example, if the Lease Amount is 100,000.00 then an entry of 0.015 will be converted into an entry of 1,500.00.")

let cutOffHelp: Help =
    Help(title: "Cut-Off Date", instruction: "A new Lease will be created from the payment groups of the existing Lease that occur on and after the cut-off date as selected by the user. If an EBO exists in the current Lease it will also be included in the new Lease. The ideal application for the Cut-Off method is the purchase of a seasoned lease out of portfolio.")

let escalationRateHelp =
    Help(title: "Escalation Rate", instruction: "The total number of payments for the starting group must be even divisible by 12. The resulting escalated payment structure will be a series of consecutive annual payment groups in which the total annual payment amount for each payment group is greater than the previous group by the amount of the escalation rate.")

let purchaseHelp =
    Help(title: "Buy/Sell", instruction: "Enter the buy rate and the program will solve for the amount fee to be paid by the purchaser of the Lease.  Alternatively, the fee paid may be entered and the program will solve for the purchaser's buy rate after payment of the fee.  To remove the purchase fee from the investment enter 0.00 for fee or set the buy rate equal to the Lease interest rate.")

let eboHelp =
    Help(title: "Early Buyout", instruction: "The EBO exercise date must occur on or before one year prior to the Lease's maturity date but no earlier than the first anniversary date of the Lease.  The amount of the EBO must greater than the par value of the Lease on the EBO exercise date but less than ore equal to the Lease Amount.  To remove an Early Buyout Option from the investment set the amount of the EBO equal to the par value of the Lease on that date as shown above.")

let baseTermStepperHelp =
    Help(title: "Base Term Stepper", instruction: "The base term stepper is meant for making minor adjustments to the base term. It is disabled when there are two or more payment groups with more than one payment. The preferred method of setting the base term is by changing the number of payments in the payment group details screen.")

let implicitRateHelp =
    Help(title: "Implicit Rate Help", instruction: "The implicit rate is the discount rate that equates the present value of the minimum lease payments and the unguaranteed residual value to the Lease Amount as of the Lease funding date. Any fee that the lessee is required to make in connection with the Lease is considered part of the minimum lease payments.")

let discountRateHelp =
    Help(title: "Specified Rate Help", instruction: "For accounting purposes the specified rate should be equal to the Lessse's Incremental Borrowing Rate (IBR) in order properly calculate the present value of minimum rents.  The discount rate used to present value the minimum rents should properly be the lower of the specified rate or the Implicit Rate.  However, the user must make the election.")

let defaultNewHelp =
    Help(title: "Default New Lease", instruction: "The default New lease parameters can be set to those specified by the user. First, create the preferred lease structure.  Then return to Preferences and switch \"use saved\"  to on and switch \"save current\" to on. Thereafter, when New is selected from the Side Menu the user's saved parameters will be loaded.  The default New lease parameters can be reset to the original by turning off those same switches.")

let eomRuleHelp =
    Help(title: "End of Month Rule", instruction: "If the base term commencement date starts on last day of a month with 30 days and the rule is on then the payment due dates for the months with 31 days will occur on the 31st of the applicable month.  If the rule is off then payment due dates for the months with 31 days will occur on the 30th.")

let baseTermHelp =
    Help(title: "Base Term Start Date", instruction: "The date when the periodic lease payments commence.  If the base term start date occurs after the funding date then an interim term will be created and one nonperiodic lease payment will added to the payments schedule. To remove an interim payment set the base start date to the funding date. For a monthly payment frequency tyhe base start date cannot occur more than 90 days after the funding date. For all other payment frequencies the interim term cannot exceed the number of days in the payment frequency.")

let solveForTermHelp =
    Help(title: "Solver For Term", instruction: "In order for the Solve For Term option to be available there must be only one unlocked payment group.  Additionally, the number of payments for that group must greater than the minimum number allowed and less then the maximum number allowed. Finally, the payment type for that group cannot be an interest only payment.")

let leaseBalanceHelp =
    Help(title: "Lease Balance Help", instruction: "The effective date can be any date occuring on or after the funding date and before the maturity date. Upon clicking the done button an amortization report is available for the lease through the effective date. Any subsequent recalculation of the lease will reset the lease balance amortization to nil.")

let exportFileHelp =
    Help(title: "Export File Help", instruction: "When the export action is turned on, the above selected file can be exported to iCloud or another such location specified by the user.  Once located on the iCloud drive the file may shared with other users of CFLease.")

let importFileHelp =
    Help(title: "Import File Help", instruction: "When the import action is turned on, a valid CFLease data file can be imported iCloud or another such location.  After importing, select File Save As from the Side Menu to save the file for local access.")

let importExportHelp =
    Help(title: "Import Export Help", instruction: "The importing and exporting of CFLease data files provide the user with additional storage space and the ability to share data files with other CFLease users. Both capabilities are best achieved by using iCloud.")

let renameHelp =
    Help(title: "Rename Help", instruction: "In order to rename a file, the renaming section must be active, the current name of the file must exist in the collection, the new file name must not exist in the collection and must be a valid file name.")

//
// NotificationKey.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//

///  Defines a notification at a given percentage.
///
///  - invalid:         Not a valid notification percentage.
///  - fivePercent:     Notify the user at five percent remaining charge.
///  - tenPercent:      Notify the user at ten percent remaining charge.
///  - fifeteenPercent: Notify the user at fifetenn percent remaining charge.
///  - twentyPercent:   Notify the user at twenty percent remaining charge.
///  - hundredPercent:  Notify the user when the battery is fully charged.
enum NotificationKey: Int {
    case invalid         = 0
    case fivePercent     = 5
    case tenPercent      = 10
    case fifeteenPercent = 15
    case twentyPercent   = 20
    case fortyPercent   = 40
    case eightyPercent   = 80
    case hundredPercent  = 100
}

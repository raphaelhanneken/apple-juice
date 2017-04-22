//
// NotificationKey.swift
// Apple Juice
// https://github.com/raphaelhanneken/apple-juice
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Raphael Hanneken
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
    case hundredPercent  = 100
}

//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// StackDemoApp
// Created by: Ryan Mckinney on 12/27/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation

//#if os(macOS)
import Foundation
import SwiftUI

@_exported import SwiftUI


@main
struct StackDemoApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .frame(maxHeight: .infinity)
        }
    }
}

//#endif

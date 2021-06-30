//
//  FirebaseCodableDemoApp.swift
//  FirebaseCodableDemo
//
//  Created by Yusuke Hasegawa on 2021/06/24.
//

import SwiftUI
import FirebaseCore

@main
struct FirebaseCodableDemoApp: App {
    
    init() {
        //setup firebase
        FirebaseApp.configure()
                        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

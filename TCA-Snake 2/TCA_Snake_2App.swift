//
//  TCA_Snake_2App.swift
//  TCA-Snake 2
//
//  Created by Peter Larson on 4/3/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCA_Snake_2App: App {
    var body: some Scene {
        WindowGroup {            
            ContentView(
                store: StoreOf<Snake>(
                    initialState: Snake.State(),
                    reducer: Snake()
                )
            )
        }
    }
}

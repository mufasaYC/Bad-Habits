//
//  AppState.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import Foundation

@Observable
final class AppState {
    static let shared: AppState = .init()
    
    var sheet: Sheet? = nil
    
    private init() { }
}

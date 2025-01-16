//
//  Sheet.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import SwiftUI

enum Sheet: Identifiable {
    case create(CreateView.Item)
    case update(UpdateView.Item)
    
    var id: String {
        switch self {
            case .create(let item):
                return item.id
            case .update(let item):
                return item.id
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
            case .create(let item):
                CreateView(item: item)
            case .update(let item):
                UpdateView(item: item)
        }
    }
}

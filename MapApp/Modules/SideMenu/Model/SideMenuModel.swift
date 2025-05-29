//
//  SideMenuModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//

enum SideMenuOption: CaseIterable {
    case map
    case list
    case info

    var title: String {
        switch self {
        case .map: return "Map"
        case .list: return "List"
        case .info: return "Info"
        }
    }

    var iconName: String {
        switch self {
        case .map: return "map"
        case .list: return "list.bullet"
        case .info: return "info.circle"
        }
    }
}

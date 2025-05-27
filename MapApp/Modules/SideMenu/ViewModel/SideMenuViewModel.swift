//
//  SideMenuViewModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//

class SideMenuViewModel {
    var onOptionSelected: ((SideMenuOption) -> Void)?
    let options = SideMenuOption.allCases

    func selectOption(at index: Int) {
        let option = options[index]
        onOptionSelected?(option)
    }
}

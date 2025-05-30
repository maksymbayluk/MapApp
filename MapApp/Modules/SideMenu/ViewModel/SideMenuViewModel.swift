//
//  SideMenuViewModel.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//

//view model class that manages the data and interaction logic for the side menu
class SideMenuViewModel {
    //selection callback
    var onOptionSelected: ((SideMenuOption) -> Void)?
    //list of all availabled options for menu
    let options = SideMenuOption.allCases

    func selectOption(at index: Int) {
        let option = options[index]
        onOptionSelected?(option)
    }
}

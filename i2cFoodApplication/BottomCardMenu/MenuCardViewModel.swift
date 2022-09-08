//
//  MenuCardViewModel.swift
//  i2cFoodApplication
//
//  Created by Muhammad Ahmar Hassan  on 02/09/2022.
//

import Foundation
import Combine

protocol MenuCardViewModelType: ObservableObject {
    var foodMenu: Food? { get set }
    var segmentSelection: Int { get set }
    var headerText: String { get set }
    var firstSectionHeader: String { get set }
    var upcomingLunchMenus: [Food] {get set }
    var upcomingDinnerMenus: [Food] { get set }
}

final class MenuCardViewModel: MenuCardViewModelType {
    
    
    @Published
    var firstSectionHeader: String = "Lunch"

    @Published
    var headerText: String = ""
    
    //MARK:- Outputs
    @Published var foodMenu: Food?
    @Published var segmentSelection: Int = 0
    
    private var lunchMenu: Food?
    private var dinnerMenu: Food?
    @Published var upcomingLunchMenus: [Food] = []
    @Published var upcomingDinnerMenus: [Food] = []
    var food: [Food] = []
    private var subscriptions: [AnyCancellable] = []
    private let service: FoodMenuServiceType
    
    init(service: FoodMenuServiceType) {
        self.service = service
        self.headerText = getHeaderText()
        
        requestLunch()
        requestDinner()
        
        $segmentSelection.sink {[weak self] valueß in
            guard let self = self else { return }
            self.foodMenu = valueß == 0 ? self.lunchMenu : self.dinnerMenu
            self.firstSectionHeader = valueß == 0 ? "Lunch Menu" : "Dinner Menu"
        }.store(in: &subscriptions)
    }
    
    private func getHeaderText() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        return "Food For Today " + formatter.string(from: currentDateTime) + " is : "
    }
    
    
}

private extension MenuCardViewModel {
    
    func requestLunch() {
        self.service.getLunchMenu().receive(on: RunLoop.main).sink { error in
            print(error)
        } receiveValue: {[weak self] menu in
            guard let self = self else { return }
            self.upcomingLunchMenus = self.getFoodForTheWeek(menu: menu)
            self.lunchMenu = self.getTodaysFood(foodMenu: menu)
            self.foodMenu = self.lunchMenu
        }.store(in: &subscriptions)
    }
    
    func requestDinner() {
        self.service.getDinnerMenu().receive(on: RunLoop.main).sink { error in
            print(error)
        } receiveValue: {[weak self] menu in
            guard let self = self else { return }
            self.upcomingDinnerMenus = self.getFoodForTheWeek(menu: menu)
            self.dinnerMenu = self.getTodaysFood(foodMenu: menu)
        }.store(in: &subscriptions)
    }
    
    func getTodaysFood(foodMenu: FoodMenu) -> Food {
        foodMenu.food.filter { $0.date.dateFromString().isToday }.first ?? Food(date: "None", day: "None", mainDish: "", sideDish: "", sweet: "")
    }
}

extension MenuCardViewModel {
    
    func getFoodForTheWeek(menu: FoodMenu)-> [Food] {
        return menu.food.filter { $0.date.dateFromString().isDateInTheFuture }
    }
}

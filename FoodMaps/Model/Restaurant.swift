//
//  Restaurant.swift
//  FoodMaps
//
//  Created by Hemg on 10/11/23.
//

struct RestaurantItem {
    var restaurant: Restaurant
    var poiItem: MTMapPOIItem
}

struct Restaurant {
    var title: String
    var description: String
    var category: RestaurantCategory
}

enum RestaurantCategory: String, CaseIterable {
    case korean = "한식"
    case japanese = "일식"
    case chinese = "중식"
    case western = "양식"
}

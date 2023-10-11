//
//  Restaurant.swift
//  FoodMaps
//
//  Created by Hemg on 10/11/23.
//

struct Restaurant {
    var title: String
    var description: String
}

struct RestaurantItem {
    var restaurant: Restaurant
    var poiItem: MTMapPOIItem
}

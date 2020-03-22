import Vapor

enum FoodType: String, Codable, CaseIterable {
    
    case mealPickup
    case mealJoin
    case ingredientsSet
    case ingredient
}

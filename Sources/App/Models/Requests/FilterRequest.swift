import Vapor

struct FilterRequest: Content {
    
    let type: FoodType?
}

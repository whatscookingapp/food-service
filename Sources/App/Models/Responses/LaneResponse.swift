import Vapor

struct LaneResponse: Content {
    
    let type: FoodType
    let items: [FoodOverviewResponse]
}

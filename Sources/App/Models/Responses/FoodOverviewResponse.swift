import Vapor

struct FoodOverviewResponse: Content {
    
    let id: UUID
    let title: String
    let creator: UserResponse
    let distance: Double?
    let image: ImageResponse?
    let createdAt: Date?
    
    init(food: Food, lat: Double?, lon: Double?, imageTransformer: ImageTransformer) throws {
        self.id = try food.requireID()
        self.title = food.title
        self.creator = try UserResponse(user: food.creator, imageTransformer: imageTransformer)
        if let inputLat = lat, let inputLon = lon, let foodLat = food.lat, let foodLon = food.lon {
            self.distance = Double.distance(lat1: inputLat, lon1: inputLon, lat2: foodLat, lon2: foodLon)
        } else {
            self.distance = nil
        }
        if let bucket = food.image?.bucket, let key = food.image?.key {
            self.image = try imageTransformer.transform(bucket: bucket, key: key)
        } else {
            self.image = nil
        }
        self.createdAt = food.createdAt
    }
}

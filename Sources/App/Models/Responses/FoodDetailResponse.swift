import Vapor

struct FoodDetailResponse: Content {
    
    let id: UUID
    let title: String
    let description: String?
    let creator: UserResponse
    let isCreator: Bool
    let status: ParticipantStatus
    let distance: Double?
    let lat: Double?
    let lon: Double?
    let image: ImageResponse?
    let createdAt: Date?
    
    init(food: Food, participant: Participant?, userID: UUID?, lat: Double?, lon: Double?, imageTransformer: ImageTransformer) throws {
        self.id = try food.requireID()
        self.title = food.title
        self.description = food.description
        self.creator = try UserResponse(user: food.creator)
        let isCreator = food.$creator.id == userID
        self.isCreator = isCreator
        if let approved = participant?.approved {
            self.status = approved ? .approved : .declined
        } else {
            self.status = .unknown
        }
        if let inputLat = lat, let inputLon = lon, let foodLat = food.lat, let foodLon = food.lon {
            self.distance = Double.distance(lat1: inputLat, lon1: inputLon, lat2: foodLat, lon2: foodLon)
        } else {
            self.distance = nil
        }
        if !food.showDistance || isCreator {
            self.lat = food.lat
            self.lon = food.lon
        } else {
            self.lat = nil
            self.lon = nil
        }
        let image = try food.joined(Image.self)
        if let bucket = image.bucket, let key = image.key {
            self.image = try imageTransformer.transform(bucket: bucket, key: key)
        } else {
            self.image = nil
        }
        self.createdAt = food.createdAt
    }
}

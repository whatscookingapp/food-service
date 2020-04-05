import Vapor
import FluentPostgresDriver

protocol FoodRepository {
    
    func queryPaginated(filters: FilterRequest, sorting: Sorting, lat: Double?, lon: Double?, language: String, on req: Request) -> EventLoopFuture<Page<Food>>
    func query(type: FoodType?, limit: Int, on req: Request) -> EventLoopFuture<[Food]>
    func find(id: UUID, on req: Request) -> EventLoopFuture<Food?>
    func findComplete(id: UUID, on req: Request) -> EventLoopFuture<Food?>
    func save(food: Food, on req: Request) -> EventLoopFuture<Food>
    func delete(food: Food, on req: Request) -> EventLoopFuture<Void>
}

struct FoodRepositoryImpl: FoodRepository {
    
    func queryPaginated(filters: FilterRequest, sorting: Sorting, lat: Double?, lon: Double?, language: String, on req: Request) -> EventLoopFuture<Page<Food>> {
        if filters.distance != nil {
            guard lat != nil, lon != nil else {
                return req.eventLoop.makeFailedFuture(Abort(.badRequest))
            }
        }
        var query = Food.query(on: req.db).group(.or) { filter in
            filters.types.forEach {
                filter.filter(\.$type == .enumCase($0.rawValue))
            }
        }
        .group(.and) { filter in
            if let slots = filters.slots {
                filter.filter(\.$slots >= slots)
            }
            if let minimumDate = filters.minimumDate {
                filter.filter(\.$expires >= minimumDate)
            }
            if let maximumDate = filters.maximumDate {
                filter.filter(\.$expires < maximumDate)
            }
            if let query = filters.query?.toSearchableQuery() {
                filter.filter(\.$document, .custom("@@"), .custom("to_tsquery('\(language)', '\(query)')"))
            }
            if let distance = filters.distance, let lat = lat, let lon = lon {
                let ((minLat, minLon), (maxLat, maxLon)) = Double.boundingBox(lat: lat, lon: lon, radius: distance)
                filter.filter(\.$lat > minLat)
                filter.filter(\.$lon > minLon)
                filter.filter(\.$lat < maxLat)
                filter.filter(\.$lon < maxLon)
            }
        }
        .group(.or) { dateFilters in
            dateFilters.filter(\.$expires == nil)
            dateFilters.filter(\.$expires > Date())
        }
        .join(Image.self, on: \Food.$imageID == \Image.$id, method: .left)
        .with(\.$creator)
            
        switch sorting {
            case .dateAsc:
                query = query.sort(\.$createdAt, .ascending)
            case .dateDesc:
                query = query.sort(\.$createdAt, .descending)
            case .slots:
                query = query.sort(\.$slots, .descending).sort(\.$createdAt, .descending)
            case .location:
                guard let lat = lat, let lon = lon else {
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest))
                }
                query = query.sort(.custom("ABS(lat - \(lat))"))
                query = query.sort(.custom("ABS(lon - \(lon))"))
        }
            
        return query.paginate(for: req)
    }
    
    func query(type: FoodType?, limit: Int, on req: Request) -> EventLoopFuture<[Food]> {
        return Food.query(on: req.db).group(.and) { filter in
            if let type = type {
                filter.filter(\.$type == .enumCase(type.rawValue))
            }
        }
        .join(Image.self, on: \Food.$imageID == \Image.$id, method: .left)
        .group(.or) { dateFilters in
            dateFilters.filter(\.$expires == nil)
            dateFilters.filter(\.$expires > Date())
        }
        .sort(\.$createdAt, .descending)
        .with(\.$creator)
        .all()
    }
    
    func find(id: UUID, on req: Request) -> EventLoopFuture<Food?> {
        return Food.query(on: req.db).filter(\.$id == id).first()
    }
    
    func findComplete(id: UUID, on req: Request) -> EventLoopFuture<Food?> {
        return Food.query(on: req.db).filter(\.$id == id).join(Image.self, on: \Food.$imageID == \Image.$id, method: .left).with(\.$creator).first()
    }
    
    func save(food: Food, on req: Request) -> EventLoopFuture<Food> {
        return food.save(on: req.db).map { food }
    }
    
    func delete(food: Food, on req: Request) -> EventLoopFuture<Void> {
        return food.delete(on: req.db)
    }
}

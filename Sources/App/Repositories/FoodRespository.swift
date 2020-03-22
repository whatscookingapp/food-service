import Vapor
import FluentPostgresDriver
import SwifQL
import PostgresBridge

protocol FoodRepository {
    
    func queryPaginated(type: FoodType?, sorting: Sorting, lat: Double?, lon: Double?, on req: Request) -> EventLoopFuture<Page<Food>>
    func query(type: FoodType?, limit: Int, on req: Request) -> EventLoopFuture<[Food]>
    func find(id: UUID, on req: Request) -> EventLoopFuture<Food?>
    func save(food: Food, on req: Request) -> EventLoopFuture<Food>
}

struct FoodRepositoryImpl: FoodRepository {
    
    func queryPaginated(type: FoodType?, sorting: Sorting, lat: Double?, lon: Double?, on req: Request) -> EventLoopFuture<Page<Food>> {
        var query = Food.query(on: req.db).group(.and) { filter in
            if let type = type {
                filter.filter(\.$type == .enumCase(type.rawValue))
            }
        }
        .group(.or) { dateFilters in
            dateFilters.filter(\.$expires == nil)
            dateFilters.filter(\.$expires > Date())
        }
        .with(\.$creator)
            
        switch sorting {
            case .dateAsc:
                query = query.sort(\.$createdAt, .ascending)
            case .dateDesc:
                query = query.sort(\.$createdAt, .descending)
            case .slots:
                query = query.sort(\.$slots, .descending).sort(\.$createdAt, .descending)
            case .location:
//                query = query.sor
                fatalError()
        }
            
        return query.paginate(for: req)
    }
    
    func query(type: FoodType?, limit: Int, on req: Request) -> EventLoopFuture<[Food]> {
        return Food.query(on: req.db).group(.and) { filter in
            if let type = type {
                filter.filter(\.$type == .enumCase(type.rawValue))
            }
        }
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
    
    func save(food: Food, on req: Request) -> EventLoopFuture<Food> {
        return food.save(on: req.db).map { food }
    }
}

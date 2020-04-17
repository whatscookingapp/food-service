import Vapor
import FluentPostgresDriver

protocol FoodReportRepository {

    func find(itemID: UUID, reporterID: UUID, on req: Request) -> EventLoopFuture<FoodReport?>
    func save(report: FoodReport, on req: Request) -> EventLoopFuture<FoodReport>
}

struct FoodReportRepositoryImpl: FoodReportRepository {
    
    func find(itemID: UUID, reporterID: UUID, on req: Request) -> EventLoopFuture<FoodReport?> {
        FoodReport.query(on: req.db).filter(\.$item.$id == itemID).filter(\.$reporter.$id == reporterID).first()
    }
    
    func save(report: FoodReport, on req: Request) -> EventLoopFuture<FoodReport> {
        report.save(on: req.db).map { report }
    }
}

import Vapor

struct DiscoverResponse: Content {

    let hero: HeroResponse?
    let lanes: [LaneResponse]
}

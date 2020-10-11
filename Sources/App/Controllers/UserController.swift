import Vapor
import Fluent

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api")
        // initial auth
        
    }
    
}

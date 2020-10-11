import Vapor
import Fluent

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api")
        // initial auth
        group
            .grouped(User.authenticator())
            .grouped(User.guardMiddleware())
            .post("login", use: loginHandler(_:))
    }
    
    // MARK: - Handlers
    
    func loginHandler(_ req: Request) throws -> EventLoopFuture<UserToken> {
        // get the user
        let user = try req.auth.require(User.self)
        // generate a token
        let token = try user.generateToken()
        // save to db
        return token
            .save(on: req.db)
            .map { token }
    }
    
}

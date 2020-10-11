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
        // MARK: Ideas
        let protected = group
            .grouped("users")
            .grouped(UserToken.authenticator())
            .grouped(UserToken.guardMiddleware())
        // 1. list all the user's ideas
        protected.get(":userId", "ideas", use: getAllIdeasHandler(_:))
    }
    
    // MARK: - Auth handlers
    
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
    
    // MARK: - Idea handlers
    
    func getAllIdeasHandler(_ req: Request) throws -> EventLoopFuture<[Idea]> {
        // get the passed id
        let id: UUID? = req.parameters.get("userId")
        // make sure the token belongs to the user we are accessing
        let auth = try req.auth.require(UserToken.self)
        if auth.user.id != id {
            return req.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
        // get the user's ideas
        return User
            .find(req.parameters.get("userId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ user in user.$ideas.get(on: req.db) })
    }
    
}

import Vapor
import Fluent

struct AdminController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "admin")
        // initial auth
        group
            .post("signup", use: signupHandler(_:))
        group
            .grouped(Admin.authenticator())
            .grouped(Admin.guardMiddleware())
            .post("login", use: loginHandler(_:))
        // protected endpoints
        let protected = group
            .grouped(AdminToken.authenticator())
            .grouped(AdminToken.guardMiddleware())
        // MARK: Users
        // 1. list all the users
        protected.get("users", use: getAllUsersHandler(_:))
        // 2. create user
        protected.post("users", use: createUserHandler(_:))
        // 3. delete user
        protected.delete("users", ":userId", use: deleteUserHandler(_:))
        // MARK: Ideas
        // 1. list all the ideas
        protected.get("ideas", use: getAllIdeasHandler(_:))
        // 2. create idea
        protected.post("ideas", use: createIdeaHandler(_:))
        // 3. delete idea
        protected.delete("ideas", ":ideaId", use: deleteIdeaHandler(_:))
        // 4. update idea
        protected.put("ideas", ":ideaId", use: updateIdeaHandler(_:))
        // 5. add category to idea
        protected.post(
            "ideas", ":ideaId",
            "categories", "categoryId",
            use: addCategoryToIdeaHandler(_:)
        )
        // 6. delete category from idea
        protected.delete(
            "ideas", ":ideaId",
            "categories", "categoryId",
            use: removeCategoryFromIdeaHandler(_:)
        )
    }
    
    // MARK: - Auth handlers
    
    func signupHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // get the admin
        let admin = try req.content.decode(Admin.self)
        admin.password = try Bcrypt.hash(admin.password)
        // save to db
        return admin
            .save(on: req.db)
            .transform(to: .noContent)
    }
    
    func loginHandler(_ req: Request) throws -> EventLoopFuture<AdminToken> {
        // get the admin
        let admin = try req.auth.require(Admin.self)
        // generate a token
        let token = try admin.generateToken()
        // save to db
        return token
            .save(on: req.db)
            .map { token }
    }
    
    // MARK: - User handlers
    
    func getAllUsersHandler(_ req: Request) throws -> EventLoopFuture<[PublicUserData]> {
        User
            .query(on: req.db)
            .all()
            .map({ users in users.map({ $0.toPublic()} )})
    }
    
    func createUserHandler(_ req: Request) throws -> EventLoopFuture<PublicUserData> {
        let user = try req.content.decode(User.self)
        user.password = try Bcrypt.hash(user.password)
        return user
            .save(on: req.db)
            .map { user.toPublic() }
    }
    
    func deleteUserHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        User
            .find(req.parameters.get("userId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ user in
                user
                    .delete(on: req.db)
                    .transform(to: .noContent)
            })
    }
    
    // MARK: - Idea handlers
    
    func getAllIdeasHandler(_ req: Request) throws -> EventLoopFuture<[Idea]> {
        Idea
            .query(on: req.db)
            .all()
    }
    
    func createIdeaHandler(_ req: Request) throws -> EventLoopFuture<Idea> {
        let data = try req.content.decode(CreateIdeaData.self)
        let idea = Idea(
            name: data.name,
            description: data.description,
            userId: data.userId
        )
        return idea
            .save(on: req.db)
            .map { idea }
    }

    func deleteIdeaHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Idea
            .find(req.parameters.get("ideaId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ idea in
                idea
                    .delete(on: req.db)
                    .transform(to: .noContent)
            })
    }

    func updateIdeaHandler(_ req: Request) throws -> EventLoopFuture<Idea> {
        let updatedIdea = try req.content.decode(CreateIdeaData.self)
        return Idea
            .find(req.parameters.get("ideaId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ idea in
                idea.name = updatedIdea.name
                idea.description = updatedIdea.description
                idea.$user.id = updatedIdea.userId
                return idea
                    .save(on: req.db)
                    .map { idea }
            })
    }

    func addCategoryToIdeaHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let ideaQuery = Idea
            .find(req.parameters.get("ideaId"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let categoryQuery = Category
            .find(req.parameters.get("categoryId"), on: req.db)
            .unwrap(or: Abort(.notFound))
        return ideaQuery
            .and(categoryQuery)
            .flatMap({ (idea, category) in
                idea.$categories
                    .attach(category, on: req.db)
                    .transform(to: .created)
            })
    }
    
    func removeCategoryFromIdeaHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let ideaQuery = Idea
            .find(req.parameters.get("ideaId"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let categoryQuery = Category
            .find(req.parameters.get("categoryId"), on: req.db)
            .unwrap(or: Abort(.notFound))
        return ideaQuery
            .and(categoryQuery)
            .flatMap({ (idea, category) in
                idea.$categories
                    .detach(category, on: req.db)
                    .transform(to: .noContent)
            })
    }
    
    // MARK: - Category handlers
    
}

// TODO: Move this to the IdeasController once it is implemented
struct CreateIdeaData: Content {
    
    let name: String
    let description: String
    let userId: UUID
    
}

// TODO: move this to the UsersController once it is implemented
struct PublicUserData: Content {
    
    let id: UUID?
    let name: String
    let username: String
    
}

extension User {
    
    func toPublic() -> PublicUserData {
        PublicUserData(id: id, name: name, username: username)
    }
    
}

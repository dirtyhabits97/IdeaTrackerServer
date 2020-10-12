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
        protected.delete(
            "users", ":userId",
            use: deleteUserHandler(_:)
        )
        // 4. update user
        protected.put(
            "users", ":userId",
            use: updateUserHandler(_:)
        )
        // MARK: Ideas
        // 1. list all the ideas
        protected.get("ideas", use: getAllIdeasHandler(_:))
        // 2. create idea
        protected.post("ideas", use: createIdeaHandler(_:))
        // 3. delete idea
        protected.delete(
            "ideas", ":ideaId",
            use: deleteIdeaHandler(_:)
        )
        // 4. update idea
        protected.put(
            "ideas", ":ideaId",
            use: updateIdeaHandler(_:)
        )
        // 5. add category to idea
        protected.post(
            "ideas", ":ideaId",
            "categories", ":categoryId",
            use: addCategoryToIdeaHandler(_:)
        )
        // 6. delete category from idea
        protected.delete(
            "ideas", ":ideaId",
            "categories", ":categoryId",
            use: removeCategoryFromIdeaHandler(_:)
        )
        // 7. list all the idea's categories
        protected.get(
            "ideas", ":ideaId",
            "categories",
            use: getAllCategoriesFromIdeaHandler(_:)
        )
        // MARK: Categories
        // 1. list all the categories
        protected.get("categories", use: getAllCategoriesHandler(_:))
        // 2. create category
        protected.post("categories", use: createCategoryHandler(_:))
        // 3. delete category
        protected.delete(
            "categories", ":categoryId",
            use: deleteCategoryHandler(_:)
        )
        // 4. update category
        protected.put(
            "categories", ":categoryId",
            use: updateCategoryHandler(_:)
        )
        // 5. list all the category's ideas
        protected.get(
            "categories", ":categoryId",
            "ideas",
            use: getAllIdeasFromCategory(_:)
        )
        // MARK: Database
        // 1. reset categories
        protected.get(
            "reset", "categories",
            use: resetCategoriesHandler(_:)
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
            .map({ users in users.map({ $0.toPublic()}) })
    }
    
    func createUserHandler(_ req: Request) throws -> EventLoopFuture<PublicUserData> {
        // validations for the user params
        try User.validate(content: req)
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
    
    func updateUserHandler(_ req: Request) throws -> EventLoopFuture<PublicUserData> {
        let updatedUser = try req.content.decode(User.self)
        // if the password is empty, do not hash
        if !updatedUser.password.isEmpty {
            updatedUser.password = try Bcrypt.hash(updatedUser.password)
        }
        return User
            .find(req.parameters.get("userId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ user in
                user.name = updatedUser.name
                user.username = updatedUser.username
                // if the password is empty, do not update the password
                if !updatedUser.password.isEmpty {
                    user.password = updatedUser.password
                }
                return user
                    .save(on: req.db)
                    .map({ user.toPublic() })
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
    
    func getAllCategoriesFromIdeaHandler(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Idea
            .find(req.parameters.get("ideaId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ idea in
                idea.$categories
                    .query(on: req.db)
                    .all()
            })
    }
    
    // MARK: - Category handlers
    
    func getAllCategoriesHandler(_ req: Request) throws -> EventLoopFuture<[Category]> {
        Category
            .query(on: req.db)
            .all()
    }
    
    func createCategoryHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        return category
            .save(on: req.db)
            .map { category }
    }
    
    func deleteCategoryHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Category
            .find(req.parameters.get("categoryId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ category in
                category
                    .delete(on: req.db)
                    .transform(to: .noContent)
            })
    }
    
    func updateCategoryHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        let updatedCategory = try req.content.decode(Category.self)
        return Category
            .find(req.parameters.get("categoryId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ category in
                category.name = updatedCategory.name
                return category
                    .save(on: req.db)
                    .map { category }
            })
    }
    
    func getAllIdeasFromCategory(_ req: Request) throws -> EventLoopFuture<[Idea]> {
        Category
            .find(req.parameters.get("categoryId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ category in
                category
                    .$ideas
                    .query(on: req.db)
                    .all()
            })
    }
    
    // MARK: - Database handlers
    
    func resetCategoriesHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let pivotMigration = CreateIdeaCategoryPivot()
        let categoryMigration = CreateCategory()
        return pivotMigration
            .revert(on: req.db)
            .flatMap({ categoryMigration.revert(on: req.db) })
            .flatMap({ categoryMigration.prepare(on: req.db) })
            .flatMap({ pivotMigration.prepare(on: req.db) })
            .transform(to: .noContent)
    }
    
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

import Vapor
import Fluent

final class CreateUserToken: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(UserToken.schema)
            .id()
            .field("value", .string, .required)
            .unique(on: "value")
            .field("userId", .uuid, .required, .references(User.schema, "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(UserToken.schema).delete()
    }
    
}

import Fluent

struct CreateIdea: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Idea.schema)
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("userid", .uuid, .required, .references(User.schema, "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Idea.schema).delete()
    }
    
}

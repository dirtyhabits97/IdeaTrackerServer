import Fluent

struct CreateCategory: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Category.schema)
            .id()
            .field("nam", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Category.schema).delete()
    }
    
}

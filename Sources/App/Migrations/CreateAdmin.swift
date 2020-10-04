import Fluent

struct CreateAdmin: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Admin.schema)
            .id()
            .field("username", .string, .required)
            .unique(on: "username")
            .field("password", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Admin.schema).delete()
    }
    
}

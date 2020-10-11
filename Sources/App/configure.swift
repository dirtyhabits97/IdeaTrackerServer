import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)
    
    app.logger.logLevel = .debug

    app.migrations.add(CreateAdmin())
    app.migrations.add(CreateAdminToken())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserToken())
    app.migrations.add(CreateIdea())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateIdeaCategoryPivot())
    try app.autoMigrate().wait()
    // register routes
    try routes(app)
}

/*
 Docker command:
 docker run --name postgres -e POSTGRES_DB=vapor_database -e POSTGRES_USER=vapor_username -e POSTGRES_PASSWORD=vapor_password -p 5432:5432 -d postgres
 
 Token:
 qi6IWbrB0m2GeSa3jXHnkw==
 */

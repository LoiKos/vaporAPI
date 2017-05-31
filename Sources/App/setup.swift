@_exported import Vapor
import PostgreSQLProvider

extension Config{

    public func setup() throws {
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        try setupProviders()
        try setupPreparations()
    }
    
    // Setup for all required provider
    private func setupProviders() throws {
        try addProvider(PostgreSQLProvider.Provider.self)
    }
    
    // Care if in your database you have 'fluent' table registering your other tables then they won't be added during preparations phase.
    private func setupPreparations() throws {

    }
}

extension Droplet {
    
    public func setup() throws {
        try collection(RoutingCenter.self)
    }
}


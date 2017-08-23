import App
import Foundation

let config = try Config()

try config.setup()

let drop = try Droplet(config)
drop.database?.threadConnectionPool.connectionPendingTimeoutSeconds = 30

try drop.setup()


try drop.run()

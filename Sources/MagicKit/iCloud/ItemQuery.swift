import AsyncAlgorithms
import Foundation
import OSLog

public class ItemQuery: SuperLog, SuperEvent, SuperThread {
    public static let emoji = "🌸"
    
    public let query = NSMetadataQuery()
    public let queue: OperationQueue
    public var verbose = false
    public var stopped = false

    public init(queue: OperationQueue = .main) {
        self.queue = queue
    }
    
    public func stop() {
        self.stopped = true
    }

    // MARK: 监听某个目录的变化

    public func searchMetadataItems(
        predicates: [NSPredicate] = [],
        sortDescriptors: [NSSortDescriptor] = [],
        scopes: [Any] = [NSMetadataQueryUbiquitousDocumentsScope]
    ) -> AsyncStream<MetadataItemCollection> {
        if verbose {
            os_log("\(self.t)searchMetadataItems")
        }
        
        query.searchScopes = scopes
        query.sortDescriptors = sortDescriptors
        query.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        return AsyncStream { continuation in
            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidFinishGathering,
                object: query,
                queue: queue
            ) { _ in
                self.collectAll(continuation, name: .NSMetadataQueryDidFinishGathering)
            }

            NotificationCenter.default.addObserver(
                forName: .NSMetadataQueryDidUpdate,
                object: query,
                queue: queue
            ) { notification in
                if self.stopped {
                    os_log("\(self.t)停止监听")
                    return continuation.finish()
                }
                
                self.collectChanged(continuation, notification: notification, name: .NSMetadataQueryDidUpdate)
            }

            query.operationQueue = queue
            query.operationQueue?.addOperation {
                if self.verbose {
                    os_log("\(self.t)start")
                }
                
                self.query.start()
            }

            continuation.onTermination = { @Sendable _ in
//                os_log("\(self.t)onTermination")
                self.query.stop()
                NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: self.query)
                NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidUpdate, object: self.query)
            }
        }
    }

    // MARK: 所有的item
    
    private func collectAll(_ continuation: AsyncStream<MetadataItemCollection>.Continuation, name: Notification.Name) {
        self.bg.async {
            if self.verbose {
                os_log("\(self.t)NSMetadataQueryDidFinishGathering")
            }
            
            let result = self.query.results.compactMap { item -> MetaWrapper? in
                guard let metadataItem = item as? NSMetadataItem else {
                    return nil
                }
                
                return MetaWrapper(metadataItem: metadataItem)
            }
            
            if self.verbose {
                os_log("\(self.t)Yield with \(result.count)")
            }
            continuation.yield(MetadataItemCollection(name: name, items: result))
        }
    }

    // MARK: 仅改变过的item
    
    private func collectChanged(_ continuation: AsyncStream<MetadataItemCollection>.Continuation, notification: Notification, name: Notification.Name) {
        let changedItems = notification.userInfo?[NSMetadataQueryUpdateChangedItemsKey] as? [NSMetadataItem] ?? []
        let deletedItems = notification.userInfo?[NSMetadataQueryUpdateRemovedItemsKey] as? [NSMetadataItem] ?? []
        
        let changedResult = changedItems.compactMap { item -> MetaWrapper? in
            MetaWrapper(metadataItem: item, isUpdated: true)
        }
        
        let deletedResult = deletedItems.compactMap { item -> MetaWrapper? in
            MetaWrapper(metadataItem: item, isDeleted: true, isUpdated: true)
        }
        
        DispatchQueue.global().async {
            if self.verbose {
                os_log("\(self.t)NSMetadataQueryDidUpdate")
            }
                
            if changedResult.count > 0 {
                if self.verbose {
                    os_log("\(self.t)Yield with changed \(changedResult.count)")
                }
                continuation.yield(MetadataItemCollection(name: name, items: changedResult))
            }
            
            if deletedResult.count > 0 {
                if self.verbose {
                    os_log("\(self.t)Yield with deleted\(deletedResult.count)")
                }
                continuation.yield(MetadataItemCollection(name: name, items: deletedResult))
            }
        }
    }
}

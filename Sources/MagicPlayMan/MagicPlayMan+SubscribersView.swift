import SwiftUI
import MagicCore

public extension MagicPlayMan {
    /// 订阅者列表视图
    struct SubscribersView: View {
        let subscribers: [PlaybackEvents.Subscriber]
        
        public var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Event Subscribers")
                    .font(.headline)
                
                if subscribers.isEmpty {
                    ContentUnavailableView(
                        "No Subscribers",
                        systemImage: .iconPersonGroupSlash,
                        description: Text("No subscribers are currently registered.")
                    )
                } else {
                    subscribersList
                }
            }
        }
        
        private var subscribersList: some View {
            List {
                ForEach(subscribers, id: \.id) { subscriber in
                    SubscriberRow(subscriber: subscriber)
                }
            }
            .listStyle(.plain)
        }
    }
    
    /// 订阅者行视图
    private struct SubscriberRow: View {
        let subscriber: PlaybackEvents.Subscriber
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(subscriber.name)
                    .font(.headline)
                
                Text("Since: \(subscriber.date.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
} 

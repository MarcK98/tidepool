import SwiftUI

struct ContentView: View {
    @State private var filter: ConditionFilter = .all

    private var spots: [Spot] { SpotCatalogue.spots(matching: filter) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    if spots.isEmpty {
                        Text("Nothing firing right now — check back on the next swell.")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.muted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                    }
                    ForEach(spots) { SpotCardView(spot: $0) }
                }
                .animation(.easeInOut(duration: 0.2), value: filter)
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .background(Theme.ink.ignoresSafeArea())
            .navigationTitle("Tidepool")
            .toolbarBackground(Theme.ink, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .accessibilityIdentifier("spot-list")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Today's conditions")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Theme.text)
                Text(countLine)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.muted)
            }
            filterControl
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    private var countLine: String {
        switch filter {
        case .all: return "\(SpotCatalogue.all.count) spots tracked"
        case .goodPlus: return "\(spots.count) of \(SpotCatalogue.all.count) spots firing"
        }
    }

    /// Segmented control: one inset track, the active chip lifted out of it.
    /// Hand-rolled rather than a `Picker` so it matches the web chips exactly.
    private var filterControl: some View {
        HStack(spacing: 4) {
            ForEach(ConditionFilter.allCases) { option in
                Button {
                    filter = option
                } label: {
                    Text(option.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(filter == option ? Theme.ink : Theme.muted)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 7)
                        .background {
                            if filter == option {
                                Capsule().fill(
                                    LinearGradient(colors: [Theme.aqua, Theme.deep],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("filter-\(option.rawValue)")
                .accessibilityAddTraits(filter == option ? [.isSelected] : [])
            }
        }
        .padding(4)
        .background(Theme.ink2.opacity(0.6), in: Capsule())
        .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
        .animation(.easeInOut(duration: 0.18), value: filter)
    }
}

#Preview {
    ContentView()
}

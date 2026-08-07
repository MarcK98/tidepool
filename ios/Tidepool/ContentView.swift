import SwiftUI

struct ContentView: View {
    @State private var filter: ConditionsFilter = .all

    private var visible: [Spot] { SpotCatalogue.spots(matching: filter) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    filterRail
                    ForEach(visible) { SpotCardView(spot: $0) }
                    if visible.isEmpty { empty }
                }
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
        VStack(alignment: .leading, spacing: 6) {
            Text("Today's conditions")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.text)
            Text(countLabel)
                .font(.system(size: 14))
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    private var countLabel: String {
        filter == .all
            ? "\(SpotCatalogue.all.count) spots tracked"
            : "\(visible.count) of \(SpotCatalogue.all.count) spots tracked"
    }

    /// A pill rail rather than a segmented `Picker` — the stock control brings
    /// its own light chrome, and this screen is the same dark palette as the web
    /// filter it mirrors.
    private var filterRail: some View {
        HStack(spacing: 4) {
            ForEach(ConditionsFilter.allCases) { option in
                Button {
                    filter = option
                } label: {
                    Text(option.label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(filter == option ? Theme.ink : Theme.muted)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
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
        .background(Theme.ink2, in: Capsule())
        .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
        .accessibilityIdentifier("conditions-filter")
    }

    private var empty: some View {
        Text("Nothing is firing right now. Try all spots.")
            .font(.system(size: 15))
            .foregroundStyle(Theme.muted)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 32)
    }
}

#Preview {
    ContentView()
}

import SwiftUI

struct ContentView: View {
    @State private var sort: SortMode = .featured

    private var spots: [Spot] { SpotCatalogue.all.sorted(by: sort) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    ForEach(spots) { SpotCardView(spot: $0) }
                }
                .animation(.easeOut(duration: 0.25), value: sort)
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
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Today's conditions")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Theme.text)
                Text("\(spots.count) spots tracked")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.muted)
            }
            sortControl
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    /// Segmented toggle, hand-rolled rather than `Picker(.segmented)` so it
    /// carries the same capsule and gradient as the web's `.sort`.
    private var sortControl: some View {
        HStack(spacing: 4) {
            ForEach(SortMode.allCases) { mode in
                Button {
                    sort = mode
                } label: {
                    Text(mode.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(sort == mode ? Theme.ink : Theme.muted)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 7)
                        .background {
                            if sort == mode {
                                Capsule().fill(
                                    LinearGradient(colors: [Theme.aqua, Theme.deep],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing)
                                )
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("sort-\(mode.rawValue)")
                .accessibilityAddTraits(sort == mode ? [.isSelected] : [])
            }
        }
        .padding(4)
        .background(Theme.ink2, in: Capsule())
        .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Sort spots")
    }
}

#Preview {
    ContentView()
}

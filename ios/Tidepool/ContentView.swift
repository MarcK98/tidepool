import SwiftUI

struct ContentView: View {
    private let spots = SpotCatalogue.all

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    ForEach(spots) { SpotCardView(spot: $0) }
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
            Text("\(spots.count) spots tracked")
                .font(.system(size: 14))
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }
}

#Preview {
    ContentView()
}

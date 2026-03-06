import SwiftUI
import SwiftData

struct CreateActivitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    @Query private var existing: [SportActivity]

    @State private var name = ""
    @State private var selectedIcon = "figure.boxing"

    static let activityIcons = [
        "figure.boxing", "figure.martial.arts", "figure.pool.swim",
        "figure.basketball", "figure.soccer", "figure.tennis",
        "figure.volleyball", "figure.climbing", "figure.skiing.downhill",
        "figure.surfing", "figure.dance", "figure.jumprope",
        "figure.pilates", "figure.rowing", "figure.handball",
        "sportscourt.fill", "bicycle", "figure.outdoor.cycle"
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                TextField("Nom de l'activité", text: $name)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Icône")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.textSecondary)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), spacing: 10) {
                        ForEach(Self.activityIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title3)
                                    .frame(width: 46, height: 46)
                                    .background(selectedIcon == icon ? theme.accentColor : DesignTokens.card2)
                                    .foregroundStyle(selectedIcon == icon ? .black : .white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }

                Button {
                    let activity = SportActivity(
                        name: name.trimmingCharacters(in: .whitespaces),
                        iconName: selectedIcon,
                        sortOrder: existing.count
                    )
                    modelContext.insert(activity)
                    dismiss()
                } label: {
                    Text("Créer")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canCreate ? theme.accentColor : DesignTokens.card2)
                        .foregroundStyle(canCreate ? .black : DesignTokens.textSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!canCreate)

                Spacer()
            }
            .padding()
            .background(DesignTokens.bgPrimary)
            .navigationTitle("Nouvelle activité")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(DesignTokens.textSecondary)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationBackground(DesignTokens.bgPrimary)
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

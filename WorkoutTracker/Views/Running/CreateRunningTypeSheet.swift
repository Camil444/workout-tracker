import SwiftUI
import SwiftData

struct CreateRunningTypeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme

    @Query private var existingTypes: [RunningSessionType]

    @State private var name = ""
    @State private var type: RunningType = .footing

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                TextField("Nom de la session", text: $name)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Type")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.textSecondary)
                    HStack(spacing: 12) {
                        ForEach(RunningType.allCases, id: \.self) { t in
                            Button {
                                type = t
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: t == .footing ? "figure.run" : "bolt.horizontal.fill")
                                        .font(.title3)
                                    Text(t.rawValue)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(type == t ? theme.accentColor : DesignTokens.card2)
                                .foregroundStyle(type == t ? .black : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }

                Button {
                    let session = RunningSessionType(
                        name: name.trimmingCharacters(in: .whitespaces),
                        runningType: type,
                        sortOrder: existingTypes.count
                    )
                    modelContext.insert(session)
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
            .navigationTitle("Nouvelle course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(DesignTokens.textSecondary)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium])
        .presentationBackground(DesignTokens.bgPrimary)
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

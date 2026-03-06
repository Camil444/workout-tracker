import SwiftUI
import SwiftData
import MapKit

struct LocationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @Environment(LocationManager.self) private var locationManager

    @Query private var gymLocations: [GymLocation]

    @State private var showAddLocation = false
    @State private var locationToDelete: GymLocation?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Permission status
                    permissionCard

                    // Locations list
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mes lieux")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        if gymLocations.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "mappin.slash")
                                    .font(.title)
                                    .foregroundStyle(DesignTokens.textSecondary)
                                Text("Aucun lieu enregistré")
                                    .font(.subheadline)
                                    .foregroundStyle(DesignTokens.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                        } else {
                            ForEach(gymLocations) { location in
                                HStack(spacing: 12) {
                                    Image(systemName: iconForType(location.activityType))
                                        .font(.title3)
                                        .foregroundStyle(theme.accentColor)
                                        .frame(width: 36)

                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text(location.name)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.white)
                                            if location.isPrimary {
                                                Text("PRINCIPAL")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(theme.accentColor.opacity(0.2))
                                                    .foregroundStyle(theme.accentColor)
                                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                            }
                                        }
                                        Text("\(location.activityType.capitalized) · \(Int(location.radiusMeters))m")
                                            .font(.caption)
                                            .foregroundStyle(DesignTokens.textSecondary)
                                    }

                                    Spacer()

                                    Button {
                                        locationToDelete = location
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(DesignTokens.destructive)
                                    }
                                }
                                .padding()
                                .background(DesignTokens.card1)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }

                        Button {
                            showAddLocation = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                Text("Ajouter un lieu")
                            }
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.accentColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                    .foregroundStyle(DesignTokens.border)
                            )
                        }
                    }
                }
                .padding()
            }
            .background(DesignTokens.bgPrimary)
            .navigationTitle("Lieux d'entraînement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }
                        .foregroundStyle(theme.accentColor)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .sheet(isPresented: $showAddLocation) {
            AddLocationSheet()
        }
        .alert(
            "Supprimer \(locationToDelete?.name ?? "") ?",
            isPresented: Binding(
                get: { locationToDelete != nil },
                set: { if !$0 { locationToDelete = nil } }
            )
        ) {
            Button("Annuler", role: .cancel) { locationToDelete = nil }
            Button("Supprimer", role: .destructive) {
                if let loc = locationToDelete {
                    modelContext.delete(loc)
                    locationToDelete = nil
                    locationManager.startMonitoring(locations: gymLocations.filter { $0.id != loc.id })
                }
            }
        }
    }

    @ViewBuilder
    private var permissionCard: some View {
        let status = locationManager.authorizationStatus
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: status == .authorizedAlways ? "checkmark.circle.fill" : "location.fill")
                    .foregroundStyle(status == .authorizedAlways ? Color.green : theme.accentColor)
                Text("Notifications de lieu")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }

            switch status {
            case .authorizedAlways:
                Text("Activé — Tu recevras une notification en arrivant à ta salle.")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.textSecondary)
            case .authorizedWhenInUse:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pour recevoir des notifications en arrivant à ta salle, autorise la localisation « Toujours » dans les Réglages.")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.textSecondary)
                    Button("Ouvrir les Réglages") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.accentColor)
                }
            default:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Autorise la localisation pour être notifié en arrivant à ta salle.")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.textSecondary)
                    Button("Autoriser la localisation") {
                        locationManager.requestAlwaysAuthorization()
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.accentColor)
                }
            }
        }
        .padding()
        .background(DesignTokens.card1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func iconForType(_ type: String) -> String {
        switch type {
        case "musculation": return "dumbbell.fill"
        case "running": return "figure.run"
        case "sport": return "flame.fill"
        default: return "mappin.circle.fill"
        }
    }
}

// MARK: - Add Location Sheet

struct AddLocationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var theme
    @Environment(LocationManager.self) private var locationManager

    @Query private var gymLocations: [GymLocation]

    @State private var name = ""
    @State private var activityType = "musculation"
    @State private var isPrimary = false
    @State private var radius: Double = 100
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var hasSetLocation = false

    private let activityTypes = [
        ("musculation", "Musculation", "dumbbell.fill"),
        ("running", "Course", "figure.run"),
        ("sport", "Activité", "flame.fill"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("Nom du lieu", text: $name)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(DesignTokens.card2)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)

                    // Activity type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type d'activité")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignTokens.textSecondary)
                        HStack(spacing: 8) {
                            ForEach(activityTypes, id: \.0) { type in
                                Button {
                                    activityType = type.0
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: type.2)
                                            .font(.title3)
                                        Text(type.1)
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(activityType == type.0 ? theme.accentColor : DesignTokens.card2)
                                    .foregroundStyle(activityType == type.0 ? .black : .white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    Toggle(isOn: $isPrimary) {
                        Text("Lieu principal")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    .tint(theme.accentColor)
                    .padding()
                    .background(DesignTokens.card2)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Map
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Emplacement")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(DesignTokens.textSecondary)
                            Spacer()
                            Button {
                                useCurrentLocation()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                    Text("Ma position")
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(theme.accentColor)
                            }
                        }
                        Map(coordinateRegion: $region, annotationItems: hasSetLocation ? [MapPin(coordinate: region.center)] : []) { pin in
                            MapAnnotation(coordinate: pin.coordinate) {
                                Circle()
                                    .fill(theme.accentColor)
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Circle()
                                            .stroke(theme.accentColor.opacity(0.3), lineWidth: 2)
                                            .frame(width: 40, height: 40)
                                    )
                            }
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture { location in
                            hasSetLocation = true
                        }
                        .onChange(of: region.center.latitude) { _, _ in
                            if hasSetLocation { }
                        }

                        Text("Centre la carte sur ton lieu puis valide")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.textSecondary)

                        Button {
                            hasSetLocation = true
                        } label: {
                            Text("Utiliser le centre de la carte")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(DesignTokens.card2)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    // Radius
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rayon de détection : \(Int(radius))m")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignTokens.textSecondary)
                        Slider(value: $radius, in: 50...500, step: 25)
                            .tint(theme.accentColor)
                    }

                    Button {
                        saveLocation()
                    } label: {
                        Text("Enregistrer")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canSave ? theme.accentColor : DesignTokens.card2)
                            .foregroundStyle(canSave ? .black : DesignTokens.textSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!canSave)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .background(DesignTokens.bgPrimary)
            .navigationTitle("Nouveau lieu")
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
        .onAppear {
            locationManager.requestAuthorization()
            locationManager.requestCurrentLocation()
            if let loc = locationManager.currentLocation {
                region.center = loc.coordinate
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && hasSetLocation
    }

    private func useCurrentLocation() {
        locationManager.requestCurrentLocation()
        if let loc = locationManager.currentLocation {
            region.center = loc.coordinate
            hasSetLocation = true
        }
    }

    private func saveLocation() {
        let location = GymLocation(
            name: name.trimmingCharacters(in: .whitespaces),
            latitude: region.center.latitude,
            longitude: region.center.longitude,
            radiusMeters: radius,
            isPrimary: isPrimary,
            activityType: activityType
        )
        modelContext.insert(location)

        // Restart monitoring with new location
        var allLocations = gymLocations
        allLocations.append(location)
        locationManager.startMonitoring(locations: allLocations)

        dismiss()
    }
}

private struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

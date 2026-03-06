# Workout Tracker

App iOS native en SwiftUI pour suivre ses performances en musculation. Remplace les tableaux Notes par une interface fluide et motivante.

## Stack

- **SwiftUI** (iOS 17+)
- **SwiftData** pour la persistance locale
- **Swift Charts** pour les graphiques de progression
- **SF Symbols** pour les icones
- Aucune dependance externe

## Fonctionnalites

- **Accueil** : grille mosaique des seances avec max affiches
- **Logger** : systeme accordeon pour enregistrer ses series (reps x poids)
- **Stats** : graphiques de progression par exercice avec Swift Charts
- **Parametres** : profil, couleur d'accent personnalisable, gestion des seances

## Design

- Dark mode, inspire de Nike Training Club
- Couleur d'accent personnalisable (defaut: jaune-vert fluo #E8FF00)
- Typographie SF Pro bold, interface minimaliste
- Animations fluides (accordeons, transitions)

## Architecture

```
WorkoutTracker/
  App/                  # Point d'entree
  Models/               # SwiftData models (UserProfile, Workout, Exercise, ExerciseLog, SetEntry)
  Views/
    Onboarding/         # Flow d'onboarding (4 etapes)
    Home/               # Grille des seances
    Logger/             # Accordeon + saisie des logs
    Stats/              # Graphiques Swift Charts
    Settings/           # Profil, couleur, gestion
    Shared/             # Composants reutilisables
  ViewModels/           # ThemeManager, WorkoutViewModel
  Utilities/            # Extensions, Design Tokens
```

## Modele de donnees

- **UserProfile** : prenom, infos physiques, couleur d'accent, onboarding
- **Workout** : seance avec nom, icone SF Symbol, liste d'exercices
- **Exercise** : exercice avec unite (kg ou PDC), historique de logs
- **ExerciseLog** : entree hebdomadaire avec series (reps x poids)

## Installation

1. Ouvrir `WorkoutTracker.xcodeproj` dans Xcode 15+
2. Selectionner un simulateur iOS 17+
3. Build & Run

## Licence

Projet personnel.

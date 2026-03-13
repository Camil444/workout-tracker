# Workout Tracker

App iOS native en SwiftUI pour suivre ses performances en musculation, course a pied et activites sportives.

## Stack

- **SwiftUI** (iOS 17+)
- **SwiftData** pour la persistance locale
- **Swift Charts** pour les graphiques de progression
- **SF Symbols** pour les icones
- Aucune dependance externe

## Fonctionnalites

- **Onboarding** : choix de programme (PPL, Upper/Lower, Full Body, Bro Split) avec seances pre-remplies et personnalisables
- **Accueil** : grille des seances musculation, course a pied et activites avec confirmation avant demarrage
- **Logger** : systeme accordeon avec timer de session, timer de repos (son + notification), saisie des series (reps x poids), detection de PR avec celebration, suppression de logs individuels
- **Stats** : graphiques de progression par exercice, calendrier d'activite, cartes resume
- **Course a pied** : suivi footing et fractionne (duree, distance, vitesse)
- **Activites** : suivi d'activites sportives personnalisees
- **Parametres** : profil, mode sombre/clair, couleur d'accent, timer de repos, gestion des seances, reinitialisation
- **IA** : identification d'exercice par description (OpenAI)
- **Live Activity** : widget Dynamic Island + ecran de verrouillage affichant timer de session et repos, boutons pour lancer un repos directement depuis le widget

## Design

- Dark/Light mode, inspire de Nike Training Club
- Couleur d'accent personnalisable (defaut: jaune-vert fluo #E8FF00)
- Typographie SF Pro bold, interface minimaliste
- Animations fluides (accordeons, transitions, confetti PR)
- Session et timers persistent en arriere-plan (UserDefaults)
- Live Activity avec Dynamic Island (ActivityKit)

## Architecture

```
WorkoutTracker/
  App/                  # Point d'entree
  Models/               # SwiftData models
  Views/
    Onboarding/         # Flow d'onboarding (4 etapes + choix programme)
    Home/               # Grille des seances, courses, activites
    Logger/             # Accordeon + saisie + timer repos + recap session
    Running/            # Sheets course a pied
    Activities/         # Sheets activites sportives
    Stats/              # Graphiques Swift Charts + calendrier
    Settings/           # Profil, apparence, gestion, reset
    Shared/             # Composants reutilisables
  ViewModels/           # ThemeManager, WorkoutViewModel
  Utilities/            # Extensions, Design Tokens, Recommendations, Templates
WorkoutLiveActivity/     # Widget Extension (Live Activity / Dynamic Island)
```

## Modele de donnees

- **UserProfile** : prenom, infos physiques, couleur d'accent, mode sombre, timer repos, onboarding
- **Workout** : seance avec nom, icone SF Symbol, liste d'exercices
- **Exercise** : exercice avec unite (kg ou PDC), historique de logs
- **ExerciseLog** : entree hebdomadaire avec series (reps x poids)
- **RunningSessionType** : type de course (footing/fractionne) avec logs
- **SportActivity** : activite sportive personnalisee avec logs

## Installation

1. Ouvrir `WorkoutTracker.xcodeproj` dans Xcode 15+
2. Selectionner un simulateur iOS 17+
3. Build & Run

## Licence

Projet personnel.

# Fluxo do App - Pippo

> Documentação do fluxo de navegação extraído do Figma

---

## Fluxo Principal

```
Splash → Onboarding → Home (com tabs)
         ↓
         Auth (login existente)
```

---

## Fluxo de Onboarding (Novo Usuário)

```
Welcome
  ↓
SelectLanguage → LanguageLevel → LearningReason
  ↓
Intro (transição)
  ↓
StudyTime
  ↓
PauseOne (transição)
  ↓
UserName → UserAge
  ↓
PauseTow (transição)
  ↓
UserEmail → UserPassword → VerifyCode
  ↓
Conclusion (transição)
  ↓
Home
```

---

## Fluxo de Auth (Usuário Existente)

```
Signin
  ↓
ForgotPassword → VerifyCode → NewPassword
  ↓
Home
```

---

## Fluxo Home (Tabs)

```
Home (IndexedStack)
├── Tab 0: Courses (trilha de lições)
├── Tab 1: Leaderboard (ranking)
├── Tab 2: Shop (loja)
├── Tab 3: Treasure (missões)
└── Tab 4: Profile (perfil)
```

---

## Fluxo de Lição

```
Courses (Home Tab 0)
  ↓
SectionsPage (unidades)
  ↓
Exercícios:
├── ImageExercisePage
├── TranslationExercisePage
├── WordExercisePage
└── MatchExercisePage
  ↓
CompletePage (conclusão)
```

---

## Fluxo de Profile

```
Profile (Tab 4)
├── UserProfilePage (visualizar perfil)
├── EditProfilePage (editar dados)
├── SettingsPage
│   ├── NotificationsPage
│   ├── LearningControlsPage
│   ├── CoursesPage
│   ├── ChangePasswordPage
│   └── PhoneNumberPage → VerifyPhonePage → PhoneLinkedPage
└── Friends (seguindo/seguidores)
```

---

## Modais e Popovers

### Home AppBar Stats
- StreakModal (dias consecutivos)
- EnergyModal (vidas/sparks)
- GemsModal (moedas)
- CoursesModal (trocar idioma)

### Lesson
- LowEnergyModal (sem energia)
- FeedbackBottomSheet (resposta certa/errada)
- LessonPopover (iniciar lição)

### Profile
- ChangeAvatarModal
- ReminderTimeModal
- CountrySelectorModal
- DeleteAccountModal → ConfirmDeleteModal

### Leaderboard
- StatusModal (promoção/rebaixamento)
- LeagueSelector

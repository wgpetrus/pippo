# Documentação do Projeto Pippo

> Status atual do desenvolvimento

---

## Resumo

| Etapa | Status | Descrição |
|-------|--------|-----------|
| 1. Preparação | ✅ Completa | Estrutura, rotas, wrapper, navegação |
| 2. Implementação UI | ✅ Completa | Todas as telas implementadas |
| 3. Implementação Lógica | 🔄 Parcial | Controllers básicos criados |

---

## Estrutura da Documentação

```
docs/
├── README.md (este arquivo)
├── 1.preparacao/
│   ├── 1-fluxo.md        # Fluxos de navegação
│   ├── 2-estrutura.md    # Estrutura de pastas
│   ├── 3-rotas.md        # Rotas GetX
│   ├── 4-wrapper.md      # Splash/Wrapper
│   └── 6-navegacao.md    # Navegação implementada
└── 2.imp-ui/
    ├── auth.md           # Telas de autenticação
    ├── onboarding.md     # Telas de onboarding
    ├── home.md           # Telas da home (tabs)
    ├── lesson.md         # Telas de exercícios
    └── profile.md        # Telas de perfil
```

---

## Contagem de Telas

| Feature | Telas | Widgets |
|---------|-------|---------|
| Auth | 4 | 1 |
| Onboarding | 14 | 5 |
| Home | 5 | 8 |
| Leaderboard | 1 | 5 |
| Shop | 1 | 4 |
| Treasure | 1 | 2 |
| Lesson | 6 | 11 |
| Profile | 11 | 12 |
| **Total** | **43** | **48** |

---

## Widgets Globais (shared/widgets/)

| Widget | Descrição |
|--------|-----------|
| AppAppbar | AppBar padrão com botão voltar |
| AppBackButton | Botão voltar circular |
| AppButton | Botão principal (primário/secundário) |
| AppFloatAnim | Animação de flutuação |
| AppLessonButton | Botão de lição na trilha |
| AppListItem | Item de lista para menus |
| AppPinput | Input de PIN/OTP |
| AppResendCode | Timer de reenvio de código |
| AppTextField | Campo de texto padrão |

---

## Próximos Passos (Etapa 8)

### Controllers a Implementar
- [ ] AuthController - lógica de login/registro
- [ ] OnboardingController - salvar dados do onboarding
- [ ] HomeController - navegação e stats
- [ ] LessonController - lógica dos exercícios
- [ ] ProfileController - edição de perfil

### Integrações Pendentes
- [ ] Firebase Auth
- [ ] Firebase Firestore
- [ ] Text-to-Speech (TTS)

---

## Links Úteis

- [Figma](https://www.figma.com/design/WcOkjqtenFTf802ZufPovx/Gemglot)
- [Steering Rules](../)

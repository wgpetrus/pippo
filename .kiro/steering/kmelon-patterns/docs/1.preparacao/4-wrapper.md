# Wrapper (Splash) - Pippo

> Tela inicial que decide para onde navegar

---

## Visual

```
┌─────────────────────────┐
│                         │
│                         │
│      [LOGO PIPPO]       │  ← SVG centralizado
│                         │
│                         │
│                         │
│    ○ (loading)          │  ← 48px do bottom
└─────────────────────────┘
```

---

## Implementação

```dart
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    Get.find<SplashController>();

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Center(
        child: SvgPicture.asset(
          AppAssets.logo,
          width: ResponsiveUtils.width(200, min: 150, max: 250),
          fit: BoxFit.contain,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: SizedBox(
            width: Get.height * 0.075,
            height: Get.height * 0.075,
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Lógica de Decisão

```dart
class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implementar lógica de autenticação
    // 1. Não autenticado? → /onboarding (primeiro acesso) ou /auth
    // 2. Autenticado, setup incompleto? → /setup
    // 3. Autenticado, setup completo? → /home

    Get.offAllNamed('/home');
  }
}
```

---

## Ordem de Verificação (a implementar)

1. **Não autenticado + primeiro acesso** → `/onboarding`
2. **Não autenticado + já tem conta** → `/auth`
3. **Autenticado + setup incompleto** → `/setup` (se existir)
4. **Autenticado + setup completo** → `/home`

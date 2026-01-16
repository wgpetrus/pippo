# Responsividade

> Referência: [code-rules.md](code-rules.md)
>
> Para theme e estilos, ver [styling-guide.md](styling-guide.md).

---

## Princípios

- **Mobile-first** — Projetar para mobile e adaptar para telas maiores
- **Breakpoints consistentes** — Usar breakpoints padronizados
- **Código enxuto** — Usar helper centralizado, sem lógica espalhada

---

## Arquivo Base

Criar `shared/utils/responsive.dart` em todos os projetos:

```dart
import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  
  Responsive(this.context);
  
  // MediaQuery
  MediaQueryData get _mq => MediaQuery.of(context);
  
  // Dimensões da tela
  double get width => _mq.size.width;
  double get height => _mq.size.height;
  
  // Breakpoints
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;
  
  // Orientação
  bool get isPortrait => _mq.orientation == Orientation.portrait;
  bool get isLandscape => _mq.orientation == Orientation.landscape;
  
  // SafeArea paddings (notch, status bar, navigation bar)
  EdgeInsets get safeAreaPadding => _mq.padding;
  double get topSafeArea => _mq.padding.top;
  double get bottomSafeArea => _mq.padding.bottom;
  double get leftSafeArea => _mq.padding.left;
  double get rightSafeArea => _mq.padding.right;
  
  // Keyboard
  double get keyboardHeight => _mq.viewInsets.bottom;
  bool get isKeyboardOpen => keyboardHeight > 0;
  
  // Text scaling (acessibilidade)
  double get textScaleFactor => _mq.textScaleFactor;
  
  // Valores responsivos baseados em porcentagem
  double wp(double percentage) => width * percentage / 100;
  double hp(double percentage) => height * percentage / 100;
  
  // Altura disponível (descontando SafeArea)
  double get availableHeight => height - topSafeArea - bottomSafeArea;
  double get availableWidth => width - leftSafeArea - rightSafeArea;
  
  // Espaçamentos responsivos
  double get spacing4 => isMobile ? 4 : 6;
  double get spacing8 => isMobile ? 8 : 12;
  double get spacing12 => isMobile ? 12 : 16;
  double get spacing16 => isMobile ? 16 : 20;
  double get spacing24 => isMobile ? 24 : 32;
  double get spacing32 => isMobile ? 32 : 40;
  double get spacing48 => isMobile ? 48 : 64;
  
  // Tamanhos de fonte responsivos (com limite para acessibilidade)
  double get fontSize10 => _limitFontSize(isMobile ? 10 : 12);
  double get fontSize12 => _limitFontSize(isMobile ? 12 : 14);
  double get fontSize14 => _limitFontSize(isMobile ? 14 : 16);
  double get fontSize16 => _limitFontSize(isMobile ? 16 : 18);
  double get fontSize18 => _limitFontSize(isMobile ? 18 : 20);
  double get fontSize20 => _limitFontSize(isMobile ? 20 : 24);
  double get fontSize24 => _limitFontSize(isMobile ? 24 : 28);
  double get fontSize32 => _limitFontSize(isMobile ? 32 : 40);
  
  // Limita font size para não quebrar layout com text scaling
  double _limitFontSize(double size) {
    final scaled = size * textScaleFactor;
    return scaled > size * 1.3 ? size * 1.3 : scaled;
  }
  
  // MaxWidth para desktop (evita layouts muito largos)
  double get maxContentWidth => isDesktop ? 1200 : width;
  
  // Valor baseado no tipo de dispositivo
  T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
  
  // Aspect ratio seguro
  double aspectRatio(double width, double height) => width / height;
}
```

---

## Uso nas Views

### Instanciar no Build

```dart
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.spacing16),
          child: Column(
            children: [
              Text(
                'Título',
                style: TextStyle(fontSize: r.fontSize24),
              ),
              SizedBox(height: r.spacing12),
              // ...
            ],
          ),
        ),
      ),
    );
  }
}
```

### SafeArea e Keyboard

```dart
// SafeArea automático
Scaffold(
  body: SafeArea(
    child: YourContent(),
  ),
)

// SafeArea manual (quando precisar customizar)
Padding(
  padding: EdgeInsets.only(
    top: r.topSafeArea,
    bottom: r.bottomSafeArea,
  ),
  child: YourContent(),
)

// Reagir ao teclado
AnimatedPadding(
  duration: Duration(milliseconds: 300),
  padding: EdgeInsets.only(bottom: r.keyboardHeight),
  child: YourForm(),
)

// Scroll quando teclado abrir
SingleChildScrollView(
  padding: EdgeInsets.only(bottom: r.keyboardHeight),
  child: YourForm(),
)
```

### Layouts Diferentes por Dispositivo

```dart
// Layout adaptativo
r.value(
  mobile: Column(children: [...]),
  tablet: Row(children: [...]),
  desktop: GridView(...),
)

// Condicional simples
if (r.isMobile)
  MobileLayout()
else if (r.isTablet)
  TabletLayout()
else
  DesktopLayout()
```

### Dimensões Responsivas

```dart
// Porcentagem da tela
Container(
  width: r.wp(80),  // 80% da largura
  height: r.hp(30), // 30% da altura
)

// Espaçamentos
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: r.spacing16,
    vertical: r.spacing24,
  ),
)

// Fontes
Text(
  'Texto',
  style: TextStyle(fontSize: r.fontSize16),
)
```

### MaxWidth para Desktop

```dart
// Centralizar conteúdo em desktop
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: r.maxContentWidth),
    child: YourContent(),
  ),
)

// Ou com Container
Container(
  width: double.infinity,
  constraints: BoxConstraints(maxWidth: r.maxContentWidth),
  child: YourContent(),
)
```

### Aspect Ratio

```dart
// Manter proporção de imagem/container
AspectRatio(
  aspectRatio: r.aspectRatio(16, 9),  // 16:9
  child: Image.network(url),
)

// Proporções comuns
aspectRatio: r.aspectRatio(1, 1),    // Quadrado
aspectRatio: r.aspectRatio(16, 9),   // Widescreen
aspectRatio: r.aspectRatio(4, 3),    // Padrão
aspectRatio: r.aspectRatio(3, 4),    // Retrato
```

---

## Breakpoints Padrão

| Dispositivo | Largura | Uso |
|-------------|---------|-----|
| Mobile | < 600px | Smartphones |
| Tablet | 600px - 1023px | Tablets, iPads |
| Desktop | ≥ 1024px | Desktops, laptops |

---

## Regras

- ✅ Sempre usar `Responsive` para dimensões e espaçamentos
- ✅ Sempre usar `SafeArea` ou considerar `topSafeArea`/`bottomSafeArea`
- ✅ Testar em múltiplos tamanhos (mobile, tablet, desktop)
- ✅ Usar `r.value()` para layouts diferentes
- ✅ Usar `SingleChildScrollView` em forms para evitar overflow com teclado
- ✅ Limitar largura em desktop com `maxContentWidth`
- ✅ Usar `AspectRatio` para manter proporções de imagens
- ❌ Nunca hardcodar valores de tamanho/espaçamento
- ❌ Nunca usar `MediaQuery` diretamente nas views
- ❌ Nunca ignorar SafeArea em telas com notch
- ❌ Nunca criar layouts que quebram com text scaling (acessibilidade)

---

## Casos Especiais

### Forms com Teclado

```dart
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(r.spacing16),
          child: Column(
            children: [
              // Form fields
            ],
          ),
        ),
      ),
    );
  }
}
```

### Bottom Sheet Responsivo

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) {
    final r = Responsive(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: r.keyboardHeight,  // Ajusta quando teclado abre
      ),
      child: Container(
        height: r.hp(80),  // 80% da altura
        padding: EdgeInsets.all(r.spacing16),
        child: YourContent(),
      ),
    );
  },
);
```

### Grid Responsivo

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: r.value(
      mobile: 2,
      tablet: 3,
      desktop: 4,
    ),
    crossAxisSpacing: r.spacing12,
    mainAxisSpacing: r.spacing12,
  ),
  itemBuilder: (context, index) => YourItem(),
)
```

### Imagens Responsivas

```dart
// Com aspect ratio
AspectRatio(
  aspectRatio: r.aspectRatio(16, 9),
  child: Image.network(
    url,
    fit: BoxFit.cover,
  ),
)

// Com dimensões fixas responsivas
Image.network(
  url,
  width: r.wp(90),
  height: r.hp(25),
  fit: BoxFit.cover,
)
```

### AppBar Responsivo

```dart
AppBar(
  toolbarHeight: r.value(
    mobile: 56,
    tablet: 64,
    desktop: 72,
  ),
  title: Text(
    'Título',
    style: TextStyle(fontSize: r.fontSize18),
  ),
)
```

---

## Testando Responsividade

### Dispositivos para Testar

| Dispositivo | Resolução | Tipo |
|-------------|-----------|------|
| iPhone SE | 375x667 | Mobile pequeno |
| iPhone 14 Pro | 393x852 | Mobile padrão |
| iPhone 14 Pro Max | 430x932 | Mobile grande |
| iPad Mini | 744x1133 | Tablet pequeno |
| iPad Air | 820x1180 | Tablet padrão |
| iPad Pro 12.9" | 1024x1366 | Tablet grande |
| Desktop HD | 1920x1080 | Desktop padrão |
| Desktop 4K | 3840x2160 | Desktop grande |

### Device Preview (Recomendado)

```dart
// pubspec.yaml
dependencies:
  device_preview: ^1.1.0

// main.dart (apenas em debug)
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(),
    ),
  );
}

// No MaterialApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      // ...
    );
  }
}
```

### Checklist de Testes

- [ ] Mobile portrait (375x667)
- [ ] Mobile landscape
- [ ] Tablet portrait (820x1180)
- [ ] Tablet landscape
- [ ] Desktop (1920x1080)
- [ ] Com teclado aberto (forms)
- [ ] Com text scaling aumentado (acessibilidade)
- [ ] Dispositivos com notch (SafeArea)
- [ ] Scroll em conteúdo longo
- [ ] Imagens mantêm proporção
- [ ] Textos não quebram layout
- [ ] Botões acessíveis em todos tamanhos

### Comandos Úteis

```bash
# Listar dispositivos disponíveis
flutter devices

# Rodar em dispositivo específico
flutter run -d <device_id>

# Rodar em Chrome (para testar desktop)
flutter run -d chrome

# Hot reload
r

# Hot restart
R
```

---

## Troubleshooting

### Overflow de Pixel

```dart
// ❌ ERRADO - pode dar overflow
Column(
  children: [
    Container(height: 300),
    Container(height: 400),
    Container(height: 500),
  ],
)

// ✅ CORRETO - usa scroll
SingleChildScrollView(
  child: Column(
    children: [
      Container(height: 300),
      Container(height: 400),
      Container(height: 500),
    ],
  ),
)
```

### Texto Cortado

```dart
// ❌ ERRADO - texto pode ser cortado
Text('Texto muito longo que pode ser cortado')

// ✅ CORRETO - texto quebra linha
Text(
  'Texto muito longo que pode ser cortado',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

### Layout Quebrado em Desktop

```dart
// ❌ ERRADO - muito largo em desktop
Container(
  width: double.infinity,
  child: YourContent(),
)

// ✅ CORRETO - limita largura
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: r.maxContentWidth),
    child: YourContent(),
  ),
)
```

### Teclado Sobrepõe Form

```dart
// ❌ ERRADO - teclado cobre campos
Scaffold(
  body: Column(
    children: [
      TextField(),
      TextField(),
      ElevatedButton(),
    ],
  ),
)

// ✅ CORRETO - scroll quando teclado abre
Scaffold(
  body: SingleChildScrollView(
    child: Column(
      children: [
        TextField(),
        TextField(),
        ElevatedButton(),
      ],
    ),
  ),
)
```

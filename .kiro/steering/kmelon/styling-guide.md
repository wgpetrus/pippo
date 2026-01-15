# Guia de Estilização

> Referência: [code-rules.md](code-rules.md)

---

## Theme e Fontes

### Centralizar em `shared/theme/theme.dart`

**NADA de nome de fonte espalhado nas telas.** Tudo centralizado em `shared/theme/theme.dart`.

```dart
// shared/theme/theme.dart
class AppTheme {
  static const fontFamily = 'nome-da-fonte';
  
  static const heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  // outros estilos...
}
```

```dart
// ✅ CORRETO - usa estilo do theme
Text('Título', style: AppTheme.heading1)

// ❌ ERRADO - fonte espalhada na view
Text('Título', style: TextStyle(fontFamily: 'nome-da-fonte', fontSize: 24))
```

---

## Ícones

### FontAwesome (Padrão)

**Apenas FontAwesome gratuito.**

```dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

FaIcon(FontAwesomeIcons.house)
FaIcon(FontAwesomeIcons.user)
```

Verificar se o ícone é gratuito antes de usar.

### Fluent UI System Icons (Alternativa)

Para ícones do sistema Microsoft Fluent Design.

```dart
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

Icon(FluentIcons.home_24_regular)
Icon(FluentIcons.person_24_filled)
```

**Link:** https://pub.dev/packages/fluentui_system_icons

---

## Packages de UI/UX

### Modals e Bottomsheets

#### wolt_modal_sheet

Bottomsheet moderno e customizável com múltiplas páginas.

```dart
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

WoltModalSheet.show(
  context: context,
  pageListBuilder: (context) => [
    WoltModalSheetPage(
      child: YourContent(),
    ),
  ],
);
```

**Link:** https://pub.dev/packages/wolt_modal_sheet

---

### Menus e Popovers

#### pie_menu

Menu circular (3 dots) para ações contextuais.

```dart
import 'package:pie_menu/pie_menu.dart';

PieMenu(
  actions: [
    PieAction(
      tooltip: Text('Editar'),
      onSelect: () => _edit(),
      child: Icon(Icons.edit),
    ),
    PieAction(
      tooltip: Text('Excluir'),
      onSelect: () => _delete(),
      child: Icon(Icons.delete),
    ),
  ],
  child: YourWidget(),
);
```

**Link:** https://pub.dev/packages/pie_menu

#### popover

Popover para exibir conteúdo flutuante (perfil, opções, etc).

```dart
import 'package:popover/popover.dart';

void _showProfilePopover(BuildContext context) {
  showPopover(
    context: context,
    bodyBuilder: (context) => _buildPopoverContent(context),
    direction: PopoverDirection.bottom,
    width: 200,
    arrowHeight: 10,
    arrowWidth: 20,
    backgroundColor: Colors.white,
    barrierColor: Colors.transparent,
    radius: 10,
  );
}
```

**Link:** https://pub.dev/packages/popover

---

### Inputs e Formatação

#### mask_text_input_formatter

Máscaras para inputs (telefone, CPF, data, etc).

```dart
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

var maskFormatter = MaskTextInputFormatter(
  mask: '+# (###) ###-##-##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

TextField(
  inputFormatters: [maskFormatter],
);
```

**Link:** https://pub.dev/packages/mask_text_input_formatter

#### pinput

Input de PIN/OTP estilizado.

```dart
import 'package:pinput/pinput.dart';

Pinput(
  length: 6,
  onCompleted: (pin) => _verifyOTP(pin),
);
```

**Link:** https://pub.dev/packages/pinput

---

### Switches e Toggles

#### toggle_switch

Switch customizável com múltiplas opções.

```dart
import 'package:toggle_switch/toggle_switch.dart';

ToggleSwitch(
  initialLabelIndex: 0,
  totalSwitches: 2,
  labels: ['Diário', 'Semanal'],
  onToggle: (index) {
    print('Selecionado: $index');
  },
);
```

**Link:** https://pub.dev/packages/toggle_switch

---

### Gráficos e Visualização

#### syncfusion_flutter_charts

Biblioteca completa de gráficos (linha, barra, pizza, etc).

```dart
import 'package:syncfusion_flutter_charts/charts.dart';

SfCartesianChart(
  primaryXAxis: CategoryAxis(),
  series: <ChartSeries>[
    LineSeries<ChartData, String>(
      dataSource: data,
      xValueMapper: (ChartData data, _) => data.x,
      yValueMapper: (ChartData data, _) => data.y,
    ),
  ],
);
```

**Link:** https://pub.dev/packages/syncfusion_flutter_charts

---

### Onboarding e Tutoriais

#### showcaseview

Tutorial interativo para destacar features do app.

```dart
import 'package:showcaseview/showcaseview.dart';

ShowCaseWidget(
  builder: Builder(
    builder: (context) => YourApp(),
  ),
);

Showcase(
  key: _key,
  description: 'Toque aqui para ver seu perfil',
  child: IconButton(
    icon: Icon(Icons.person),
    onPressed: () {},
  ),
);
```

**Link:** https://pub.dev/packages/showcaseview

---

## Utilitários

### uuid

Geração de IDs únicos. Usar **v5** para dados pessoais (determinístico).

```dart
import 'package:uuid/uuid.dart';

const uuid = Uuid();

// Para dados pessoais (sempre gera o mesmo ID para o mesmo input)
final userId = uuid.v5(Uuid.NAMESPACE_URL, 'url_do_cliente');

// Para IDs aleatórios
final randomId = uuid.v4();
```

**Regra:** Sempre usar `uuid.v5()` ao armazenar informação pessoal.

**Link:** https://pub.dev/packages/uuid

---

## Recursos

- **Flutter Gems:** https://fluttergems.dev/ — Marketplace de packages Flutter

# Componentes do Projeto

> Padrões visuais específicos do Pippo

---

## Análise de Telas (Figma/Imagens)

**Antes de implementar qualquer tela, verificar:**

1. **Widgets globais existentes** (`shared/widgets/`)
   - Botões → `AppButton`, `AppBackButton`
   - Inputs → `AppTextField`, `AppPinput`
   - AppBar → `AppAppbar`
   - Listas → `AppListItem`
   - Outros → verificar pasta

2. **Widgets da feature** (`feature/widgets/`)
   - Verificar se já existe widget similar na feature
   - Reutilizar antes de criar novo

3. **Theme** (`shared/theme/`)
   - Cores, fontes e estilos já definidos
   - Nunca hardcodar valores

### Checklist

Ao receber uma tela para implementar:

- [ ] Identificar todos os componentes visuais
- [ ] Mapear para widgets existentes
- [ ] Listar o que precisa ser criado
- [ ] Perguntar antes de criar widgets novos

### Regra

> **⚠️ Sempre perguntar antes de criar um widget novo.**
> 
> Pode ser que já exista algo similar ou que o componente deva ser global.

---

## AppAppbar (AppBar Padrão)

**Sempre usar `AppAppbar` para páginas internas com botão voltar.**

### Propriedades

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `title` | String | Título da página (obrigatório) |
| `showBack` | bool | Mostra botão voltar (default: true) |
| `onBack` | VoidCallback? | Ação customizada do botão voltar |
| `actions` | List<Widget>? | Widgets à direita (ex: botão Save) |
| `centerTitle` | bool | Centraliza título (default: false) |

### Uso

```dart
// AppBar simples
AppAppbar(title: 'Settings')

// AppBar com ação Save
AppAppbar(
  title: 'Profile',
  actions: [
    TextButton(
      onPressed: _save,
      child: Text('Save', style: AppTheme.textMdBold.copyWith(color: AppTheme.primary)),
    ),
  ],
)

// AppBar sem botão voltar (tabs principais)
AppBar(
  backgroundColor: AppTheme.white,
  surfaceTintColor: AppTheme.white,
  elevation: 0,
  automaticallyImplyLeading: false,
  title: const Text('Shop', style: AppTheme.displaySmBold),
  titleSpacing: 20,
)
```

### Proibido

```dart
// ❌ ERRADO - AppBar com estilos inconsistentes
AppBar(
  title: Text('Título', style: AppTheme.textXlBold),  // usar displaySmBold
)

// ❌ ERRADO - criar AppBar manual quando AppAppbar resolve
AppBar(
  leading: const AppBackButton(),
  title: Text('Settings'),
  // ... muitas linhas
)
```

---

## AppButton (Botão Padrão)

**Sempre usar `AppButton` para botões de ação no app.**

### Propriedades

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `text` | String | Texto do botão (obrigatório) |
| `onPressed` | VoidCallback? | Ação ao clicar (null = desabilitado) |
| `isPrimary` | bool | true = verde, false = branco com borda |
| `isLoading` | bool | Mostra loading spinner |
| `prefixIcon` | Widget? | Ícone antes do texto |
| `suffixIcon` | Widget? | Ícone depois do texto |

### Uso

```dart
// Botão primário (verde)
AppButton(
  text: 'Continue',
  onPressed: () => _submit(),
)

// Botão secundário (branco)
AppButton(
  text: 'Cancel',
  isPrimary: false,
  onPressed: () => Get.back(),
)

// Botão desabilitado
AppButton(
  text: 'Continue',
  onPressed: null,
)

// Botão com loading
AppButton(
  text: 'Continue',
  isLoading: controller.isLoading.value,
  onPressed: controller.isLoading.value ? null : () => _submit(),
)

// Botão com ícone
AppButton(
  text: 'Sign in with Google',
  prefixIcon: FaIcon(FontAwesomeIcons.google, size: 18),
  onPressed: () => _signInWithGoogle(),
)
```

### Proibido

```dart
// ❌ ERRADO - ElevatedButton padrão
ElevatedButton(onPressed: () {}, child: Text('Continue'))

// ❌ ERRADO - TextButton para ações principais
TextButton(onPressed: () {}, child: Text('Continue'))
```

---

## AppBackButton (Botão Voltar)

Widget global para botão voltar circular verde.

### Especificação

| Propriedade | Valor |
|-------------|-------|
| Formato | Círculo |
| Tamanho | 40x40 |
| Cor de fundo | `AppTheme.primary` |
| Ícone | `FontAwesomeIcons.arrowLeft` |
| Cor do ícone | `AppTheme.white` |

### Uso

```dart
// Dentro de AppAppbar (automático)
AppAppbar(title: 'Settings')

// Manual quando necessário
AppBackButton(onPressed: () => _customAction())
```

---

## AppListItem (Item de Lista)

**Usar para menus de configurações e listas de opções.**

### Propriedades

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `label` | String | Texto do item (obrigatório) |
| `icon` | IconData? | Ícone à esquerda (opcional) |
| `trailing` | Widget? | Widget à direita (ex: Switch, Text) |
| `onTap` | VoidCallback? | Ação ao clicar |
| `enabled` | bool | Habilita/desabilita item |
| `showChevron` | bool | Mostra seta quando tem onTap |

### Uso

```dart
// Item com ícone e navegação
AppListItem(
  icon: FontAwesomeIcons.solidUser,
  label: 'Profile',
  onTap: () => Get.to(() => ProfilePage()),
)

// Item com Switch
AppListItem(
  icon: FontAwesomeIcons.solidBell,
  label: 'Notifications',
  trailing: Switch(value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
)

// Item sem ícone (para listas simples)
AppListItem(
  label: 'Practice reminders',
  showChevron: false,
  trailing: Switch(...),
)

// Item desabilitado
AppListItem(
  label: 'Reminder time',
  enabled: false,
  trailing: Text('6:00 AM'),
)
```

### Proibido

```dart
// ❌ ERRADO - criar widgets de lista customizados
ListTile(...)
Container(child: Row(...))
```

# Estrutura do Projeto

> Referência: [code-rules.md](code-rules.md)

---

## Organização de Arquivos

### Cada Page na Sua Feature

**NUNCA** colocar todas as pages dentro de `home/`. Cada page pertence à sua feature.
**NUNCA** criar models, repository, services. **SEMPRE** perguntar se pode criar.

```
# ✅ CORRETO - cada page na sua feature
features/core/professionals/views/
└── favorites_page.dart

features/inners/settings/views/
└── profile_page.dart

# ❌ ERRADO - tudo em home
features/inners/home/views/
├── favorites_page.dart      # ERRADO!
├── profile_page.dart        # ERRADO!
└── appointments_page.dart   # ERRADO!
```

### Verificar Sempre

Antes de criar/mover arquivo, perguntar:
1. Este arquivo pertence a qual feature?
2. É uma view, page, controller, widget?
3. Está na pasta correta dessa feature?

---

## Ordem de Imports

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Packages externos
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 4. Imports locais
import '../controllers/auth_controller.dart';
import '../../shared/widgets/app_button.dart';
```

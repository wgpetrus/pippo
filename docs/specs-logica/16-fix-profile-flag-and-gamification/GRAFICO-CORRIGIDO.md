# Correção: Gráfico Semanal Não Atualizava ao Trocar Curso

## 🎯 Problema

**Sintoma:** Ao trocar de curso, o gráfico semanal permanecia com os mesmos dados.

**Causa:** O método `_loadUserWeeklyProgress()` buscava dados da estrutura ANTIGA (`users/{userId}/stats/dailyHistory/days/`) ao invés da estrutura NOVA (`users/{userId}/courses/{courseId}/stats/dailyHistory/days/`).

---

## ✅ Solução

### Método `_loadUserWeeklyProgress()` - CORRIGIDO

**ANTES:**
```dart
Future<List<Map<String, dynamic>>> _loadUserWeeklyProgress(String userId) async {
  // ... cálculo de datas ...
  
  // ❌ ERRADO - estrutura antiga
  final dayDoc = await _firestore
      .collection('users')
      .doc(userId)
      .collection('stats')
      .doc('dailyHistory')
      .collection('days')
      .doc(dateStr)
      .get();
}
```

**DEPOIS:**
```dart
Future<List<Map<String, dynamic>>> _loadUserWeeklyProgress(String userId) async {
  // 1. Buscar curso ativo
  final coursesSnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .where('isActive', isEqualTo: true)
      .limit(1)
      .get();

  if (coursesSnapshot.docs.isEmpty) {
    return _getEmptyWeek(); // Retorna semana vazia
  }

  final courseId = coursesSnapshot.docs.first.id;
  
  // 2. Buscar dados do dia (estrutura NOVA)
  final dayDoc = await _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId)  // ✅ CORRETO - do curso ativo
      .collection('stats')
      .doc('dailyHistory')
      .collection('days')
      .doc(dateStr)
      .get();
}
```

---

## 📊 Novo Método: `_getEmptyWeek()`

Retorna uma semana vazia quando não há curso ativo:

```dart
List<Map<String, dynamic>> _getEmptyWeek() {
  final now = DateTime.now();
  final currentWeekday = now.weekday;
  final daysToSunday = currentWeekday == 7 ? 0 : currentWeekday;
  final sunday = now.subtract(Duration(days: daysToSunday));
  
  final weekDays = <Map<String, dynamic>>[];
  
  for (int i = 0; i < 7; i++) {
    final date = sunday.add(Duration(days: i));
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    weekDays.add({
      'date': dateStr,
      'day': _getDayAbbreviation(date.weekday),
      'xp': 0,
    });
  }
  
  return weekDays;
}
```

---

## 🧪 Teste

### Cenário: Trocar de Curso e Verificar Gráfico

1. **Curso Chinês (ativo):**
   - Completar lições nos últimos 3 dias
   - Verificar que gráfico mostra barras com XP

2. **Trocar para Curso Alemão:**
   - Curso novo, sem XP
   - Verificar que gráfico mostra barras vazias (XP=0)

3. **Voltar para Curso Chinês:**
   - Verificar que gráfico mostra barras com XP novamente

---

## ✅ Resultado

**Agora o gráfico:**
- ✅ Mostra dados do curso ativo
- ✅ Atualiza ao trocar de curso
- ✅ Mostra semana vazia se não houver curso ativo
- ✅ Restaura dados ao voltar para curso anterior

---

## 📝 Arquivo Modificado

- `lib/features/inners/profile/controllers/profile_controller.dart`
  - Método `_loadUserWeeklyProgress()` - atualizado
  - Método `_getEmptyWeek()` - novo

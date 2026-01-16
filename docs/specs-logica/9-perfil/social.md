# Perfil - Sistema Social

> Lógica de follow/unfollow e interações sociais

---

## Follow/Unfollow

### Seguir Usuário

```dart
Future<void> followUser(String targetUserId) async {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  
  // 1. Adicionar à lista de following do usuário atual
  await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .update({
    'following': FieldValue.arrayUnion([targetUserId]),
    'followingCount': FieldValue.increment(1),
  });
  
  // 2. Adicionar à lista de followers do outro usuário
  await FirebaseFirestore.instance
      .collection('users')
      .doc(targetUserId)
      .update({
    'followers': FieldValue.arrayUnion([currentUserId]),
    'followersCount': FieldValue.increment(1),
  });
  
  // 3. Atualizar UI
  isFollowing.value = true;
  followingCount++;
  
  // 4. Enviar notificação (opcional)
  await sendFollowNotification(targetUserId);
}
```

### Deixar de Seguir

```dart
Future<void> unfollowUser(String targetUserId) async {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  
  // 1. Remover da lista de following
  await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .update({
    'following': FieldValue.arrayRemove([targetUserId]),
    'followingCount': FieldValue.increment(-1),
  });
  
  // 2. Remover da lista de followers
  await FirebaseFirestore.instance
      .collection('users')
      .doc(targetUserId)
      .update({
    'followers': FieldValue.arrayRemove([currentUserId]),
    'followersCount': FieldValue.increment(-1),
  });
  
  // 3. Atualizar UI
  isFollowing.value = false;
  followingCount--;
}
```

---

## Verificar se Segue

```dart
Future<bool> isFollowingUser(String targetUserId) async {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .get();
  
  final following = List<String>.from(doc.data()?['following'] ?? []);
  
  return following.contains(targetUserId);
}
```

---

## Perfil de Outro Usuário

### Diferenças do Perfil Próprio

**Não mostrar:**
- Botão Settings
- Card "Complete Profile"
- Gems e energia (dados privados)

**Mostrar:**
- Botão "Seguir" ou "Seguindo"
- Botão "Mensagem" (futuro)

**Gráfico comparativo:**
- Duas linhas: você vs usuário
- Cores diferentes
- Legenda

---

## Completar Perfil

### Verificação

```dart
bool isProfileComplete() {
  return bio != null && 
         bio!.isNotEmpty &&
         phone != null &&
         phoneVerified == true &&
         avatarId != 'avatar_01'; // não é avatar padrão
}

List<String> getMissingItems() {
  final missing = <String>[];
  
  if (bio == null || bio!.isEmpty) {
    missing.add('Bio');
  }
  
  if (phone == null || !phoneVerified) {
    missing.add('Telefone verificado');
  }
  
  if (avatarId == 'avatar_01') {
    missing.add('Avatar personalizado');
  }
  
  return missing;
}
```

### Card "Complete Your Profile"

Mostrar apenas se `!isProfileComplete()`:

```dart
if (!isProfileComplete()) {
  CompleteProfileCard(
    missingItems: getMissingItems(),
    onTap: () => Get.to(() => EditProfilePage()),
  );
}
```

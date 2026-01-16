# Perfil - Edição e Configurações

> Lógica de edição de perfil e configurações

---

## Editar Perfil

### Validações

**Username:**
```dart
String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Username é obrigatório';
  }
  
  if (value.length < 3) {
    return 'Username deve ter pelo menos 3 caracteres';
  }
  
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
    return 'Apenas letras, números e underscore';
  }
  
  return null;
}

Future<bool> isUsernameAvailable(String username) async {
  // Verificar se já existe no Firestore
  final query = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username)
      .get();
  
  return query.docs.isEmpty;
}
```

**Name:**
```dart
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Nome é obrigatório';
  }
  
  if (value.length < 2) {
    return 'Nome deve ter pelo menos 2 caracteres';
  }
  
  if (value.length > 50) {
    return 'Nome deve ter no máximo 50 caracteres';
  }
  
  return null;
}
```

**Bio:**
```dart
String? validateBio(String? value) {
  if (value != null && value.length > 150) {
    return 'Bio deve ter no máximo 150 caracteres';
  }
  
  return null;
}
```

---

## Salvar Perfil

```dart
Future<void> updateProfile({
  String? name,
  String? username,
  String? bio,
  String? avatarId,
  String? country,
}) async {
  // 1. Validar campos
  if (name != null && validateName(name) != null) {
    throw Exception('Nome inválido');
  }
  
  if (username != null) {
    if (validateUsername(username) != null) {
      throw Exception('Username inválido');
    }
    
    // Verificar se username mudou
    if (username != currentUser.username) {
      // Verificar se está disponível
      if (!await isUsernameAvailable(username)) {
        throw Exception('Username já está em uso');
      }
    }
  }
  
  // 2. Atualizar no Firestore
  final updates = <String, dynamic>{
    'updatedAt': FieldValue.serverTimestamp(),
  };
  
  if (name != null) updates['name'] = name;
  if (username != null) updates['username'] = username;
  if (bio != null) updates['bio'] = bio;
  if (avatarId != null) updates['avatarId'] = avatarId;
  if (country != null) updates['country'] = country;
  
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update(updates);
  
  // 3. Atualizar localmente
  currentUser = currentUser.copyWith(
    name: name,
    username: username,
    bio: bio,
    avatarId: avatarId,
    country: country,
  );
  
  // 4. Mostrar sucesso
  showSuccessMessage('Perfil atualizado com sucesso!');
  
  // 5. Voltar para ProfilePage
  Get.back();
}
```

---

## Alterar Senha

### Validações

```dart
String? validateCurrentPassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Senha atual é obrigatória';
  }
  return null;
}

String? validateNewPassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Nova senha é obrigatória';
  }
  
  if (value.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  
  return null;
}

String? validateConfirmPassword(String? value, String newPassword) {
  if (value == null || value.isEmpty) {
    return 'Confirme a nova senha';
  }
  
  if (value != newPassword) {
    return 'As senhas não coincidem';
  }
  
  return null;
}
```

### Processo

```dart
Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  // 1. Validar campos
  if (validateNewPassword(newPassword) != null) {
    throw Exception('Nova senha inválida');
  }
  
  if (validateConfirmPassword(confirmPassword, newPassword) != null) {
    throw Exception('Senhas não coincidem');
  }
  
  // 2. Reautenticar usuário
  final user = FirebaseAuth.instance.currentUser!;
  final credential = EmailAuthProvider.credential(
    email: user.email!,
    password: currentPassword,
  );
  
  try {
    await user.reauthenticateWithCredential(credential);
  } catch (e) {
    throw Exception('Senha atual incorreta');
  }
  
  // 3. Atualizar senha
  await user.updatePassword(newPassword);
  
  // 4. Mostrar sucesso
  showSuccessMessage('Senha alterada com sucesso!');
  
  // 5. Voltar para SettingsPage
  Get.back();
}
```

---

## Vincular Telefone

### Formatação de Telefone

**Nota**: Usar `mask_text_input_formatter` package para máscara de telefone:

```dart
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

var phoneFormatter = MaskTextInputFormatter(
  mask: '+## (##) #####-####',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

TextField(
  controller: _phoneController,
  inputFormatters: [phoneFormatter],
  keyboardType: TextInputType.phone,
);
```

### Processo

```dart
Future<void> linkPhoneNumber(String phoneNumber) async {
  // 1. Formatar número com código do país
  final formattedNumber = formatPhoneNumber(phoneNumber);
  
  // 2. Enviar SMS via Firebase Phone Auth
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: formattedNumber,
    verificationCompleted: (credential) async {
      // Auto-verificação (Android)
      await linkCredential(credential);
    },
    verificationFailed: (error) {
      showErrorMessage('Erro ao enviar código');
    },
    codeSent: (verificationId, resendToken) {
      // Salvar verificationId temporariamente
      this.verificationId = verificationId;
      
      // Navegar para VerifyPhonePage
      Get.to(() => VerifyPhonePage());
    },
    codeAutoRetrievalTimeout: (verificationId) {},
  );
}

Future<void> verifyPhoneCode(String code) async {
  // 1. Criar credential
  final credential = PhoneAuthProvider.credential(
    verificationId: verificationId!,
    smsCode: code,
  );
  
  // 2. Vincular ao usuário atual
  await linkCredential(credential);
}

Future<void> linkCredential(PhoneAuthCredential credential) async {
  final user = FirebaseAuth.instance.currentUser!;
  
  // Vincular credential
  await user.linkWithCredential(credential);
  
  // Salvar telefone no Firestore
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update({
    'phone': credential.phoneNumber,
    'phoneVerified': true,
  });
  
  // Navegar para PhoneLinkedPage
  Get.to(() => PhoneLinkedPage());
}
```

---

## Excluir Conta

### Processo

```dart
Future<void> deleteAccount() async {
  // 1. Mostrar confirmações (2 modais)
  final confirmed = await showDeleteConfirmation();
  if (!confirmed) return;
  
  final finalConfirmed = await showFinalConfirmation();
  if (!finalConfirmed) return;
  
  // 2. Deletar dados do Firestore
  await deleteUserData();
  
  // 3. Deletar conta do Auth
  await FirebaseAuth.instance.currentUser!.delete();
  
  // 4. Limpar dados locais
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
  // 5. Navegar para auth
  Get.offAllNamed('/auth');
}

Future<void> deleteUserData() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  
  // Deletar documento do usuário
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .delete();
  
  // Deletar subcoleções (courses, progress, history, etc)
  // Usar Cloud Function para deletar subcoleções
  await FirebaseFunctions.instance
      .httpsCallable('deleteUserData')
      .call({'userId': userId});
}
```

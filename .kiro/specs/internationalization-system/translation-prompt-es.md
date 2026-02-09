# Prompt de Traducción al Español - Pippo App

## Contexto

Pippo es una aplicación de aprendizaje de idiomas similar a Duolingo. Los usuarios aprenden nuevos idiomas a través de lecciones interactivas, ejercicios gamificados, y un sistema de progresión con XP, gemas, y rachas diarias.

La aplicación incluye:
- **Autenticación**: Login, registro, recuperación de contraseña
- **Onboarding**: Flujo de bienvenida para nuevos usuarios (selección de idioma, nivel, motivación, etc.)
- **Lecciones**: Ejercicios interactivos (traducción, imágenes, palabras, emparejamiento)
- **Home**: Navegación principal con tabs (Cursos, Ranking, Tienda, Misiones, Perfil)
- **Gamificación**: Sistema de energía, gemas, rachas, XP, niveles
- **Perfil**: Configuraciones, estadísticas, gestión de cuenta
- **Social**: Ranking de ligas, amigos, competencia

## Instrucciones de Traducción

1. **Tono y Estilo**:
   - Mantener un tono amigable, motivador y juvenil
   - Usar lenguaje natural y conversacional
   - Mantener la energía y entusiasmo del original
   - Adaptar expresiones culturales cuando sea necesario

2. **Términos Técnicos**:
   - "Streak" → "Racha" (días consecutivos)
   - "XP" → mantener "XP" (experiencia)
   - "Gems" → "Gemas"
   - "Energy" → "Energía"
   - "Boost" → "Impulso" o mantener "Boost"
   - "League" → "Liga"

3. **Formato**:
   - Mantener placeholders exactamente como están: {lang}, {count}, {current}, {total}, {time}, {energy}, {language}, {xp}
   - Preservar saltos de línea (\n) donde aparezcan
   - Mantener emojis y símbolos especiales
   - No traducir nombres propios (Pippo, Gem)

4. **Consistencia**:
   - Usar las mismas traducciones para términos repetidos
   - Mantener coherencia en el tratamiento formal/informal (usar "tú" informal)
   - Ser consistente con mayúsculas en títulos


## Traducciones Requeridas

A continuación se presentan todas las claves de traducción del portugués brasileño (pt_BR) que deben ser traducidas al español (es_ES):

### Auth Section

```
'auth_cancel_button': 'Cancelar',
'auth_confirm_password_hint': 'Digite sua senha novamente',
'auth_confirm_password_label': 'Confirmar senha',
'auth_email_hint': 'digite seu usuário / e-mail',
'auth_email_label': 'Usuário / e-mail',
'auth_facebook_button': 'Facebook',
'auth_forgot_password': 'Esqueceu sua senha',
'auth_forgot_password_description': 'Digite seu e-mail para receber um link de recuperação de senha.',
'auth_forgot_password_title': 'Esqueci minha senha',
'auth_gmail_button': 'Gmail',
'auth_login_with_email_button': 'Fazer login com e-mail',
'auth_new_password_description': 'Crie uma nova senha para sua conta.',
'auth_new_password_hint': 'Digite sua nova senha',
'auth_new_password_label': 'Nova senha',
'auth_new_password_title': 'Nova senha',
'auth_password_hint': 'digite sua senha',
'auth_password_label': 'Senha',
'auth_remembered_password': 'Lembrei minha senha',
'auth_reset_password_button': 'Redefinir senha',
'auth_send_link_button': 'Enviar link',
'auth_signin_button': 'Entrar',
'auth_signin_title': 'Entrar',
'auth_verify_button': 'Verificar',
'auth_verify_code_description': 'Digite o código de 5 dígitos que enviamos para seu e-mail.',
'auth_verify_code_title': 'Verificar código',
```


### Onboarding Section (Part 1)

```
'onboarding_conclusion_button': 'Vamos Aprender',
'onboarding_conclusion_button_cancel': 'Cancelar',
'onboarding_conclusion_subtitle': 'Seu curso está pronto e esperando — a apenas um clique.',
'onboarding_conclusion_title': 'Estava te esperando! Vamos nos divertir.',
'onboarding_header_exit_button': 'Sair',
'onboarding_header_exit_dialog_cancel': 'Continuar Cadastro',
'onboarding_header_exit_dialog_confirm': 'Sair',
'onboarding_header_exit_dialog_message': 'Você perderá todo o progresso do cadastro.',
'onboarding_header_exit_dialog_title': 'Sair do Cadastro?',
'onboarding_intro_button': 'Começar',
'onboarding_intro_mascot_greeting': 'Oi! Eu sou o Gem!',
'onboarding_intro_mascot_lets_go': 'Vamos juntos!',
'onboarding_intro_subtitle': 'Só mais alguns passos e você está dentro!',
'onboarding_intro_title': 'Comece Sua Aventura!',
'onboarding_language_level_basic_conversations': 'Consigo ter conversas básicas',
'onboarding_language_level_bubble': 'Como você avalia seu nível?',
'onboarding_language_level_fluent': 'Falo, leio e escrevo com facilidade',
'onboarding_language_level_grammar_reading': 'Entendo gramática e leio confortavelmente',
'onboarding_language_level_new': 'Sou novo em {lang}',
'onboarding_language_level_some_words': 'Sei algumas palavras',
'onboarding_language_level_title': 'Nível do Idioma',
'onboarding_learning_reason_bubble': 'Por que você quer aprender {lang}?',
'onboarding_learning_reason_connect_people': 'Quero me conectar com pessoas.',
'onboarding_learning_reason_enjoy_media': 'Quero curtir filmes, músicas e livros.',
'onboarding_learning_reason_explore_world': 'Quero explorar o mundo.',
'onboarding_learning_reason_love_learning': 'Adoro aprender coisas novas.',
'onboarding_learning_reason_other': 'Outro',
'onboarding_learning_reason_other_modal_confirm': 'Confirmar',
'onboarding_learning_reason_other_modal_hint': 'Escreva seu motivo aqui...',
'onboarding_learning_reason_other_modal_label': 'Conte-nos seu motivo',
'onboarding_learning_reason_other_modal_title': 'Outro Motivo',
'onboarding_learning_reason_speak_confidently': 'Quero falar sem medo.',
'onboarding_learning_reason_title': 'Motivo para Aprender',
'onboarding_learning_reason_work_study': 'Preciso para trabalho ou estudo.',
```


### Onboarding Section (Part 2)

```
'onboarding_pause_one_button': 'Próximo',
'onboarding_pause_one_subtitle': 'Escolha seu ritmo, trace seu caminho e desbloqueie um mundo de palavras. Cada escolha que você faz constrói sua missão pessoal—pronto para começar?',
'onboarding_pause_one_title': 'Vamos criar sua jornada de aprendizado!',
'onboarding_pause_two_button': 'Vamos lá',
'onboarding_pause_two_subtitle': 'Leva só um momento para desbloquear sua jornada!',
'onboarding_pause_two_title': 'Pronto para Começar Sua Aventura?',
'onboarding_select_language_arabic': 'Árabe',
'onboarding_select_language_bubble': 'Qual idioma você quer aprender?',
'onboarding_select_language_chinese': 'Chinês',
'onboarding_select_language_english': 'Inglês',
'onboarding_select_language_french': 'Francês',
'onboarding_select_language_german': 'Alemão',
'onboarding_select_language_japanese': 'Japonês',
'onboarding_select_language_portuguese': 'Português',
'onboarding_select_language_spanish': 'Espanhol',
'onboarding_select_language_title': 'Selecionar Idioma',
'onboarding_study_time_10min': '10 min / dia',
'onboarding_study_time_15min': '15 min / dia',
'onboarding_study_time_20min': '20 min / dia',
'onboarding_study_time_30min': '30 min / dia',
'onboarding_study_time_40min': '40 min / dia',
'onboarding_study_time_5min': '5 min / dia',
'onboarding_study_time_bubble': 'Escolha sua meta diária de aprendizado',
'onboarding_study_time_title': 'Tempo de Estudo',
'onboarding_user_age_hint': 'digite sua idade',
'onboarding_user_age_label': 'Idade',
'onboarding_user_age_question': 'Quantos anos você tem?',
'onboarding_user_email_error_invalid': 'E-mail inválido',
'onboarding_user_email_hint': 'digite seu e-mail',
'onboarding_user_email_label': 'E-mail',
'onboarding_user_email_question': 'Qual é o seu e-mail?',
'onboarding_user_name_hint': 'digite seu nome',
'onboarding_user_name_label': 'Nome',
'onboarding_user_name_question': 'Qual é o seu nome?',
'onboarding_user_password_button_cancel': 'Cancelar',
'onboarding_user_password_button_have_account': 'Já tenho uma conta',
'onboarding_user_password_confirm_hint': 'repita sua senha',
'onboarding_user_password_confirm_label': 'Confirmar Senha',
'onboarding_user_password_error_mismatch': 'As senhas não coincidem.',
'onboarding_user_password_hint': 'digite sua senha',
'onboarding_user_password_label': 'Senha',
'onboarding_user_password_title': 'Crie sua senha mágica',
'onboarding_verify_code_button_cancel': 'Cancelar',
'onboarding_verify_code_button_verify': 'Verify',
'onboarding_verify_code_debug_banner_subtitle': 'Use test code 00000 to skip verification',
'onboarding_verify_code_debug_banner_title': '🔓 DEBUG MODE',
'onboarding_verify_code_subtitle': 'We\'ve sent a 5-digit code to your e-mail. Enter it below to unlock your next adventure!',
'onboarding_verify_code_title': 'One step closer to your streak!',
'onboarding_welcome_button_have_account': 'Já tenho uma conta',
'onboarding_welcome_button_start': 'Começar',
'onboarding_welcome_title': 'Pronto para Começar sua Aventura?',
```


### Nota sobre las Secciones Restantes

Las siguientes secciones también deben ser traducidas siguiendo las mismas pautas:

- **Lesson Section**: ~40 claves relacionadas con ejercicios, retroalimentación, y completar lecciones
- **Home Section**: ~50 claves para navegación, modales de energía/gemas/racha, y tabs
- **Leaderboard Section**: ~20 claves para ligas, ranking, y competencia
- **Shop Section**: ~35 claves para tienda, boosts, y compras
- **Treasure Section**: ~30 claves para desafíos y misiones
- **Profile Section**: ~80 claves para perfil, configuraciones, y gestión de cuenta
- **Common Section**: ~30 claves comunes reutilizables
- **Error Section**: ~7 claves de mensajes de error

**Total**: Aproximadamente 350+ claves de traducción

## Formato de Salida Esperado

Por favor, proporciona las traducciones en el siguiente formato Dart:

```dart
class EsES {
  static const Map<String, String> translations = {
    // Auth Section
    'auth_cancel_button': '[traducción]',
    'auth_confirm_password_hint': '[traducción]',
    // ... etc
  };
}
```

## Verificación de Calidad

Antes de finalizar, verifica:
- ✅ Todos los placeholders están intactos
- ✅ El tono es consistente y natural
- ✅ Los términos técnicos están traducidos correctamente
- ✅ No hay errores ortográficos
- ✅ El formato Dart es válido
- ✅ Todas las claves están presentes


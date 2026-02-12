# Implementation Plan: Correção de Bugs Fevereiro 2026

## Overview

Plano SIMPLIFICADO para correção de bugs críticos, remoção de código duplicado e implementação de traduções. Foco em soluções diretas sem complexidade desnecessária.

**Estimativa:** 8-12 horas

## Tasks

### Fase 1: Bugs Críticos (URGENTE - 3-4h)

- [x] 1. Corrigir Lesson Flow Controller (race condition de auth)
  - [x] 1.1 Refatorar lesson_flow_controller.dart
    - Substituir múltiplas verificações de auth por uma única no início do método startLesson()
    - Usar padrão: `final user = _auth.currentUser; if (user == null) { errorMessage.value = 'error_unauthenticated'.tr; return; }`
    - Remover TODOS os delays artificiais de 100ms
    - Remover verificações repetidas de autenticação
    - Adicionar try-catch em operações Firestore
    - Implementar onClose() para limpar recursos
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 5.1, 5.2, 5.3_
  
  - [x] 1.2 Escrever unit tests
    - Testar verificação única de auth no início
    - Testar que não há race condition
    - Testar tratamento de erros Firestore
    - Testar onClose() limpa recursos
    - _Requirements: 1.1, 1.2, 1.4_

- [x] 2. Corrigir Splash Controller (null pointer)
  - [x] 2.1 Refatorar splash_controller.dart
    - Substituir `_auth.currentUser!.uid` por verificação segura
    - Usar padrão: `final user = _auth.currentUser; if (user == null) { errorMessage.value = 'error_unauthenticated'.tr; _navigateToAuth(); return; }`
    - Adicionar try-catch em operações Firestore
    - Implementar onClose() para limpar recursos
    - _Requirements: 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 5.1, 5.2, 5.3_
  
  - [x] 2.2 Escrever unit tests
    - Testar navegação quando usuário é null
    - Testar que não crasha com null pointer
    - Testar navegação quando usuário é válido
    - _Requirements: 2.1, 2.2, 2.3_

- [x] 3. Adicionar try-catch em Profile Controllers
  - [x] 3.1 Refatorar profile_data_controller.dart
    - Adicionar try-catch em TODAS as operações Firestore
    - Usar ErrorHandler.getFirestoreErrorMessage() para erros
    - Implementar onClose()
    - _Requirements: 3.1, 3.2, 3.3, 5.1, 5.2, 5.3_
  
  - [x] 3.2 Refatorar profile_social_controller.dart
    - Adicionar try-catch em TODAS as operações Firestore
    - Implementar onClose()
    - _Requirements: 3.1, 3.2, 3.3, 5.1, 5.2, 5.3_
  
  - [x] 3.3 Refatorar profile_auth_controller.dart
    - Adicionar try-catch em TODAS as operações Firestore
    - Implementar onClose()
    - _Requirements: 3.1, 3.2, 3.3, 5.1, 5.2, 5.3_
  
  - [x] 3.4 Refatorar profile_search_controller.dart
    - Adicionar try-catch em TODAS as operações Firestore
    - Implementar onClose()
    - _Requirements: 3.1, 3.2, 3.3, 5.1, 5.2, 5.3_
  
  - [x] 3.5 Refatorar profile_settings_controller.dart
    - Adicionar try-catch em TODAS as operações Firestore
    - Implementar onClose()
    - _Requirements: 3.1, 3.2, 3.3, 5.1, 5.2, 5.3_
  
  - [x] 3.6 Refatorar profile_courses_controller.dart
    - Adicionar try-catch em TODAS as operações Firestore
    - Implementar onClose()
    - _Requirements: 3.1, 3.2, 3.3, 5.1, 5.2, 5.3_
  
  - [x] 3.7 Escrever unit tests para Profile Controllers
    - Testar try-catch em operações Firestore
    - Testar uso correto de ErrorHandler
    - Testar onClose() limpa recursos
    - _Requirements: 3.1, 3.2, 3.3_

- [x] 4. Checkpoint - Validar bugs críticos corrigidos
  - Rodar todos os testes
  - Verificar que app não crasha mais

### Fase 2: Remoção de Duplicação (2-3h)

- [x] 5. Remover handlers duplicados em auth_credentials_controller
  - [x] 5.1 Refatorar auth_credentials_controller.dart
    - REMOVER método _handleFirebaseLoginError
    - REMOVER método _handleFirebaseRegisterError
    - Substituir chamadas por ErrorHandler.getLoginErrorMessage()
    - Substituir chamadas por ErrorHandler.getRegisterErrorMessage()
    - _Requirements: 4.1, 4.2_
  
  - [x] 5.2 Escrever unit tests
    - Testar uso correto de ErrorHandler.getLoginErrorMessage()
    - Testar uso correto de ErrorHandler.getRegisterErrorMessage()
    - Verificar ausência de handlers duplicados
    - _Requirements: 4.1, 4.2_

- [x] 6. Remover wrappers desnecessários de _handleFirestoreError
  - [x] 6.1 Refatorar 18 controllers
    - REMOVER método _handleFirestoreError de:
      - treasure_rewards_controller.dart
      - treasure_challenges_controller.dart
      - profile_settings_controller.dart
      - profile_social_controller.dart
      - profile_search_controller.dart
      - profile_data_controller.dart
      - profile_courses_controller.dart
      - shop_controller.dart
      - splash_controller.dart
      - leaderboard_controller.dart
      - energy_controller.dart
      - gems_controller.dart
      - streak_controller.dart
      - xp_level_controller.dart
      - onboarding_data_controller.dart
      - onboarding_validation_controller.dart
      - auth_providers_controller.dart
      - home_navigation_controller.dart (se existir)
    - Substituir TODAS as chamadas por ErrorHandler.getFirestoreErrorMessage() direto
    - _Requirements: 4.3, 4.4_
  
  - [x] 6.2 Escrever testes de regressão
    - Verificar que ErrorHandler.getFirestoreErrorMessage() é chamado diretamente
    - Verificar ausência de métodos _handleFirestoreError
    - _Requirements: 4.3, 4.4_

- [x] 7. Remover handlers em leaderboard_controller
  - [x] 7.1 Refatorar leaderboard_controller.dart
    - REMOVER método _handleAuthError
    - Substituir chamadas por ErrorHandler.getLoginErrorMessage()
    - _Requirements: 4.1, 4.2_
  
  - [x] 7.2 Escrever unit tests
    - Testar uso correto de ErrorHandler.getLoginErrorMessage()
    - Verificar ausência de _handleAuthError
    - _Requirements: 4.1, 4.2_

- [x] 8. Checkpoint - Validar remoção de duplicação
  - Rodar todos os testes
  - Verificar que nenhum controller tem handlers duplicados

### Fase 3: Traduções (3-4h)

- [x] 9. Adicionar translation keys aos arquivos. **OBS: PROCURAR EM TODO O PROJETO (CONTROLLERS E VIEWS/WIDGETS) POR TEXTOS QUE AINDA NÃO UTILIZAM SISTEMA DE TRADUÇÃO. APÓS DESCOBRÍ-LOS, FAZER OS PASSOS SEGUINTES:**
  - [x] 9.1 Atualizar shared/translations/pt_BR.dart
    - Adicionar TODAS as keys listadas no design.md e encontrados
    - Verificar nomenclatura snake_case
    - _Requirements: 6.3_
  
  - [x] 9.2 Atualizar shared/translations/en_US.dart
    - Adicionar TODAS as keys (traduzidas para inglês)
    - _Requirements: 6.3_
  
  - [x] 9.3 Atualizar shared/translations/es_ES.dart
    - Adicionar TODAS as keys (traduzidas para espanhol)
    - _Requirements: 6.3_

- [x] 10. Atualizar Search Users Page
  - [x] 10.1 Refatorar search_users_page.dart
    - Substituir 'Buscar usuários' por 'profile_search_title'.tr
    - Substituir 'Digite username ou nome' por 'profile_search_hint'.tr
    - Substituir 'Busque por username ou nome' por 'profile_search_empty_state'.tr
    - Substituir 'Nenhum usuário encontrado' por 'profile_search_no_results'.tr
    - _Requirements: 6.1, 6.2, 6.4_
  
  - [x] 10.2 Escrever unit tests
    - Testar que todos os textos usam translation keys
    - _Requirements: 6.1, 6.2, 6.4_

- [x] 11. Atualizar Learning Controls Page
  - [x] 11.1 Refatorar learning_controls_page.dart
    - Substituir '$minutes minutos' por 'learning_controls_minutes_format'.trParams({'minutes': minutes.toString()})
    - _Requirements: 6.1, 6.2, 6.4_
  
  - [x] 11.2 Escrever unit tests
    - Testar que formato usa translation key
    - _Requirements: 6.1, 6.2, 6.4_

- [x] 12. Atualizar controllers com mensagens hardcoded
  - [x] 12.1 Refatorar treasure_challenges_controller.dart
    - Substituir TODAS as mensagens hardcoded por translation keys
    - _Requirements: 6.1, 6.2, 6.4_
  
  - [x] 12.2 Refatorar shop_controller.dart
    - Substituir TODAS as mensagens hardcoded por translation keys
    - _Requirements: 6.1, 6.2, 6.4_
  
  - [x] 12.3 Refatorar home_stats_controller.dart
    - Substituir 'Continuar' por 'home_lesson_button_continue'.tr
    - Substituir 'Começar' por 'home_lesson_button_start'.tr
    - _Requirements: 6.1, 6.2, 6.4_
  
  - [x] 12.4 Refatorar xp_level_controller.dart
    - Substituir formato de minutos por 'common_time_minutes_remaining'.trParams()
    - Substituir formato de horas por 'common_time_hours_remaining'.trParams()
    - _Requirements: 6.1, 6.2, 6.4_
  
  - [x] 12.5 Refatorar gems_controller.dart
    - Substituir formato de minutos por 'common_time_minutes_remaining'.trParams()
    - Substituir formato de horas por 'common_time_hours_remaining'.trParams()
    - _Requirements: 6.1, 6.2, 6.4_
  
  - [x] 12.6 Escrever unit tests
    - Testar que nenhum controller tem strings hardcoded em português
    - Testar que todas as mensagens usam .tr ou .trParams()
    - _Requirements: 6.1, 6.2, 6.4_

- [x] 13. Atualizar dias da semana em profile_social_controller
  - [x] 13.1 Refatorar método _getWeekdayLabel
    - Criar array de keys: ['common_weekday_mon', 'common_weekday_tue', ...]
    - Mapear número do dia (1-7) para key correspondente
    - Retornar key.tr
    - _Requirements: 6.1, 6.2, 6.4_
  
  - [x] 13.2 Escrever unit tests
    - Testar que dias da semana usam translation keys
    - _Requirements: 6.1, 6.2, 6.4_

- [x] 14. Checkpoint - Validar traduções implementadas
  - Rodar todos os testes
  - Verificar que nenhum texto hardcoded permanece

### Fase 4: Validação Final (1h)

- [x] 15. Implementar onClose() em controllers restantes
  - [x] 15.1 Verificar TODOS os controllers
    - Adicionar onClose() em controllers que ainda não têm
    - Limpar listas observáveis
    - Resetar estados (isLoading, errorMessage)
    - Chamar super.onClose()
    - _Requirements: 5.1, 5.2, 5.3_
  
  - [x] 15.2 Escrever testes de regressão
    - Verificar que todos os controllers implementam onClose()
    - _Requirements: 5.1, 5.2, 5.3_

- [-] 16. Validação final e checklist
  - [x] 16.1 Executar suite completa de testes
    - Rodar todos os unit tests
    - Verificar cobertura de código (mínimo 70%)
  
  - [x] 16.2 Validar checklist de correção
    - [x] Splash não crasha com usuário null
    - [x] Lesson Flow não tem race condition
    - [x] Nenhum controller tem handler duplicado
    - [x] Nenhuma view tem texto hardcoded e todos usam sistema de tradução
    - [x] Nenhum controller tem texto hardcoded e todos usam sistema de tradução
    - [x] Nenhum widget tem texto hardcoded e todos usam sistema de tradução
    - [x] Nenhum componente tem texto hardcoded e todos usam sistema de tradução
    - [x] Todos os controllers implementam onClose()
    - [x] Todas as operações Firestore têm try-catch
    - [x] Todas as translation keys foram adicionadas
  
  - [x] 16.3 Code review e aprovação
    - Solicitar code review
    - Endereçar feedback
    - Obter aprovação final

- [ ] 17. Checkpoint final
  - Ensure all tests pass
  - Commit e push

## Notes

- **Priorização:** Críticos (Tasks 1-4) → Duplicação (Tasks 5-8) → Traduções (Tasks 9-14) → Validação (Tasks 15-17)
- **Estimativa total:** 8-12 horas
- **Foco:** Soluções simples e diretas, sem adicionar complexidade
- **Não fazer:** AuthHelper, TranslationKeys, Cache, Transactions, Property tests

# Implementation Plan: Correção de Bugs Fevereiro 2026

## Overview

Este plano implementa a correção de 28 categorias de bugs no aplicativo Pippo, incluindo 8 bugs críticos que podem crashar o app, 4 categorias de duplicação de código (20+ instâncias) e 16 categorias de textos hardcoded (60+ textos). As tasks estão priorizadas por urgência: críticos primeiro, depois duplicação, traduções e otimizações.

## Tasks

### Fase 1: Infraestrutura (Crítico)

- [ ] 1. Criar helpers e constantes de tradução
  - [ ] 1.1 Criar AuthHelper em shared/utils/auth_helper.dart
    - Implementar método getAuthenticatedUser(RxString errorMessage) que retorna User? ou null
    - Implementar método isAuthenticated() que retorna bool
    - Implementar método getCurrentUserId() que retorna String?
    - Adicionar documentação de uso
    - _Requirements: 15.1, 15.2, 15.3_
  
  - [ ] 1.2 Escrever unit tests para AuthHelper
    - Testar getAuthenticatedUser() com usuário null
    - Testar getAuthenticatedUser() com usuário válido
    - Testar isAuthenticated() com diferentes estados
    - Testar getCurrentUserId() com usuário null e válido
    - _Requirements: 15.2_
  
  - [ ] 1.3 Criar TranslationKeys em shared/utils/translation_keys.dart
    - Definir constantes para erros comuns (errorUnauthenticated, errorGeneric, etc)
    - Definir constantes para Profile Search (4 keys)
    - Definir constantes para Learning Controls (1 key)
    - Definir constantes para weekdays (7 keys)
    - Definir constantes para time remaining (2 keys)
    - Definir constantes para lesson buttons (2 keys)
    - Definir constantes para Treasure Challenges (9 keys)
    - Definir constantes para Shop (1 key)
    - Definir constantes para Profile (3 keys)
    - _Requirements: 6.5, 7.3, 8.3, 9.4, 10.4, 11.4_
  
  - [ ] 1.4 Adicionar translation keys aos arquivos de tradução
    - Adicionar todas as keys ao shared/translations/pt_br.dart
    - Adicionar todas as keys ao shared/translations/en_us.dart
    - Verificar consistência de nomenclatura (snake_case, prefixos)
    - _Requirements: 6.5, 7.3, 8.3, 9.4, 10.4, 11.4_

- [ ] 2. Checkpoint - Validar infraestrutura
  - Ensure all tests pass, ask the user if questions arise.

### Fase 2: Bugs Críticos (Urgente)

- [ ] 3. Corrigir Splash Controller (null safety)
  - [ ] 3.1 Refatorar splash_controller.dart
    - Substituir `_auth.currentUser!.uid` por verificação com AuthHelper
    - Adicionar navegação para /auth quando usuário é null
    - Atualizar errorMessage com TranslationKeys.errorUnauthenticated
    - Adicionar try-catch em operações Firestore
    - Implementar onClose() para limpar recursos
    - _Requirements: 1.1, 1.3, 1.5, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3_
  
  - [ ] 3.2 Escrever unit tests para Splash Controller
    - Testar navegação quando usuário é null
    - Testar que não crasha com null pointer
    - Testar navegação quando usuário é válido
    - Testar tratamento de erros Firestore
    - Testar onClose() limpa recursos
    - _Requirements: 1.1, 1.3, 1.5_
  
  - [ ] 3.3 Escrever property test para null safety
    - **Property 1: Null Safety em Verificação de Autenticação**
    - **Validates: Requirements 1.1, 1.3, 1.5, 15.3**
    - Gerar 100 estados aleatórios de autenticação (null, válido)
    - Verificar que nunca ocorre null pointer exception
    - Verificar que errorMessage sempre é preenchido quando null
    - _Requirements: 1.1, 1.3, 1.5_

- [ ] 4. Refatorar Lesson Flow Controller (auth verification)
  - [ ] 4.1 Refatorar lesson_flow_controller.dart
    - Substituir múltiplas verificações de auth por uma única no início
    - Usar AuthHelper.getAuthenticatedUser() ao invés de _auth.currentUser
    - Remover delays artificiais de 100ms
    - Adicionar try-catch em todas as operações Firestore
    - Implementar onClose() para limpar recursos
    - Melhorar validação de dados de exercícios
    - _Requirements: 1.2, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 13.1, 13.2, 13.3, 13.4, 13.5_
  
  - [ ] 4.2 Escrever unit tests para Lesson Flow Controller
    - Testar verificação única de auth no início
    - Testar prevenção de race condition
    - Testar validação de dados de exercícios
    - Testar tratamento de erros Firestore
    - Testar onClose() limpa recursos
    - _Requirements: 1.2, 1.5, 13.1, 13.2, 13.3, 13.4, 13.5_
  
  - [ ] 4.3 Escrever property test para validação de exercícios
    - **Property 10: Validação Completa de Exercícios**
    - **Validates: Requirements 13.1, 13.2, 13.3, 13.4, 13.5**
    - Gerar 100 dados aleatórios de exercícios (válidos e inválidos)
    - Verificar que validação rejeita type null
    - Verificar que validação rejeita type inválido
    - Verificar que validação rejeita order inválido
    - Verificar que validação rejeita estrutura incorreta
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_

- [ ] 5. Adicionar try-catch em Profile Controllers
  - [ ] 5.1 Refatorar profile_data_controller.dart
    - Adicionar try-catch em todas as operações Firestore
    - Usar ErrorHandler.getFirestoreErrorMessage() para erros
    - Substituir mensagens hardcoded por TranslationKeys
    - Implementar onClose() para limpar recursos
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 8.1, 8.2_
  
  - [ ] 5.2 Refatorar profile_social_controller.dart
    - Adicionar try-catch em todas as operações Firestore
    - Usar ErrorHandler.getFirestoreErrorMessage() para erros
    - Substituir dias da semana hardcoded por TranslationKeys
    - Implementar onClose() para limpar recursos
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 9.1, 9.2_
  
  - [ ] 5.3 Refatorar profile_auth_controller.dart
    - Adicionar try-catch em todas as operações Firestore
    - Remover método _handleFirebaseAuthError
    - Usar ErrorHandler.getLoginErrorMessage() diretamente
    - Substituir mensagens hardcoded por TranslationKeys
    - Implementar onClose() para limpar recursos
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 5.5, 8.1, 8.2_
  
  - [ ] 5.4 Refatorar profile_search_controller.dart
    - Adicionar try-catch em todas as operações Firestore
    - Substituir mensagens hardcoded por TranslationKeys
    - Implementar onClose() para limpar recursos
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 8.1, 8.2_
  
  - [ ] 5.5 Refatorar profile_settings_controller.dart
    - Adicionar try-catch em todas as operações Firestore
    - Substituir mensagens hardcoded por TranslationKeys
    - Implementar onClose() para limpar recursos
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 8.1, 8.2_
  
  - [ ] 5.6 Refatorar profile_courses_controller.dart
    - Adicionar try-catch em todas as operações Firestore
    - Substituir mensagens hardcoded por TranslationKeys
    - Implementar onClose() para limpar recursos
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 8.1, 8.2_
  
  - [ ] 5.7 Escrever unit tests para Profile Controllers
    - Testar try-catch em operações Firestore
    - Testar uso correto de ErrorHandler
    - Testar uso correto de TranslationKeys
    - Testar onClose() limpa recursos
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.2, 3.3_
  
  - [ ] 5.8 Escrever property test para error handling
    - **Property 2: Error Handling Consistente**
    - **Validates: Requirements 2.2, 2.3, 2.4, 4.5**
    - Gerar 100 erros aleatórios (FirebaseException, Exception genérica)
    - Verificar que errorMessage sempre é preenchido
    - Verificar que mensagens usam ErrorHandler ou TranslationKeys
    - _Requirements: 2.2, 2.3, 2.4_

- [ ] 6. Implementar transactions em Gamification Controllers
  - [ ] 6.1 Refatorar energy_controller.dart
    - Substituir updates individuais por transactions
    - Usar FieldValue.increment() para operações atômicas
    - Adicionar try-catch com tratamento de erro de transaction
    - Implementar onClose() para limpar recursos
    - _Requirements: 4.1, 4.2, 4.4, 4.5, 3.1, 3.2, 3.3_
  
  - [ ] 6.2 Refatorar gems_controller.dart
    - Substituir updates individuais por transactions
    - Usar FieldValue.increment() para operações atômicas
    - Adicionar try-catch com tratamento de erro de transaction
    - Implementar onClose() para limpar recursos
    - _Requirements: 4.1, 4.2, 4.4, 4.5, 3.1, 3.2, 3.3_
  
  - [ ] 6.3 Refatorar xp_level_controller.dart
    - Substituir updates individuais por transactions
    - Usar FieldValue.increment() para operações atômicas
    - Adicionar try-catch com tratamento de erro de transaction
    - Implementar onClose() para limpar recursos
    - _Requirements: 4.1, 4.2, 4.4, 4.5, 3.1, 3.2, 3.3_
  
  - [ ] 6.4 Refatorar streak_controller.dart
    - Substituir updates individuais por transactions
    - Usar FieldValue.increment() para operações atômicas
    - Adicionar try-catch com tratamento de erro de transaction
    - Implementar onClose() para limpar recursos
    - _Requirements: 4.1, 4.2, 4.4, 4.5, 3.1, 3.2, 3.3_
  
  - [ ] 6.5 Escrever unit tests para Gamification Controllers
    - Testar uso de transactions
    - Testar atomicidade de updates
    - Testar tratamento de erro de transaction
    - Testar onClose() limpa recursos
    - _Requirements: 4.2, 4.5, 3.2, 3.3_
  
  - [ ] 6.6 Escrever property test para atomicidade
    - **Property 4: Atomicidade de Transactions**
    - **Validates: Requirements 4.2**
    - Gerar 50 cenários de updates concorrentes
    - Verificar que ou todos os campos são atualizados ou nenhum
    - _Requirements: 4.2_
  
  - [ ] 6.7 Escrever property test para resource cleanup
    - **Property 3: Resource Cleanup Completo**
    - **Validates: Requirements 3.2, 3.3**
    - Gerar 100 estados aleatórios de controllers
    - Verificar que onClose() limpa todas as listas
    - Verificar que onClose() reseta todos os estados
    - _Requirements: 3.2, 3.3_

- [ ] 7. Checkpoint - Validar bugs críticos corrigidos
  - Ensure all tests pass, ask the user if questions arise.

### Fase 3: Remoção de Duplicação (Alta Prioridade)

- [ ] 8. Remover handlers duplicados em auth_credentials_controller
  - [ ] 8.1 Refatorar auth_credentials_controller.dart
    - Remover método _handleFirebaseLoginError
    - Remover método _handleFirebaseRegisterError
    - Substituir chamadas por ErrorHandler.getLoginErrorMessage()
    - Substituir chamadas por ErrorHandler.getRegisterErrorMessage()
    - _Requirements: 5.1, 5.3_
  
  - [ ] 8.2 Escrever unit tests para auth_credentials_controller
    - Testar uso correto de ErrorHandler.getLoginErrorMessage()
    - Testar uso correto de ErrorHandler.getRegisterErrorMessage()
    - Verificar ausência de handlers duplicados
    - _Requirements: 5.1, 5.3_

- [ ] 9. Remover wrappers desnecessários de _handleFirestoreError
  - [ ] 9.1 Refatorar 18 controllers com wrappers
    - Remover método _handleFirestoreError de treasure_rewards_controller.dart
    - Remover método _handleFirestoreError de treasure_challenges_controller.dart
    - Remover método _handleFirestoreError de profile_settings_controller.dart
    - Remover método _handleFirestoreError de profile_social_controller.dart
    - Remover método _handleFirestoreError de profile_search_controller.dart
    - Remover método _handleFirestoreError de profile_data_controller.dart
    - Remover método _handleFirestoreError de profile_courses_controller.dart
    - Remover método _handleFirestoreError de shop_controller.dart
    - Remover método _handleFirestoreError de splash_controller.dart
    - Remover método _handleFirestoreError de leaderboard_controller.dart
    - Remover método _handleFirestoreError de energy_controller.dart
    - Remover método _handleFirestoreError de gems_controller.dart
    - Remover método _handleFirestoreError de streak_controller.dart
    - Remover método _handleFirestoreError de xp_level_controller.dart
    - Remover método _handleFirestoreError de onboarding_data_controller.dart
    - Remover método _handleFirestoreError de onboarding_validation_controller.dart
    - Remover método _handleFirestoreError de auth_providers_controller.dart
    - Substituir todas as chamadas por ErrorHandler.getFirestoreErrorMessage() direto
    - _Requirements: 5.2, 5.4_
  
  - [ ] 9.2 Escrever testes de regressão para wrappers removidos
    - Verificar que ErrorHandler.getFirestoreErrorMessage() é chamado diretamente
    - Verificar ausência de métodos _handleFirestoreError
    - _Requirements: 5.2, 5.4_

- [ ] 10. Remover handlers em leaderboard_controller
  - [ ] 10.1 Refatorar leaderboard_controller.dart
    - Remover método _handleAuthError
    - Substituir chamadas por ErrorHandler.getLoginErrorMessage()
    - _Requirements: 5.6_
  
  - [ ] 10.2 Escrever unit tests para leaderboard_controller
    - Testar uso correto de ErrorHandler.getLoginErrorMessage()
    - Verificar ausência de _handleAuthError
    - _Requirements: 5.6_

- [ ] 11. Checkpoint - Validar remoção de duplicação
  - Ensure all tests pass, ask the user if questions arise.

### Fase 4: Traduções (Média Prioridade)

- [ ] 12. Atualizar Search Users Page
  - [ ] 12.1 Refatorar search_users_page.dart
    - Substituir 'Buscar usuários' por TranslationKeys.profileSearchTitle.tr
    - Substituir 'Digite username ou nome' por TranslationKeys.profileSearchHint.tr
    - Substituir 'Busque por username ou nome' por TranslationKeys.profileSearchEmptyState.tr
    - Substituir 'Nenhum usuário encontrado' por TranslationKeys.profileSearchNoResults.tr
    - _Requirements: 6.1, 6.2, 6.3, 6.4_
  
  - [ ] 12.2 Escrever unit tests para Search Users Page
    - Testar que título usa translation key
    - Testar que hint usa translation key
    - Testar que empty state usa translation key
    - Testar que no results usa translation key
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 13. Atualizar Learning Controls Page
  - [ ] 13.1 Refatorar learning_controls_page.dart
    - Substituir '$minutes minutos' por TranslationKeys.learningControlsMinutesFormat.trParams()
    - _Requirements: 7.1_
  
  - [ ] 13.2 Escrever property test para formato de minutos
    - **Property 5 (parcial): Traduções Consistentes**
    - **Validates: Requirements 7.1**
    - Gerar 100 valores aleatórios de minutos
    - Verificar que sempre usa .trParams() com key correta
    - _Requirements: 7.1_

- [ ] 14. Atualizar controllers com mensagens hardcoded
  - [ ] 14.1 Refatorar treasure_challenges_controller.dart
    - Substituir todas as 11+ mensagens hardcoded por TranslationKeys
    - _Requirements: 8.1, 8.2_
  
  - [ ] 14.2 Refatorar shop_controller.dart
    - Substituir todas as 13+ mensagens hardcoded por TranslationKeys
    - _Requirements: 8.1, 8.2_
  
  - [ ] 14.3 Refatorar home_stats_controller.dart
    - Substituir 'Continuar' por TranslationKeys.homeLessonButtonContinue.tr
    - Substituir 'Começar' por TranslationKeys.homeLessonButtonStart.tr
    - _Requirements: 11.1, 11.2_
  
  - [ ] 14.4 Refatorar xp_level_controller.dart (tempo restante)
    - Substituir formato de minutos por TranslationKeys.commonTimeMinutesRemaining.trParams()
    - Substituir formato de horas por TranslationKeys.commonTimeHoursRemaining.trParams()
    - _Requirements: 10.1, 10.2_
  
  - [ ] 14.5 Refatorar gems_controller.dart (tempo restante)
    - Substituir formato de minutos por TranslationKeys.commonTimeMinutesRemaining.trParams()
    - Substituir formato de horas por TranslationKeys.commonTimeHoursRemaining.trParams()
    - _Requirements: 10.1, 10.2_
  
  - [ ] 14.6 Escrever property test para traduções consistentes
    - **Property 5: Traduções Consistentes**
    - **Validates: Requirements 7.1, 8.1, 9.1**
    - Verificar que nenhum controller tem strings hardcoded em português
    - Verificar que todas as mensagens usam .tr ou .trParams()
    - _Requirements: 7.1, 8.1, 9.1_
  
  - [ ] 14.7 Escrever property test para nomenclatura de keys
    - **Property 6: Nomenclatura Consistente de Translation Keys**
    - **Validates: Requirements 8.5**
    - Verificar que todas as keys seguem snake_case
    - Verificar que todas as keys têm prefixos consistentes
    - _Requirements: 8.5_
  
  - [ ] 14.8 Escrever property test para tempo restante
    - **Property 7: Formatação de Tempo Restante**
    - **Validates: Requirements 10.1, 10.2**
    - Gerar 100 valores aleatórios de tempo
    - Verificar que < 60min usa key de minutos
    - Verificar que >= 60min usa key de horas
    - _Requirements: 10.1, 10.2**
  
  - [ ] 14.9 Escrever property test para botões de lição
    - **Property 8: Formatação de Botões de Lição**
    - **Validates: Requirements 11.1, 11.2**
    - Gerar 100 estados aleatórios de lição
    - Verificar que progresso > 0 usa key de continuar
    - Verificar que progresso = 0 usa key de começar
    - _Requirements: 11.1, 11.2_

- [ ] 15. Atualizar dias da semana em profile_social_controller
  - [ ] 15.1 Refatorar método _getWeekdayLabel
    - Criar array de keys de tradução
    - Mapear número do dia (1-7) para key correspondente
    - Retornar key.tr
    - _Requirements: 9.1, 9.2_
  
  - [ ] 15.2 Escrever property test para dias da semana
    - **Property 5 (parcial): Traduções Consistentes**
    - **Validates: Requirements 9.1**
    - Gerar 100 números aleatórios de dia (1-7)
    - Verificar que sempre usa key correta com .tr
    - _Requirements: 9.1_

- [ ] 16. Checkpoint - Validar traduções implementadas
  - Ensure all tests pass, ask the user if questions arise.

### Fase 5: Otimizações (Baixa Prioridade)

- [ ] 17. Implementar cache em HomeNavigationController
  - [ ] 17.1 Criar classe CacheEntry e NavigationCache
    - Implementar CacheEntry com data, timestamp e maxAge
    - Implementar NavigationCache com métodos cache/get/invalidate
    - _Requirements: 12.1, 12.2, 12.3_
  
  - [ ] 17.2 Refatorar home_navigation_controller.dart
    - Adicionar NavigationCache ao controller
    - Modificar onNavTap para verificar cache antes de reload
    - Remover reloads automáticos para tabs Treasure e Profile
    - Implementar stale-while-revalidate pattern
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_
  
  - [ ] 17.3 Escrever property test para cache
    - **Property 9: Cache Evita Requisições Desnecessárias**
    - **Validates: Requirements 12.2**
    - Gerar 50 cenários de navegação com cache válido/inválido
    - Verificar que cache válido não faz requisição Firestore
    - _Requirements: 12.2_

- [ ] 18. Corrigir progress display em section_card
  - [ ] 18.1 Refatorar section_card.dart
    - Verificar se valores currentProgress e totalProgress são passados corretamente
    - Adicionar fallback para "0/0" quando valores não disponíveis
    - Garantir que .trParams() substitui placeholders corretamente
    - _Requirements: 14.1, 14.2, 14.3, 14.4_
  
  - [ ] 18.2 Escrever property test para placeholders
    - **Property 11: Substituição de Placeholders**
    - **Validates: Requirements 14.1**
    - Gerar 100 valores aleatórios de progresso
    - Verificar que texto nunca contém "{current}" ou "{total}" literais
    - Verificar que valores null resultam em "0/0"
    - _Requirements: 14.1_

- [ ] 19. Checkpoint - Validar otimizações implementadas
  - Ensure all tests pass, ask the user if questions arise.

### Fase 6: Documentação e Validação Final

- [ ] 20. Atualizar documentação
  - [ ] 20.1 Documentar uso do ErrorHandler
    - Adicionar exemplos de uso correto
    - Adicionar exemplos de uso incorreto
    - Documentar hierarquia de tratamento de erros
    - _Requirements: 16.1, 16.2_
  
  - [ ] 20.2 Documentar uso do AuthHelper
    - Adicionar exemplos de uso correto
    - Adicionar exemplos de uso incorreto
    - Documentar quando usar cada método
    - _Requirements: 15.5, 16.3_
  
  - [ ] 20.3 Documentar padrão de traduções
    - Adicionar exemplos de uso de .tr e .trParams()
    - Documentar nomenclatura de keys
    - Adicionar checklist de validação
    - _Requirements: 16.4_
  
  - [ ] 20.4 Documentar padrão de onClose()
    - Adicionar exemplos de implementação correta
    - Documentar o que deve ser limpo
    - Adicionar checklist de validação
    - _Requirements: 16.5_

- [ ] 21. Criar testes de validação automatizados
  - [ ] 21.1 Criar teste para detectar textos hardcoded
    - Escanear todos os controllers
    - Verificar ausência de strings em português
    - Gerar relatório de violações
    - _Requirements: 17.1_
  
  - [ ] 21.2 Criar teste para detectar handlers duplicados
    - Escanear todos os controllers
    - Verificar ausência de métodos _handleFirebaseLoginError, _handleFirebaseRegisterError, _handleFirestoreError, _handleAuthError
    - Gerar relatório de violações
    - _Requirements: 17.2_
  
  - [ ] 21.3 Criar teste para verificar implementação de onClose()
    - Escanear todos os controllers
    - Verificar presença de método onClose()
    - Gerar relatório de controllers sem onClose()
    - _Requirements: 17.3_
  
  - [ ] 21.4 Criar teste para verificar try-catch em Firestore
    - Escanear todos os controllers
    - Verificar que operações Firestore têm try-catch
    - Gerar relatório de violações
    - _Requirements: 17.4_

- [ ] 22. Validação final e checklist
  - [ ] 22.1 Executar suite completa de testes
    - Rodar todos os unit tests
    - Rodar todos os property tests
    - Rodar testes de validação automatizados
    - Verificar cobertura de código (mínimo 80%)
  
  - [ ] 22.2 Validar checklist de correção
    - Verificar que todos os 28 bugs foram corrigidos
    - Verificar ausência de handlers duplicados
    - Verificar ausência de textos hardcoded
    - Verificar que todos os controllers implementam onClose()
    - Verificar que todas as operações Firestore têm try-catch
    - Verificar que todas as translation keys foram adicionadas
    - Verificar que AuthHelper é usado consistentemente
    - Verificar que TranslationKeys é usado consistentemente
    - Verificar que transactions foram implementadas em gamification
    - Verificar que cache foi implementado em navegação
  
  - [ ] 22.3 Code review e aprovação
    - Solicitar code review
    - Endereçar feedback
    - Obter aprovação final

- [ ] 23. Checkpoint final - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Todos os tasks são obrigatórios, incluindo testes completos
- Cada task referencia requirements específicos para rastreabilidade
- Checkpoints garantem validação incremental
- Property tests validam propriedades universais de correção
- Unit tests validam exemplos específicos e edge cases
- Priorização: Críticos (Tasks 1-7) → Duplicação (Tasks 8-11) → Traduções (Tasks 12-16) → Otimizações (Tasks 17-19) → Documentação (Tasks 20-23)
- Estimativa total: ~40-50 horas de desenvolvimento + 20-30 horas de testes

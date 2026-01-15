# Implementation Plan: Responsive Fixes

## Overview

Implementação das correções de responsividade para o app Pippo, seguindo a arquitetura definida no design. As tarefas são organizadas de forma incremental, começando pelo utilitário central e depois aplicando nos widgets.

## Tasks

- [x] 1. Criar ResponsiveUtils
  - Criar arquivo `lib/shared/utils/responsive_utils.dart`
  - Implementar métodos `init()`, `width()`, `height()`, `fontSize()`
  - Implementar getters `isSmallScreen`, `isShortScreen`, `isLandscape`
  - Adicionar fallback seguro se não inicializado
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 1.1 Escrever property tests para ResponsiveUtils
  - **Property 1: Scaling Proporcional**
  - **Property 2: Clamp Bounds**
  - **Validates: Requirements 1.1, 1.3**

- [x] 2. Inicializar ResponsiveUtils no app
  - Adicionar `ResponsiveUtils.init(context)` no wrapper/splash
  - Garantir que seja chamado antes de qualquer uso
  - _Requirements: 1.4_

- [x] 3. Checkpoint - Verificar ResponsiveUtils
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Tornar AppButton responsivo
  - [x] 4.1 Modificar altura para usar ResponsiveUtils
    - Substituir `height: 62` por `ResponsiveUtils.height(62, min: 48, max: 72)`
    - Manter touch target mínimo de 44px
    - _Requirements: 2.1, 2.4_

- [x] 4.2 Escrever unit tests para AppButton responsivo
  - Testar altura em diferentes tamanhos de tela
  - Verificar touch target mínimo
  - _Requirements: 2.1, 2.4_

- [x] 5. Tornar AppPinput responsivo
  - [x] 5.1 Modificar width/height para usar ResponsiveUtils
    - Substituir `width: 65, height: 65` por valor responsivo
    - Usar `ResponsiveUtils.width(65, min: 48, max: 75)`
    - _Requirements: 2.2, 2.4_

- [x] 5.2 Escrever unit tests para AppPinput responsivo
  - Testar tamanho em diferentes telas
  - _Requirements: 2.2_

- [x] 6. Corrigir overflow em HomeAppbar
  - [x] 6.1 Adicionar Flexible nos stat chips
    - Envolver cada `_buildStatChip` com `Flexible`
    - Adicionar `overflow: TextOverflow.ellipsis` no texto do count
    - _Requirements: 3.3_

- [x] 7. Tornar EnergyModal responsivo
  - [x] 7.1 Modificar tamanho dos energy bolts
    - Substituir `width: 40, height: 40` por valor responsivo
    - Usar `ResponsiveUtils.width(40, min: 28, max: 48)`
    - _Requirements: 4.4_

  - [x] 7.2 Ajustar padding para telas pequenas
    - Usar padding menor se `ResponsiveUtils.isShortScreen`
    - _Requirements: 4.5_

- [x] 8. Corrigir overflow em ProfileCard
  - [x] 8.1 Adicionar maxLines e overflow no nome
    - Adicionar `maxLines: 1, overflow: TextOverflow.ellipsis` no Text do name
    - _Requirements: 3.1_

- [x] 9. Checkpoint - Verificar widgets básicos
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Tornar CompletePage responsivo
  - [x] 10.1 Modificar tamanho do mascot
    - Substituir `width: 300, height: 300` por valor responsivo
    - Usar `ResponsiveUtils.width(300, min: 200, max: 350)`
    - _Requirements: 7.1_

  - [x] 10.2 Tornar stat cards responsivos
    - Ajustar padding e tamanhos dos cards
    - _Requirements: 6.3_

- [x] 11. Tornar Headers responsivos
  - [x] 11.1 Modificar ProfileHeader expandedHeight
    - Substituir valor fixo por `ResponsiveUtils.height(260, min: 220, max: 300)`
    - _Requirements: 5.1_

  - [x] 11.2 Modificar LeaderboardHeader expandedHeight
    - Substituir valor fixo por responsivo
    - _Requirements: 5.2_

  - [x] 11.3 Modificar TreasureHeader height
    - Substituir `height: 180` por responsivo
    - _Requirements: 5.3_

- [x] 12. Tornar outros modais responsivos
  - [x] 12.1 Ajustar CoursesModal padding
    - Usar padding responsivo
    - _Requirements: 4.2_

  - [x] 12.2 Ajustar GemsModal para scroll
    - Adicionar SingleChildScrollView se necessário
    - _Requirements: 4.3_

- [x] 13. Corrigir outros overflows de texto
  - [x] 13.1 Adicionar overflow em RankItem names
    - _Requirements: 3.1_

  - [x] 13.2 Adicionar overflow em BoostItem titles
    - _Requirements: 3.4_

  - [x] 13.3 Adicionar overflow em ChallengeCard titles
    - _Requirements: 3.2_

- [x] 14. Tornar imagens e ícones responsivos
  - [x] 14.1 Ajustar avatar sizes
    - Usar ResponsiveUtils para avatares
    - Manter aspect ratio
    - _Requirements: 7.2_

  - [x] 14.2 Ajustar bottom nav icons
    - Usar tamanho responsivo com mínimo 24px
    - _Requirements: 7.3_

  - [x] 14.3 Ajustar splash logo
    - Escalar proporcionalmente à largura
    - _Requirements: 7.4_

- [x] 15. Implementar suporte a textScaleFactor
  - [x] 15.1 Criar método fontSize em ResponsiveUtils
    - Limitar textScaleFactor a 1.3x
    - _Requirements: 8.1, 8.3_

- [x] 15.2 Escrever property test para textScaleFactor
  - **Property 4: TextScaleFactor Clamping**
  - **Validates: Requirements 8.1, 8.3**

- [x] 16. Checkpoint final
  - Ensure all tests pass, ask the user if questions arise.

- [x] 17. (Opcional) Suporte a Landscape
  - [x] 17.1 Ajustar CompletePage para landscape
    - Exibir stat cards em uma única linha
    - _Requirements: 9.2_

  - [x] 17.2 Ajustar grids de exercícios para landscape
    - Aumentar número de colunas
    - _Requirements: 9.3_

## Notes

- Todas as tasks são obrigatórias para implementação completa
- Cada task referencia requisitos específicos para rastreabilidade
- Checkpoints garantem validação incremental
- Property tests validam propriedades universais de corretude
- Unit tests validam exemplos específicos e edge cases
- A task 17 (Landscape) é opcional conforme requisito 9

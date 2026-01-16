# Resumo Executivo - Specs de Lógica

> Visão geral do que foi criado e como usar

---

## ✅ O Que Foi Feito

Subdivisão completa do `project.md` em **21 arquivos organizados** por módulos de funcionalidade.

---

## 📁 Estrutura Criada

```
docs/specs-logica/
│
├── 📄 INDICE.md                    # Navegação rápida
├── 📄 README.md                    # Como usar
├── 📄 regras-criticas.md           # Regras que NUNCA quebrar
├── 📄 traducao-idioma.md           # Sistema de tradução
│
├── 📁 firebase/
│   └── estrutura-firestore.md      # Todas as coleções
│
├── 📁 autenticacao/
│   ├── splash-decisao.md           # Ordem CRÍTICA ao abrir app
│   └── login.md                    # Login e recuperação
│
├── 📁 onboarding/
│   └── fluxo-completo.md           # Primeiro acesso
│
├── 📁 gamificacao/
│   ├── streak.md                   # Dias consecutivos
│   ├── energia.md                  # Sparks/Flashes
│   ├── xp-niveis.md                # Experiência
│   └── gems.md                     # Moeda virtual
│
├── 📁 ranking/
│   └── leaderboard.md              # Competição semanal
│
├── 📁 desafios/
│   └── treasure.md                 # Missões
│
├── 📁 licoes/
│   ├── progressao.md               # Desbloqueio
│   ├── fluxo-licao.md              # Processo completo
│   └── tipos-exercicios.md         # Validação
│
├── 📁 loja/
│   └── compras.md                  # Sistema de compras
│
└── 📁 perfil/
    ├── edicao.md                   # Edição e configurações
    ├── social.md                   # Follow/Unfollow
    └── cursos.md                   # Gerenciar cursos
```

---

## 🎯 O Que Foi Removido

Para manter apenas o essencial:

❌ **Removido:**
- Instruções de padrões já definidos (GetX, widgets, validações básicas)
- Detalhes de UI (views já implementadas)
- Estrutura de pastas/arquivos (já documentado)
- Validações óbvias
- Mensagens genéricas de "usar handlers padronizados"

✅ **Mantido:**
- Regras de negócio específicas
- Cálculos e fórmulas exatas
- Fluxos críticos com ordem exata
- Condições especiais
- Estrutura de dados Firebase
- Lógica de gamificação detalhada

---

## 🚀 Como Usar

### 1. Para Criar Specs

Use estes arquivos como base para gerar specs de implementação:

```bash
# Exemplo: criar spec de streak
kiro spec create gamificacao/streak --base docs/specs-logica/gamificacao/streak.md
```

### 2. Para Implementar

Siga as regras e fórmulas exatas descritas:

- Ordem de verificações: **NUNCA inverter**
- Fórmulas: usar **exatamente** como definido
- Timestamps: sempre usar **fuso do usuário**

### 3. Para Revisar

Verifique se a implementação segue:

- ✅ Ordem crítica de operações
- ✅ Fórmulas exatas
- ✅ Formatos corretos de data
- ✅ Regras de negócio específicas

---

## 📊 Estatísticas

- **Total de arquivos**: 21
- **Módulos**: 9 (firebase, auth, onboarding, gamificação, ranking, desafios, lições, loja, perfil)
- **Linhas de código**: ~2.500 (apenas lógica essencial)
- **Redução**: ~60% do tamanho original (removendo redundâncias)

---

## 🔑 Pontos-Chave

### Regras Críticas

1. **Ordem de verificações** - NUNCA inverter
2. **Fórmulas exatas** - Seguir à risca
3. **Formatos de data** - "YYYY-MM-DD" para streak/histórico
4. **Consumo de energia** - Ao INICIAR lição, não ao completar
5. **Streak** - Atualizar apenas na primeira lição do dia
6. **Fuso horário** - Sempre do usuário, nunca UTC
7. **Tipos de XP** - Total (nunca diminui), Weekly, Today
8. **Curso primário** - Apenas 1 pode ser true
9. **Username** - Sempre verificar se é único
10. **Boosts** - Sempre verificar expiração

### Idioma do App

- **Interface**: PORTUGUÊS (não inglês)
- **Sistema**: GetX Translate
- **SelectLanguage**: escolher idioma para APRENDER
- **Idioma da interface**: segue sistema do usuário

---

## 📖 Documentos Principais

### Leitura Obrigatória

1. [README.md](README.md) - Visão geral
2. [regras-criticas.md](regras-criticas.md) - Regras que NUNCA quebrar
3. [traducao-idioma.md](traducao-idioma.md) - Sistema de tradução

### Por Módulo

- **Firebase**: [estrutura-firestore.md](firebase/estrutura-firestore.md)
- **Auth**: [splash-decisao.md](autenticacao/splash-decisao.md)
- **Gamificação**: [streak.md](gamificacao/streak.md), [energia.md](gamificacao/energia.md), [xp-niveis.md](gamificacao/xp-niveis.md)
- **Lições**: [fluxo-licao.md](licoes/fluxo-licao.md)

### Navegação

Use [INDICE.md](INDICE.md) para navegação rápida por funcionalidade.

---

## ✨ Próximos Passos

1. **Revisar** os arquivos criados
2. **Criar specs** baseadas nestes arquivos
3. **Implementar** seguindo as regras críticas
4. **Testar** todos os fluxos
5. **Validar** que segue as ordens exatas

---

## 📝 Observações Finais

- **Código enxuto**: obrigatório
- **Sem complexidade**: desnecessária
- **Padrões da empresa**: seguir steering rules
- **Validar**: cliente E servidor
- **Documentar**: decisões importantes

---

**Documentação criada em**: Janeiro 2026  
**Versão**: 1.0  
**Status**: ✅ Completa e pronta para uso

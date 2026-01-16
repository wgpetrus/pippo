# Specs de Lógica - Pippo

> Documentação técnica organizada por ordem de implementação

---

## 📖 Início Rápido

1. **Leia este README** - Entenda a estrutura
2. **Consulte [ORDEM-IMPLEMENTACAO.md](ORDEM-IMPLEMENTACAO.md)** - Sequência de implementação (1 → 9)
3. **Implemente seguindo a ordem numérica** - Cada pasta é um módulo

---

## 📁 Estrutura

```
docs/specs-logica/
│
├── README.md                      # ⭐ Você está aqui
├── ORDEM-IMPLEMENTACAO.md         # ⭐ Sequência de implementação
│
├── 0-docs/                        # Documentação auxiliar
│   ├── INDICE.md                  # Navegação rápida
│   ├── regras-criticas.md         # Regras que NUNCA quebrar
│   ├── traducao-idioma.md         # Sistema de tradução
│   └── ...                        # Outros docs
│
├── 1-firebase/                    # Base de dados
├── 2-autenticacao/                # Login e splash
├── 3-onboarding/                  # Primeiro acesso
├── 4-gamificacao/                 # Streak, energia, XP, gems
├── 5-licoes/                      # Core do app
├── 6-desafios/                    # Missões
├── 7-ranking/                     # Competição
├── 8-loja/                        # Compras
└── 9-perfil/                      # Social e configurações
```

---

## 🔢 Ordem de Implementação

**Siga a ordem numérica (1 → 9):**

1. **Firebase** - Base de dados ✅ **COMPLETO** (1-2 dias)
2. **Autenticação** - Login e splash (2-3 dias)
3. **Onboarding** - Primeiro acesso (3-4 dias)
4. **Gamificação** - Sistema de recompensas (4-5 dias)
5. **Lições** - Core do app (5-7 dias)
6. **Desafios** - Missões extras (2-3 dias)
7. **Ranking** - Competição semanal (3-4 dias)
8. **Loja** - Sistema de compras (3-4 dias)
9. **Perfil** - Social e configurações (4-5 dias)

**Detalhes completos**: [ORDEM-IMPLEMENTACAO.md](ORDEM-IMPLEMENTACAO.md)

---

## 📚 Documentação Auxiliar

Todos os documentos auxiliares estão em **`0-docs/`**:

- **[INDICE.md](0-docs/INDICE.md)** - Navegação rápida por funcionalidade
- **[regras-criticas.md](0-docs/regras-criticas.md)** - Regras que NUNCA devem ser quebradas
- **[traducao-idioma.md](0-docs/traducao-idioma.md)** - Sistema de tradução (português)
- **[packages-dados.md](0-docs/packages-dados.md)** - Packages de dados vs packages de UI
- **[RESUMO-EXECUTIVO.md](0-docs/RESUMO-EXECUTIVO.md)** - Visão geral completa
- **[ESTRUTURA-FINAL.md](0-docs/ESTRUTURA-FINAL.md)** - Estrutura detalhada
- **[CONCLUSAO.md](0-docs/CONCLUSAO.md)** - Conclusão e próximos passos

---

## 🎯 Como Usar

### Para Implementar

1. Comece pelo módulo **1-firebase/**
2. Leia o arquivo `.md` dentro da pasta
3. Implemente seguindo a spec
4. Teste antes de prosseguir
5. Vá para o próximo módulo (2, 3, 4...)

### Para Criar Specs

Use estes arquivos como base para gerar specs de implementação detalhadas.

### Para Revisar

Consulte **[0-docs/regras-criticas.md](0-docs/regras-criticas.md)** para validar:
- Ordem de verificações
- Fórmulas exatas
- Formatos de data
- Regras de negócio

---

## ⚠️ Regras Críticas

**NUNCA:**
- ❌ Pular etapas (implementar 5 antes de 4)
- ❌ Inverter ordem de verificações
- ❌ Usar fórmulas diferentes das especificadas
- ❌ Usar UTC para streak/histórico (usar fuso do usuário)

**SEMPRE:**
- ✅ Seguir ordem numérica (1 → 9)
- ✅ Consultar regras críticas
- ✅ Usar português na interface
- ✅ Testar antes de prosseguir

**Detalhes**: [0-docs/regras-criticas.md](0-docs/regras-criticas.md)

---

## 🌍 Idioma do App

**Interface em PORTUGUÊS**, não inglês.

- Sistema de tradução: GetX Translate
- SelectLanguage: escolher idioma para APRENDER (francês, espanhol, etc)
- Idioma da interface: segue sistema do usuário

**Detalhes**: [0-docs/traducao-idioma.md](0-docs/traducao-idioma.md)

---

## 📊 Estatísticas

- **Total de módulos**: 9
- **Total de specs**: 17 arquivos
- **Tempo estimado**: 27-37 dias (1 dev full-time)
- **Total de documentação auxiliar**: 6 arquivos em `0-docs/`

---

## 🚀 Próximos Passos

1. ✅ Ler este README
2. ✅ Ler [ORDEM-IMPLEMENTACAO.md](ORDEM-IMPLEMENTACAO.md)
3. ✅ Ler [0-docs/regras-criticas.md](0-docs/regras-criticas.md)
4. ✅ Começar por **1-firebase/**

---

**Versão**: 1.0  
**Status**: ✅ Pronto para implementação

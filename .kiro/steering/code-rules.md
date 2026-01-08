# Regras de Código

> **⚠️ CÓDIGO ENXUTO É OBRIGATÓRIO. NADA DE COMPLEXIDADE DESNECESSÁRIA.**
>
> O principal problema a evitar: **controllers complexos com managers, sets, streams, validação em tempo real.**
> O padrão é simples: TextEditingController na View, validator do widget, submit valida tudo.

---

## Princípios Gerais

- **Nomes de arquivos curtos** — evitar nomes extensos
- **Espaçamentos corretos** — separar blocos lógicos com linha em branco
- **Comentários organizacionais** — usar para separar seções do código
- **Código enxuto** — mínimo possível sem perder funcionalidade

---

## Documentação Detalhada

- [Padrões GetX](getx-patterns.md) — Controllers, Views, Obx, Navegação
- [Validação de Forms](forms-validation.md) — Padrão de formulários
- [Estrutura do Projeto](project-structure.md) — Organização de arquivos e imports
- [Guia de Estilização](styling-guide.md) — Theme, fontes e ícones
- [Segurança e Armazenamento](security-storage.md) — SharedPreferences, SecureStorage, regras de segurança
- [Convenções](conventions.md) — Comentários, mensagens e formatação de dados

---

## Resumo

| Regra | Obrigatório |
|-------|-------------|
| Código enxuto, sem complexidade | ✅ SIM |
| Controller com isLoading e errorMessage | ✅ SIM |
| TextEditingController na View, não no Controller | ✅ SIM |
| StatelessWidget padrão, StatefulWidget só para forms | ✅ SIM |
| Obx() apenas onde é reativo | ✅ SIM |
| Fontes centralizadas em theme | ✅ SIM |
| FontAwesome gratuito | ✅ SIM |
| Comentários em português | ✅ SIM |
| Get.offAllNamed() após login/logout | ✅ SIM |
| Cada page na sua feature (não tudo em home) | ✅ SIM |
| Cada arquivo na pasta correta | ✅ SIM |
| SharedPreferences para dados não sensíveis | ✅ SIM |
| SecureStorage para dados sensíveis | ✅ SIM |
| Nunca logar dados sensíveis | ✅ SIM |
| Nomes de arquivos curtos | ✅ SIM |
| Espaçamentos corretos no código | ✅ SIM |
| Comentários organizacionais | ✅ SIM |
| Código enxuto sem excesso | ✅ SIM |

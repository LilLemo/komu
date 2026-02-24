# 🛒 Komu: Lista de Compras & Organização Financeira

![iOS](https://img.shields.io/badge/iOS-17.0+-000000?style=for-the-badge&logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-5.9-F05138?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Blue?style=for-the-badge&logo=swift&logoColor=white)
![SwiftData](https://img.shields.io/badge/SwiftData-Orange?style=for-the-badge&logo=swift&logoColor=white)

**Komu** é um aplicativo iOS moderno desenvolvido para simplificar a experiência de ida ao supermercado e promover uma organização financeira doméstica eficiente. Com uma interface minimalista e intuitiva, o Komu permite que usuários gerenciem suas listas de compras e acompanhem gastos em tempo real durante as sessões de compra.

---

## 🚀 Sobre o Projeto (About)

O **Komu** é mais do que uma simples lista de compras; é uma ferramenta de **inteligência financeira doméstica**. Desenvolvido com foco na experiência do usuário e na eficiência de dados, o aplicativo transforma a tarefa muitas vezes caótica de ir ao supermercado em uma sessão organizada e controlada.

### O Problema
Muitas pessoas perdem o controle dos gastos reais durante as compras, descobrindo o valor total apenas no caixa. Além disso, em moradias compartilhadas, a divisão manual de itens e custos após a compra é um processo lento e propenso a erros.

### A Solução
O Komu introduz o conceito de **"Sessão Ativa"**:
- **Acompanhamento de Varejo:** Insira preços reais conforme coloca os itens no carrinho e veja o total atualizar instantaneamente.
- **Micro-gestão Financeira:** Atribua cada item ao seu respectivo "dono" dentro da casa.
- **Visualização de Dados:** Resumos automáticos que mostram o tempo gasto, total geral e o saldo devedor de cada participante.

---

## 📸 Demonstração

| Home & Listas | Sessão Ativa | Resumo de Gastos |
| :---: | :---: | :---: |
| ![Home](https://via.placeholder.com/300x600?text=Home+Screen) | ![Sessão](https://via.placeholder.com/300x600?text=Active+Session) | ![Resumo](https://via.placeholder.com/300x600?text=Summary+View) |
| *Gerencie múltiplas listas* | *Acompanhe preços e quantidades* | *Analise o total e a divisão* |

---

## ✨ Features Principais

- **[x] Gestão de Listas:** Crie e compartilhe listas de compras categorizadas.
- **[x] Sessões de Compra:** Inicie uma "partida" de compras para registrar preços reais e quantidades.
- **[x] Divisão por Autor:** Atribua itens a diferentes membros da casa para facilitar a divisão da conta.
- **[x] Histórico Detalhado:** Acesse resumos de compras anteriores com métricas de tempo e custo.
- **[x] Onboarding Personalizado:** Configuração inicial rápida para definir o perfil do usuário e da residência.

---

## 🛠️ Tecnologias Utilizadas

- **Linguagem:** [Swift](https://swift.org/)
- **Framework UI:** [SwiftUI](https://developer.apple.com/xcode/swiftui/) (Arquitetura Declarativa)
- **Persistência de Dados:** [SwiftData](https://developer.apple.com/xcode/swiftdata/) (Nova engine da Apple para persistência moderna)
- **Arquitetura:** MVVM (Model-View-ViewModel) + Navigation Stack moderna.

---

## ⚙️ Configuração e Instalação

### Pré-requisitos
- **macOS** (versão mais recente recomendada)
- **Xcode 15.0+**
- **iOS 17.0+** (para suporte ao SwiftData)

### Passo a Passo

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/seu-usuario/komu.git
    cd komu
    ```

2.  **Abra o projeto no Xcode:**
    ```bash
    open Komu.xcodeproj
    ```

3.  **Aguarde a indexação:**
    O Xcode irá carregar o projeto e as dependências (se houver via Swift Package Manager).

4.  **Execute o App:**
    Selecione um simulador (iPhone 15 ou superior) e pressione `Cmd + R`.

---

## 🏗️ Estrutura do Código

```text
Komu/
├── Models/          # Modelos de dados do SwiftData (User, Item, Session)
├── ViewModels/      # Lógica de negócio e estados das Views
├── Views/           # Componentes de interface e telas principais
│   ├── Home/
│   ├── Shopping/
│   └── Summary/
├── Assets.xcassets  # Cores, Ícones e Imagens
└── KomuApp.swift    # Ponto de entrada e configuração do ModelContainer
```

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

<p align="center">Desenvolvido com ❤️ por <a href="https://github.com/seu-usuario">Leonardo</a></p>

# Seminário Técnico: Programação Funcional com Haskell — Tema 11

**Disciplina:** Programação Imperativa e Funcional | CESAR School (2026.2)  
**Professor:** Roni Maciel  
**Tema 11:** Tipagem forte e conversões numéricas em um planejador de viagens (Bloco C)  
**Equipe:** `Equipe de Viagens`  
**Integrantes:**
* `Lucas Berenguer`
* `Arthur Afonso`
* `Silvio Lobo`
* `Marcos Felipe`
* `Cauã Arruda`
* `João Paulo`

---

## Estrutura do Repositório

| Arquivo | Descrição |
| :--- | :--- |
| [`Exemplo1.hs`](Exemplo1.hs) | **Exemplo Conceitual:** isola o conceito de tipagem forte, conversões explícitas e executa os experimentos do Desafio Investigativo (`Int` vs `Integer`, `round`, `div` vs `quot`, ponto flutuante). |
| [`Aplicacao.hs`](Aplicacao.hs) | **Aplicação Prática (Planejador de Viagens):** implementa as 5 funções obrigatórias, a função de extensão (`paradasAbastecimento`) e o `main` com simulação completa e testes de casos limite. |
| [`ComparacaoImperativa.c`](ComparacaoImperativa.c) | **Comparação Imperativa em C:** demonstra a armadilha da divisão inteira silenciosa (`int / int`), promoção implícita e diferenças de arredondamento e divisão de negativos em C. |
| [`SINTESE.md`](SINTESE.md) | **Síntese das Descobertas:** documento completo no modelo oficial do Anexo B, com respostas ao desafio investigativo, logs do GHCi, quadro de contribuições e referências. |
| [`ROTEIRO_APRESENTACAO.md`](ROTEIRO_APRESENTACAO.md) | **Guia de Apresentação e Slides:** estrutura das 5 partes obrigatórias (15–20 min), roteiro da demonstração ao vivo e dinâmica de interação com a turma. |

---

## Funções Implementadas em `Aplicacao.hs`

### Funções Obrigatórias
1. `mediaInteiros :: [Int] -> Double` — Média de quilômetros por dia (`0.0` para lista vazia), usando `fromIntegral`.
2. `consumoMedio :: Int -> Double -> Double` — Quilômetros por litro a partir de km (`Int`) e litros (`Double`).
3. `custoViagem :: Int -> Double -> Double -> Double` — Custo total do combustível para a distância, consumo e preço informados.
4. `dividirConta :: Int -> Int -> (Int, Int)` — Divide o total em centavos (`Int`) pelo número de pessoas (`Int`), devolvendo `(valor por pessoa, centavos que sobram)` via `div` e `mod`.
5. `arredondar2 :: Double -> Double` — Arredonda valores em ponto flutuante para duas casas decimais usando `round` e `fromIntegral`.

### Função de Extensão
6. `paradasAbastecimento :: Int -> Double -> Double -> Int` — Calcula o número mínimo de tanques/paradas necessárias na viagem a partir da distância (`Int`), consumo (`Double`) e capacidade do tanque (`Double`), convertendo explicitamente com `fromIntegral` e arredondando para cima com `ceiling`.

---

## Como Executar e Compilar

### 1. Usando o Interpretador Interativo (`GHCi`)

Para testar as funções interativamente no terminal:

```bash
ghci Aplicacao.hs
```

Dentro do prompt `ghci>`, execute:

```haskell
mediaInteiros [6,8,10]
consumoMedio 420 35
custoViagem 600 12 6.0
dividirConta 10000 3
arredondar2 3.14159
paradasAbastecimento 600 12.0 40.0
main
```

Para carregar o exemplo conceitual no GHCi:

```bash
ghci Exemplo1.hs
```

---

### 2. Compilando com o `GHC` (com verificação `-Wall`)

#### No Windows (PowerShell):
```powershell
# Compilar e executar o Exemplo Conceitual
ghc -Wall Exemplo1.hs -o exemplo1.exe
.\exemplo1.exe

# Compilar e executar a Aplicacao Pratica (Planejador de Viagens)
ghc -Wall Aplicacao.hs -o aplicacao.exe
.\aplicacao.exe
```

#### No Linux ou macOS:
```bash
# Compilar e executar o Exemplo Conceitual
ghc -Wall Exemplo1.hs -o exemplo1
./exemplo1

# Compilar e executar a Aplicacao Pratica (Planejador de Viagens)
ghc -Wall Aplicacao.hs -o aplicacao
./aplicacao
```

*(Alternativamente, para rodar sem gerar arquivos executáveis, utilize `runghc Exemplo1.hs` e `runghc Aplicacao.hs`).*

---

### 3. Compilando a Comparação Imperativa em C (`GCC`)

```powershell
gcc -Wall ComparacaoImperativa.c -o comparacao.exe
.\comparacao.exe
```

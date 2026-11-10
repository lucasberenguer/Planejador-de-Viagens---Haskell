# SÍNTESE DAS DESCOBERTAS

**Tema:** 11 - Tipagem forte e conversões numéricas em um planejador de viagens  
**Equipe:** [Equipe de Viagens]    

---

## 1. O conceito em poucas palavras

O Haskell adota um sistema de **tipagem estática e forte**, no qual cada expressão possui um tipo bem definido em tempo de compilação e **não existem conversões implícitas (coerções silenciosas)** entre tipos numéricos diferentes. Enquanto linguagens imperativas como C promovem automaticamente um `int` para `double` ou truncam divisões inteiras sem avisar, somar ou dividir um `Int` com um `Double` em Haskell gera erro de compilação. Para combinar tipos distintos, o programador deve explicitar sua intenção usando funções de conversão baseadas em classes de tipos, como `fromIntegral` (de inteiros para qualquer tipo numérico) e `round`, `truncate`, `floor` ou `ceiling` (de reais para inteiros). Além disso, o Haskell separa claramente inteiros de precisão fixa de 64 bits (`Int`) de inteiros de precisão arbitrária (`Integer`), e operadores de divisão inteira (`div`, `quot`) da divisão real (`/`).

---

## 2. Resposta ao desafio investigativo

Todos os experimentos abaixo foram executados no **GHCi 9.10.3** e estão reproduzidos no arquivo [`Exemplo1.hs`](Exemplo1.hs).

### 2.1. `2^63` e `product [1..25]` com `Int` vs `Integer`

**Comandos e saídas no GHCi:**
```text
ghci> (maxBound :: Int)
9223372036854775807
ghci> 2^63 :: Int
-9223372036854775808
ghci> 2^63 :: Integer
9223372036854775808
ghci> product [1..25] :: Int
7034535277573963776
ghci> product [1..25] :: Integer
15511210043330985984000000
```

**Conclusão:**  
O tipo `Int` utiliza representação em complemento de dois com tamanho fixo da arquitetura (64 bits em máquinas modernas), cujo valor máximo é $2^{63} - 1$ (`9223372036854775807`). Ao calcular `2^63 :: Int`, o bit mais significativo (bit de sinal) é atingido, provocando **transbordamento (*integer overflow*)** para o menor valor negativo (`minBound :: Int`, que é $-2^{63}$). No caso de $25!$ (`product [1..25]`), o valor real requer cerca de 84 bits; em `Int`, múltiplos estouros descartam os bits superiores e produzem um número positivo completamente incorreto (`7034535277573963776`). Já o tipo `Integer` aloca memória dinamicamente conforme necessário (precisão arbitrária), entregando os resultados exatos.

---

### 2.2. Por que `sum xs / length xs` não compila?

**Comandos e saídas no GHCi:**
```text
ghci> :t sum
sum :: (Foldable t, Num a) => t a -> a
ghci> :t length
length :: Foldable t => t a -> Int
ghci> :t (/)
(/) :: Fractional a => a -> a -> a
ghci> let xs = [6, 8, 10] :: [Int]
ghci> sum xs / length xs
<interactive>:2:8: error: [GHC-39999]
    * No instance for `Fractional Int' arising from a use of `/'
    * In the expression: sum xs / length xs
```
*(E mesmo que `xs` seja `[Double]`, ocorre o erro `Couldn't match expected type 'Double' with actual type 'Int'` no segundo argumento `length xs`).*

**Conclusão:**  
Há dois impedimentos de tipo:
1. A função `length` **sempre devolve `Int`**, independentemente do tipo dos elementos da lista.
2. O operador de divisão real `(/)` exige que ambos os operandos sejam do mesmo tipo `a` pertencente à classe `Fractional` (como `Float` ou `Double`). O tipo `Int` **não** é instância de `Fractional`. Para compilar, é obrigatório converter ambos os lados com `fromIntegral`:
   ```haskell
   fromIntegral (sum xs) / fromIntegral (length xs)
   ```

---

### 2.3. Arredondamento (`round 2.5` vs `round 3.5`) e Divisão (`div` vs `quot`)

**Comandos e saídas no GHCi:**
```text
ghci> round 2.5
2
ghci> round 3.5
4
ghci> div (-7) 2
-4
ghci> quot (-7) 2
-3
ghci> divMod (-7) 2
(-4,1)
ghci> quotRem (-7) 2
(-3,-1)
```

**Conclusão:**
* **`round 2.5` e `round 3.5`:** O Haskell utiliza o **arredondamento bancário** (*round half to even*, padrão IEEE 754). Quando a parte fracionária é exatamente `0.5` (equidistante entre dois inteiros), `round` escolhe o **inteiro par mais próximo** (`2` para `2.5` e `4` para `3.5`). Isso evita o viés estatístico de acumular erros sempre para cima em grandes volumes de dados financeiros.
* **`div (-7) 2` vs `quot (-7) 2`:** A divisão exata é `-3.5`.
  * `div` trunca em direção ao **infinito negativo ($\lfloor -3.5 \rfloor = -4$)**, fazendo com que `mod (-7) 2` tenha o mesmo sinal do divisor (`+1`), pois $(-4) \times 2 + 1 = -7$. É ideal para aritmética modular (índices circulares, relógios).
  * `quot` trunca em direção ao **zero ($\text{truncate}(-3.5) = -3$)**, igual ao operador `/` de inteiros em C. Por isso, `rem (-7) 2` resulta em `-1`, pois $(-3) \times 2 + (-1) = -7$.

---

### 2.4. Ponto Flutuante (`0.1 + 0.2 == 0.3`) e Centavos Inteiros

**Comandos e saídas no GHCi:**
```text
ghci> 0.1 + 0.2
0.30000000000000004
ghci> 0.1 + 0.2 == 0.3
False
```

**Conclusão:**  
Os tipos `Float` e `Double` seguem o padrão binário IEEE 754. Assim como $\frac{1}{3}$ é uma dízima periódica na base 10 ($0.333\dots$), as frações decimais $\frac{1}{10}$ (`0.1`) e $\frac{2}{10}$ (`0.2`) são **dízimas periódicas infinitas na base 2** ($0.0001100110011\dots_2$). Como a mantissa do `Double` tem apenas 53 bits, ocorre um arredondamento na representação binária de cada número, e a soma acumula um resíduo (`0.30000000000000004`), tornando a comparação `== 0.3` falsa.  
Por esse motivo, **sistemas financeiros e bancários armazenam valores monetários em centavos inteiros** (`Int` ou `Integer`, onde R$ 0,10 = `10` e R$ 0,20 = `20`), pois a aritmética inteira é 100% exata em base 2 (`10 + 20 == 30` é sempre `True`), como aplicado na função `dividirConta` do nosso planejador de viagens.

---

## 3. Principais descobertas

1. **Silêncio no Overflow de `Int`:** Assim como em C, o tipo `Int` em Haskell **não lança exceção** quando ultrapassa `maxBound` (`9223372036854775807`); ele dá a volta (*wrap-around*) silenciosamente para números negativos. Para cálculos combinatórios ou fatoriais (como `product [1..25]`), deve-se usar `Integer`.
2. **Papel Polimórfico de `fromIntegral`:** A assinatura `fromIntegral :: (Integral a, Num b) => a -> b` permite converter qualquer inteiro (`Int` ou `Integer`) para qualquer tipo numérico (`Double`, `Float`, `Integer`, etc.), funcionando como a ponte universal e explícita entre inteiros e reais.
3. **Eliminação do Bug da Divisão Inteira Acidental:** Em C, dividir duas variáveis `int` e guardar em um `double` (`double m = soma / n;`) trunca o resultado silenciosamente antes da atribuição. Em Haskell, a separação entre `div :: Integral a => a -> a -> a` e `(/) :: Fractional a => a -> a -> a` torna esse bug impossível de compilar.
4. **Arredondamento Sem Viés Estatístico:** A função `round` do Haskell difere da função `round()` da biblioteca `<math.h>` do C: enquanto o C arredonda `.5` afastando do zero (`round(2.5) == 3.0`), o Haskell arredonda para o par mais próximo (`round 2.5 == 2`), reduzindo erros acumulados em séries de arredondamentos.
5. **Escolha Semântica do Arredondamento na Extensão (`ceiling`):** Na função de extensão `paradasAbastecimento`, descobrimos que `round` ou `truncate` seriam incorretos na prática: se uma viagem exige `1.25` tanques de combustível, arredondar para o mais próximo daria `1` tanque e o veículo ficaria sem combustível na estrada. O uso de `ceiling` garante segurança operacional ao arredondar qualquer fração excedente para o inteiro superior (`2`).

---

## 4. Comparação com a abordagem imperativa

No arquivo [`ComparacaoImperativa.c`](ComparacaoImperativa.c), implementamos a função `mediaInteiros` em C para contrastar com a versão em Haskell de [`Aplicacao.hs`](Aplicacao.hs):

| Aspecto | Linguagem C (`ComparacaoImperativa.c`) | Haskell (`Aplicacao.hs`) |
| :--- | :--- | :--- |
| **Conversão `int` $\rightarrow$ `double`** | Implícita em expressões mistas (`km / litros`), mas perigosa quando ambos são `int` (`soma / n`). | Sempre explícita via `fromIntegral`, documentando no código onde ocorre mudança de domínio numérico. |
| **Divisão inteira vs. real** | Usa o mesmo símbolo `/` para ambos; o comportamento depende silenciosamente do tipo dos operandos. | Símbolos e classes separados: `div`/`quot` (`Integral`) para inteiros e `/` (`Fractional`) para reais. |
| **Retorno de múltiplos valores (`dividirConta`)** | Exige ponteiros/passagem por referência (`int *porPessoa, int *sobra`) e mutação de variáveis externas. | Retorna uma tupla pura e imutável `(Int, Int)` diretamente com `(div, mod)`. |
| **Controle de estado** | Usa laço `for` e variável acumuladora mutável `int soma = 0;`. | Expressão declarativa pura: `fromIntegral (sum xs) / fromIntegral (length xs)`. |

---

## 5. Dificuldades e limitações

* **Dificuldades encontradas e como foram resolvidas:**
  * *Arredondamento para $N$ casas decimais:* O `Prelude` do Haskell não possui uma função pronta que arredonde um `Double` diretamente para outro `Double` com 2 casas decimais, pois `round` devolve um tipo `Integral` (`Int` ou `Integer`), e não `Double`. Resolvemos isso em `arredondar2` multiplicando por `100.0`, aplicando `round` para obter os centésimos inteiros e reconvertendo com `fromIntegral` antes de dividir por `100.0`.
  * *Avisos de `type defaulting` com `-Wall`:* Ao compilar com `ghc -Wall`, expressões como `2 ^ 63` ou `round (valor * 100.0)` geram avisos de *type-defaults* se o tipo do expoente ou do inteiro intermediário não for anotado. Resolvemos anotando explicitamente (`2 ^ (63 :: Int)` e `round (valor * 100.0) :: Integer`), garantindo compilação limpa com zero avisos.
* **Limitações do conceito:**
  * A obrigatoriedade de usar `fromIntegral` em toda operação mista entre `Int` e `Double` torna fórmulas matemáticas longas mais verbosas do que em linguagens com coerção automática.
  * Mesmo com tipagem forte, o tipo `Double` continua sujeito às limitações físicas do padrão IEEE 754 (imprecisão binária de frações decimais), exigindo que sistemas críticos usem inteiros em centavos ou bibliotecas específicas de aritmética decimal.

---

## 6. Quadro de contribuições

> *(Preencha os nomes dos integrantes da sua equipe abaixo antes da entrega final)*

| Integrante | Funções implementadas | Pesquisa | Parte da apresentação |
| :--- | :--- | :--- | :--- |
| **[Integrante 1]** | `mediaInteiros`, `consumoMedio` | Tipagem forte, `fromIntegral` e erro `sum xs / length xs` | Parte 1: Introdução e Contextualização |
| **[Integrante 2]** | `custoViagem`, `dividirConta` | Transbordamento (`Int` vs `Integer`) e `div`/`mod` vs `quot`/`rem` | Parte 2: Investigação Técnica e Desafio |
| **[Integrante 3]** | `arredondar2`, `paradasAbastecimento` (extensão) | Arredondamento bancário (`round`) e ponto flutuante IEEE 754 | Parte 3: Demonstração Prática ao Vivo |
| **[Integrante 4]** *(se houver)* | `main` (`Aplicacao.hs`) e `ComparacaoImperativa.c` | Comparativo C vs Haskell e casos limite | Parte 4 e 5: Análise Crítica e Interação com a Turma |

---

## 7. Referências

1. **HASKELL.ORG.** *Documentation & GHC User's Guide*. Disponível em: https://www.haskell.org/documentation/ .
2. **HASKELL.** *Documentação oficial do módulo Prelude (Classes Num, Integral, Fractional, RealFrac)*. Disponível em: https://hackage.haskell.org/package/base/docs/Prelude.html .
3. **HUTTON, G.** *Programming in Haskell*. 2. ed. Cambridge: Cambridge University Press, 2016. (Capítulos 2 e 3: Tipos e Classes).
4. **LIPOVAČA, M.** *Learn You a Haskell for Great Good!* San Francisco: No Starch Press, 2011. Disponível em: http://learnyouahaskell.com/types-and-typeclasses .
5. **BIRD, R.** *Thinking Functionally with Haskell*. Cambridge: Cambridge University Press, 2014.
6. **GOLDBERG, D.** *What Every Computer Scientist Should Know About Floating-Point Arithmetic*. ACM Computing Surveys, v. 23, n. 1, p. 5–48, 1991.

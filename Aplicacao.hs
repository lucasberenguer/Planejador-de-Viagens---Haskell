-- ============================================================================
-- Seminario Tecnico: Programacao Funcional com Haskell (CESAR School - 2026.2)
-- Tema 11: Tipagem forte e conversoes numericas em um planejador de viagens
-- Arquivo: Aplicacao.hs (Aplicacao Pratica, Extensao e Testes no main)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FUNCOES OBRIGATORIAS DO TEMA 11
-- Regras:
-- 1. Toda conversao de tipo deve ser explicita e comentada no codigo.
-- 2. Proibido alterar as assinaturas para evitar conversoes.
-- ----------------------------------------------------------------------------

-- 1. Media de quilometros por dia; 0.0 para lista vazia.
-- Exemplo do catalogo: mediaInteiros [6,8,10] resulta em 8.0.
mediaInteiros :: [Int] -> Double
mediaInteiros [] = 0.0
mediaInteiros xs =
    -- sum xs :: Int e length xs :: Int.
    -- O operador (/) exige tipos da classe Fractional (como Double).
    -- Por isso, convertemos ambos explicitamente com fromIntegral :: Int -> Double.
    fromIntegral (sum xs) / fromIntegral (length xs)

-- 2. Quilometros rodados (Int) e litros gastos (Double); devolve km por litro (Double).
-- Exemplo do catalogo: consumoMedio 420 35 resulta em 12.0.
consumoMedio :: Int -> Double -> Double
consumoMedio km litros
    | litros <= 0.0 = 0.0
    | otherwise     =
        -- km :: Int precisa ser convertido explicitamente com fromIntegral para Double
        -- antes de ser dividido por litros :: Double usando (/).
        fromIntegral km / litros

-- 3. Distancia em km (Int), consumo em km/l (Double) e preco do litro (Double);
-- devolve o custo do combustivel (Double).
-- Exemplo do catalogo: custoViagem 600 12 6.0 resulta em 300.0.
custoViagem :: Int -> Double -> Double -> Double
custoViagem distanciaKm kmPorLitro precoLitro
    | kmPorLitro <= 0.0 = 0.0
    | otherwise         =
        -- distanciaKm :: Int eh convertido explicitamente para Double via fromIntegral
        -- para calcular os litros necessarios em ponto flutuante.
        let litrosNecessarios = fromIntegral distanciaKm / kmPorLitro
        in litrosNecessarios * precoLitro

-- 4. Total em centavos (Int) e numero de pessoas (Int);
-- devolve (valor por pessoa, centavos que sobram).
-- Exemplo do catalogo: dividirConta 10000 3 resulta em (3333,1).
dividirConta :: Int -> Int -> (Int, Int)
dividirConta totalCentavos pessoas
    | pessoas <= 0 = (0, totalCentavos)
    | otherwise    =
        -- Aqui operamos apenas com Int usando divisao inteira (div) e resto (mod),
        -- evitando erros de precisao de ponto flutuante em valores monetarios.
        (totalCentavos `div` pessoas, totalCentavos `mod` pessoas)

-- 5. Arredonda um Double para duas casas decimais.
-- Exemplo do catalogo: arredondar2 3.14159 resulta em 3.14.
arredondar2 :: Double -> Double
arredondar2 valor =
    -- 1) Multiplicamos por 100.0 para deslocar duas casas decimais.
    -- 2) round :: Double -> Integer arredonda para o inteiro mais proximo.
    -- 3) fromIntegral :: Integer -> Double converte o inteiro de volta para Double
    --    para podermos dividir por 100.0 com o operador (/).
    let centesimosInteiros = round (valor * 100.0) :: Integer
    in fromIntegral centesimosInteiros / 100.0

-- ----------------------------------------------------------------------------
-- FUNCAO DE EXTENSAO
-- Calculo do numero minimo de paradas para abastecer durante a viagem.
-- Recebe: distancia total em km (Int), consumo medio em km/l (Double)
--         e capacidade do tanque em litros (Double).
-- Devolve: quantidade inteira de tanques/paradas necessarias (Int).
-- ----------------------------------------------------------------------------
paradasAbastecimento :: Int -> Double -> Double -> Int
paradasAbastecimento distanciaKm kmPorLitro capacidadeTanque
    | distanciaKm <= 0 || kmPorLitro <= 0.0 || capacidadeTanque <= 0.0 = 0
    | otherwise =
        -- 1) fromIntegral converte distanciaKm (Int) para Double.
        -- 2) Calculamos quantos tanques fracionarios a viagem consome (Double).
        -- 3) ceiling :: Double -> Int arredonda sempre para cima (teto),
        --    pois qualquer fracao extra de tanque exige uma parada adicional.
        let autonomiaPorTanque = kmPorLitro * capacidadeTanque
            tanquesNecessarios = fromIntegral distanciaKm / autonomiaPorTanque
        in ceiling tanquesNecessarios

-- ----------------------------------------------------------------------------
-- PROGRAMA PRINCIPAL (main) - DEMONSTRACAO PRATICA E CASOS LIMITE
-- ----------------------------------------------------------------------------
main :: IO ()
main = do
    putStrLn "============================================================"
    putStrLn "   PLANEJADOR DE VIAGENS - TEMA 11 (TIPAGEM E CONVERSOES)   "
    putStrLn "============================================================"
    putStrLn ""

    putStrLn "--- 1. Exemplos Oficiais do Catalogo ---"
    putStrLn ("mediaInteiros [6,8,10]          = " ++ show (mediaInteiros [6, 8, 10]) ++ " (esperado: 8.0)")
    putStrLn ("consumoMedio 420 35             = " ++ show (consumoMedio 420 35) ++ " (esperado: 12.0)")
    putStrLn ("custoViagem 600 12 6.0          = " ++ show (custoViagem 600 12 6.0) ++ " (esperado: 300.0)")
    putStrLn ("dividirConta 10000 3            = " ++ show (dividirConta 10000 3) ++ " (esperado: (3333,1))")
    putStrLn ("arredondar2 3.14159             = " ++ show (arredondar2 3.14159) ++ " (esperado: 3.14)")
    putStrLn ""

    putStrLn "--- 2. Funcao de Extensao (Paradas para Abastecimento) ---"
    putStrLn ("paradasAbastecimento 600 12.0 40.0  = " ++ show (paradasAbastecimento 600 12.0 40.0) ++ " paradas (autonomia 480km -> teto(1.25) = 2)")
    putStrLn ("paradasAbastecimento 960 12.0 40.0  = " ++ show (paradasAbastecimento 960 12.0 40.0) ++ " paradas (autonomia exata 480km -> teto(2.0) = 2)")
    putStrLn ("paradasAbastecimento 1000 12.5 45.0 = " ++ show (paradasAbastecimento 1000 12.5 45.0) ++ " paradas (autonomia 562.5km -> teto(1.77) = 2)")
    putStrLn ""

    putStrLn "--- 3. Simulacao Completa de uma Viagem entre Amigos ---"
    let trechosDiarios = [185, 240, 310, 190] :: [Int]
        kmTotal        = sum trechosDiarios
        litrosGastos   = 74.0 :: Double
        precoGasolina  = 5.89 :: Double
        capacidadeTanq = 45.0 :: Double
        amigos         = 3 :: Int
        mediaKmDia     = mediaInteiros trechosDiarios
        kmPorLitro     = consumoMedio kmTotal litrosGastos
        custoBruto     = custoViagem kmTotal kmPorLitro precoGasolina
        custoArred     = arredondar2 custoBruto
        -- Conversao explicita de Reais (Double) para Centavos (Int) via round:
        totalCentavos  = round (custoArred * 100.0) :: Int
        divisao        = dividirConta totalCentavos amigos
        numParadas     = paradasAbastecimento kmTotal kmPorLitro capacidadeTanq

    putStrLn ("Trechos diarios (km)        : " ++ show trechosDiarios)
    putStrLn ("Distancia total (km)        : " ++ show kmTotal)
    putStrLn ("Media diaria (km/dia)       : " ++ show (arredondar2 mediaKmDia))
    putStrLn ("Consumo medio (km/l)        : " ++ show (arredondar2 kmPorLitro))
    putStrLn ("Custo bruto (R$)            : " ++ show custoBruto)
    putStrLn ("Custo arredondado (R$)      : " ++ show custoArred)
    putStrLn ("Total em centavos (Int)     : " ++ show totalCentavos ++ " centavos")
    putStrLn ("Divisao entre 3 amigos      : " ++ show divisao ++ " (centavos por pessoa, sobra)")
    putStrLn ("Tanques/paradas necessarias : " ++ show numParadas)
    putStrLn ""

    putStrLn "--- 4. Testes com Casos Limite (Lista Vazia, Divisoes Nao Exatas, Zero) ---"
    putStrLn ("mediaInteiros [] (lista vazia)  = " ++ show (mediaInteiros []))
    putStrLn ("mediaInteiros [7, 8] (nao exata)= " ++ show (mediaInteiros [7, 8]))
    putStrLn ("consumoMedio 350 0.0 (litros=0) = " ++ show (consumoMedio 350 0.0))
    putStrLn ("dividirConta 500 5 (sem sobra)  = " ++ show (dividirConta 500 5))
    putStrLn ("dividirConta 500 0 (pessoas=0)  = " ++ show (dividirConta 500 0))
    putStrLn ("arredondar2 (-15.678) (negativo)= " ++ show (arredondar2 (-15.678)))
    putStrLn ("paradasAbastecimento 0 12 40    = " ++ show (paradasAbastecimento 0 12.0 40.0))

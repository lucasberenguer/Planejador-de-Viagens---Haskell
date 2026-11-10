-- ============================================================================
-- Seminario Tecnico: Programacao Funcional com Haskell (CESAR School - 2026.2)
-- Tema 11: Tipagem forte e conversoes numericas em um planejador de viagens
-- Arquivo: Exemplo1.hs (Exemplo Conceitual e Experimento do Desafio)
-- ============================================================================

-- 1. Int (precisao fixa de 64 bits) vs Integer (precisao arbitraria)
potencia63Int :: Int
potencia63Int = 2 ^ (63 :: Int)

potencia63Integer :: Integer
potencia63Integer = 2 ^ (63 :: Int)

fatorial25Int :: Int
fatorial25Int = product [1..25]

fatorial25Integer :: Integer
fatorial25Integer = product [1..25]

-- 2. Conversao explicita obrigatoria: por que sum xs / length xs exige fromIntegral?
-- Em Haskell, length :: [a] -> Int e (/) :: Fractional a => a -> a -> a.
-- Como Int nao pertence a classe Fractional e nao ha conversao implícita,
-- usamos fromIntegral :: (Integral a, Num b) => a -> b para converter Int em Double.
mediaConceitual :: [Int] -> Double
mediaConceitual [] = 0.0
mediaConceitual xs = fromIntegral (sum xs) / fromIntegral (length xs)

-- 3. Arredondamentos: round (bancario/par mais proximo), truncate, floor e ceiling
amostraArredondamento :: Double -> (Int, Int, Int, Int)
amostraArredondamento x = (round x, truncate x, floor x, ceiling x)

-- 4. Divisao inteira: div/mod (direcao a -infinito) vs quot/rem (direcao a zero, como em C)
compararDivisoes :: Int -> Int -> ((Int, Int), (Int, Int))
compararDivisoes a b = (divMod a b, quotRem a b)

-- 5. Precisao de ponto flutuante (IEEE 754) vs centavos inteiros
somaPontoFlutuante :: Double
somaPontoFlutuante = 0.1 + 0.2

testeIgualdadeReal :: Bool
testeIgualdadeReal = (0.1 + 0.2 :: Double) == 0.3

somaEmCentavos :: Int
somaEmCentavos = 10 + 20

testeIgualdadeCentavos :: Bool
testeIgualdadeCentavos = somaEmCentavos == 30

main :: IO ()
main = do
    putStrLn "=== TEMA 11: EXEMPLO CONCEITUAL E DESAFIO INVESTIGATIVO ==="
    putStrLn ""

    putStrLn "1. Transbordamento (Overflow): Int vs Integer"
    putStrLn ("   maxBound :: Int           = " ++ show (maxBound :: Int))
    putStrLn ("   minBound :: Int           = " ++ show (minBound :: Int))
    putStrLn ("   2^63 :: Int               = " ++ show potencia63Int ++ " (OVERFLOW!)")
    putStrLn ("   2^63 :: Integer           = " ++ show potencia63Integer ++ " (Exato)")
    putStrLn ("   product [1..25] :: Int    = " ++ show fatorial25Int ++ " (OVERFLOW!)")
    putStrLn ("   product [1..25] :: Integer= " ++ show fatorial25Integer ++ " (Exato)")
    putStrLn ""

    putStrLn "2. Conversao Explicita na Media (fromIntegral)"
    putStrLn ("   mediaConceitual [6, 8, 10]= " ++ show (mediaConceitual [6, 8, 10]))
    putStrLn ("   mediaConceitual [7, 8]    = " ++ show (mediaConceitual [7, 8]))
    putStrLn ""

    putStrLn "3. Funcoes de Arredondamento: (round, truncate, floor, ceiling)"
    putStrLn ("   x =  2.5 -> " ++ show (amostraArredondamento 2.5) ++ " (round 2.5 vai para o par 2)")
    putStrLn ("   x =  3.5 -> " ++ show (amostraArredondamento 3.5) ++ " (round 3.5 vai para o par 4)")
    putStrLn ("   x = -2.3 -> " ++ show (amostraArredondamento (-2.3)))
    putStrLn ""

    putStrLn "4. Divisao de Negativos: (div, mod) vs (quot, rem)"
    putStrLn ("   Para -7 e 2 -> (divMod, quotRem) = " ++ show (compararDivisoes (-7) 2))
    putStrLn "   Explicacao: div (-7) 2 = -4 (piso, resto +1); quot (-7) 2 = -3 (trunca p/ 0, resto -1)."
    putStrLn ""

    putStrLn "5. Ponto Flutuante (Double) vs Centavos Inteiros (Int)"
    putStrLn ("   0.1 + 0.2 em Double       = " ++ show somaPontoFlutuante)
    putStrLn ("   (0.1 + 0.2) == 0.3        = " ++ show testeIgualdadeReal)
    putStrLn ("   10 + 20 == 30 (centavos)  = " ++ show testeIgualdadeCentavos)

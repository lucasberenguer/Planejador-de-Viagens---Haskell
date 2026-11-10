/* ============================================================================
 * Seminario Tecnico: Programacao Funcional com Haskell (CESAR School - 2026.2)
 * Tema 11: Tipagem forte e conversoes numericas em um planejador de viagens
 * Arquivo: ComparacaoImperativa.c (Comparacao C vs Haskell - Exigencia 5)
 * ============================================================================
 */

#include <stdio.h>
#include <math.h>

/* 1. ARMADILHA CLASSICA EM C: Divisao inteira silenciosa
 * Como 'soma' e 'n' sao int, o operador '/' faz divisao inteira (truncando a
 * parte decimal) ANTES de converter o resultado para double no return!
 * Em Haskell, (/) nao aceita Int: o compilador impede esse erro em tempo de compilacao.
 */
double mediaInteirosBugada(const int xs[], int n) {
    if (n <= 0) return 0.0;
    int soma = 0;
    for (int i = 0; i < n; i++) {
        soma += xs[i];
    }
    return soma / n; /* BUG SILENCIOSO: 15 / 2 vira 7, e depois 7.0! */
}

/* Versao corrigida em C com cast explicito (double) */
double mediaInteirosCorreta(const int xs[], int n) {
    if (n <= 0) return 0.0;
    int soma = 0;
    for (int i = 0; i < n; i++) {
        soma += xs[i];
    }
    return (double)soma / (double)n;
}

/* 2. Consumo medio: em C, int km eh promovido silenciosamente para double */
double consumoMedio(int km, double litros) {
    if (litros <= 0.0) return 0.0;
    return km / litros; /* Conversao implicita (silent promotion) de int para double */
}

/* 3. Divisao de conta em centavos */
void dividirConta(int totalCentavos, int pessoas, int *porPessoa, int *sobra) {
    if (pessoas <= 0) {
        *porPessoa = 0;
        *sobra = totalCentavos;
        return;
    }
    *porPessoa = totalCentavos / pessoas;
    *sobra = totalCentavos % pessoas;
}

int main(void) {
    int trechos[] = {7, 8}; /* Soma = 15, media real = 7.5 */
    int n = 2;

    printf("=== COMPARACAO IMPERATIVA EM C (TEMA 11) ===\n\n");

    printf("1. Armadilha da divisao inteira silenciosa em C:\n");
    printf("   mediaInteirosBugada([7, 8])  = %.2f (Truncou 15/2 para 7 sem aviso!)\n",
           mediaInteirosBugada(trechos, n));
    printf("   mediaInteirosCorreta([7, 8]) = %.2f (Com cast explicito (double))\n\n",
           mediaInteirosCorreta(trechos, n));

    printf("2. Divisao de negativos em C (/ e %%) equivale a quot e rem do Haskell:\n");
    printf("   -7 / 2 = %d (trunca em direcao a zero, igual a quot (-7) 2)\n", -7 / 2);
    printf("   -7 %% 2 = %d (resto negativo, igual a rem (-7) 2)\n\n", -7 % 2);

    printf("3. Arredondamento em C (round de math.h vs round do Haskell):\n");
    printf("   round(2.5) em C = %.1f (afasta do zero; em Haskell round 2.5 = 2, par mais proximo)\n",
           round(2.5));
    printf("   round(3.5) em C = %.1f (afasta do zero; em Haskell round 3.5 = 4, par mais proximo)\n\n",
           round(3.5));

    int quota = 0, resto = 0;
    dividirConta(10000, 3, &quota, &resto);
    printf("4. Dividir conta (10000 centavos para 3 pessoas): (%d, %d)\n", quota, resto);

    return 0;
}

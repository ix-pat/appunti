# Parametri del generatore
b <- 1664525
a <- 1013904223
N <- 2^(32)
x0 <- 1       # seme iniziale
n <- 1000       # quanti valori generare

# Inizializzazione
x <- numeric(n)
x[1] <- x0

# Generazione ricorsiva
for (i in 2:n) {
  x[i] <- (a + b * x[i-1]) %% N
}

# Stampa dei risultati
print(x)

# Eventuale visualizzazione della distribuzione
hist(x, col = "lightblue", main = "Distribuzione dei valori generati", xlab = "Valori")

set.seed(42)

# Parametri del modello
sge <- 0.8
sigma2 <- sge^2
x <- (1:10)/10
n <- length(x)
X <- cbind(1, x)
beta <- c(0, 1)

# Matrice teorica di covarianza
XtX_inv <- solve(t(X) %*% X)
V_theo <- sigma2 * XtX_inv

# Simulazione
B <- 100000
betas <- matrix(NA, nrow = B, ncol = 2)

for (i in 1:B) {
  y <- X %*% beta + rnorm(n, mean = 0, sd = sge)
  fit <- lsfit(x, y)
  betas[i, ] <- fit$coefficients
}

# Matrice empirica
V_emp <- cov(betas)

# Confronto
round(V_emp, 5)
round(V_theo, 5)








library(mvtnorm)

# 1. Parametri
mu <- c(0, 1)
CS <- matrix(c(0.3049, -0.4370, -0.4370, 0.7919), nrow = 2, byrow = TRUE)

# 2. Simula 10000 osservazioni da N(mu, CS)
set.seed(1230)
sim <- rmvnorm(1000, mean = mu, sigma = CS)

cs <- cov(sim)
# 3. Griglia per la densità teorica
b0gr <- seq(min(sim[,1]), max(sim[,1]), length.out = 101)
b1gr <- seq(min(sim[,2]), max(sim[,2]), length.out = 101)
grid <- expand.grid(b0 = b0gr, b1 = b1gr)

# 4. Densità teorica su griglia
dens_vals <- dmvnorm(grid, mean = mu, sigma = cs)
dens_mat <- matrix(dens_vals, nrow = 101, byrow = F)

# 5. Grafico
image(b0gr, b1gr, dens_mat, col = rev(gray.colors(100)),
      xlab = expression(beta[0]), ylab = expression(beta[1]),
      main = "Simulazione da N(mu, Sigma) + densità teorica")
contour(b0gr, b1gr, (dens_mat), drawlabels = FALSE)
points(sim[,1], sim[,2], pch = 16, cex = 1, col = adjustcolor("blue", 0.2))

points(mu[1], mu[2], pch = 3, col = "red", cex = 1.5)

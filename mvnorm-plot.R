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
B <- 10000
betas <- matrix(NA, nrow = B, ncol = 2)

for (i in 1:B) {
  y <- X %*% beta + rnorm(n, mean = 0, sd = sge)
  fit <- lsfit(x, y)
  betas[i, ] <- fit$coefficients
}

# Matrice empirica
V_emp <- cov(betas)

# Confronto
round(V_emp, 5)[1:4]
round(V_theo, 5)



library(mvtnorm)

# 1. Parametri
mu <- c(0, 1)
CS <- matrix(V_emp[1:4], nrow = 2, byrow = TRUE)
CS <- V_theo

# 2. Simula 10000 osservazioni da N(mu, CS)
set.seed(1230)
sim <- rmvnorm(1000, mean = mu, sigma = CS)

cs <- cov(sim)
# 3. Griglia per la densità teorica
b0gr <- seq(min(sim[,1])-.1, max(sim[,1])+.1, length.out = 101)
b1gr <- seq(min(sim[,2])-.1, max(sim[,2])+.1, length.out = 101)
grid <- expand.grid(b0 = b0gr, b1 = b1gr)

# 4. Densità teorica su griglia
# 

f_norm <- function(x) {
  y <- x[2]
  x <- x[1]
  1 / (2 * pi * sqrt(det(CS))) * exp(-0.5 * t(c(x, y) - mu) %*% solve(CS) %*% (c(x, y) - mu))
}

dens_vals <- unname(apply(grid,1,f_norm))
dens_mat <- matrix(dens_vals, nrow = 101, byrow = T)

# 5. Grafico
image(b0gr, b1gr, dens_mat, col = rev(gray.colors(100)),
      xlab = expression(beta[0]), ylab = expression(beta[1]),
      main = "Simulazione da N(mu, Sigma) + densità teorica")
contour(b0gr, b1gr, (dens_mat), drawlabels = FALSE,add=T)
points(sim[,1], sim[,2], pch = 16, cex = 1, col = adjustcolor("red", 0.2))

points(mu[1], mu[2], pch = 3, col = "red", cex = 1.5)

############### DEFINITVA
############### 

set.seed(1000)
sge <- .8
sigma2 <- sge^2
x <- (1:10)/10
y <- x+rnorm(10,0,sge)
nrep <- 5000
V0 <- sge^2 * (1/10+mean(x)^2/(10*s2c(x))) 
V1 <- sge^2 / (10*s2c(x)) 
C12<- -mean(x)*V1

# generazione delle Y replicate
y_sim <- replicate(nrep, 0 + 1 * x + rnorm(length(x), sd=sge))

# calcolo delle stime b0 e b1 per ciascuna simulazione
X <- cbind(1, x)
XX1 <- solve(t(X) %*% X)
b_hat <- apply(y_sim, 2, function(y) XX1 %*% t(X) %*% y)
b_hat <- t(b_hat)  # righe = simulazioni
mu <- c(0,1)


# Matrice teorica di covarianza
CS <- sigma2 * XX1


b0gr <- seq(-3*sqrt(CS[1,1]),+3*sqrt(CS[1,1]),length.out = 101)
b1gr <- seq(1-3*sqrt(CS[2,2]),1+3*sqrt(CS[2,2]),length.out = 101)
b01  <- expand.grid(b0gr,b1gr)

f_norm <- function(x) {
  y <- x[2]
  x <- x[1]
  1 / (2 * pi * sqrt(det(CS))) * exp(-0.5 * t(c(x, y) - mu) %*% solve(CS) %*% (c(x, y) - mu))
}
sey <-function(x,n) sqrt(sge^2*(1/n+(x-mean(x))^2/(n*s2c(x))))

dens_vals <- unname(apply(b01,1,f_norm))
dens_mat <- matrix(dens_vals, nrow = 101, byrow = T)

par(mfrow=c(1,2),cex=cex)

plot(x,y,pch=16,cex=1,ylim=c(-1,3),lty=2,type="n",axes=F,xlab="x",ylab="y")
axis(1,x)
axis(2)
ppp <- matrix(nrow = 500,ncol=2)
for(i in 1:500){
  md <- b_hat[i,]
  abline(md,col="Grey")
}
abline(0,1,col="DarkRed",lwd=2)
abline(v=mean(x),lty=2)
abline(h=mean(x),lty=2)

curve(x+1.96*sey(x,n=10),add=T,lty=2,col="DarkRed",lwd=2)
curve(x-1.96*sey(x,n=10),add=T,lty=2,col="DarkRed",lwd=2)

# 5. Grafico
image(b0gr, b1gr, dens_mat, col = rev(gray.colors(100)),
      xlab = expression(beta[0]), ylab = expression(beta[1]),
      main = "Simulazione da N(mu, Sigma) + densità teorica")
contour(b0gr, b1gr, (dens_mat), drawlabels = FALSE,add=T)

points(b_hat[1:500,1],b_hat[1:500,2],pch=16,cex=.5,col="darkblue")
points(0,1,pch=3,col=2)



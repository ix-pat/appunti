library(shiny)

ui <- fluidPage(
  titlePanel("Funzione di Verosimiglianza Binomiale"),
  sidebarLayout(
    sidebarPanel(
      numericInput("pi_", "Pi stimato", value = .6, min = 0, max = 1,step = .1),
      numericInput("n", "Numero di prove (n):", value = 5, min = 0, max = 100000,step = 5)
    ),
    mainPanel(
      plotOutput("likelihoodPlot")
    )
  )
)

server <- function(input, output) {
  output$likelihoodPlot <- renderPlot({
    
    n <- input$n
    sn <- input$pi_ * n
    l <- function(x) log(x^sn * (1 - x)^(n - sn))-log((sn/n)^sn * (1 - sn/n)^(n - sn))
    L <- function(x) (x^sn * (1 - x)^(n - sn))/((sn/n)^sn * (1 - sn/n)^(n - sn))
    if (sn > n) return(NULL)
    
    pp <- (0:10)/10
    par(mfrow = c(1, 2), cex = 1.2)
    
    curve(L(x), 0, 1,
          axes = FALSE, xlab = expression(pi), ylab = expression(L(pi)),
          main = "Verosimiglianza", col = "blue")
    axis(1, pp)
    axis(2, las = 2)
    segments(sn / n, 0, sn / n, 1, lty = 2)
    
    curve(l(x), 0, 1, ylim = c(-20,0),
          axes = FALSE, xlab = expression(pi), ylab = expression(log~L(pi)),
          main = "Log-Verosimiglianza", col = "red")
    axis(1, pp)
    axis(2, las = 2)
    segments(sn / n, -20, sn / n, 0, lty = 2)
  })
}

shinyApp(ui = ui, server = server)
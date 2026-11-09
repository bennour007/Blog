make_network <- \(type, n = 1024) {                                         # <1>
  switch(type,
         everyone    = create_complete(n),                                       # <2>
         close_knit  = play_smallworld(n_dim = 1, dim_size = n,
                                       order = 2, p_rewire = 0),                 # <3>
         small_world = play_smallworld(n_dim = 1, dim_size = n,
                                       order = 2, p_rewire = 0.05),              # <4>
         random      = play_degree(rep(4, n), method = "vl"),                    # <5>
         scale_free  = play_barabasi_albert(n, power = 1, growth = 2,
                                            directed = FALSE)                    # <6>
  ) |>
    activate(nodes) |>
    filter(!node_is_isolated())                                             # <7>
}

simulate <- \(g, b, K = 0.1, rho0 = 0.5, steps = 1000, payoff_rule = "total", init = NULL) {
  n     <- igraph::vcount(g)
  A     <- igraph::as_adjacency_matrix(g, sparse = TRUE)                     # <8>
  deg   <- igraph::degree(g)
  nbrs  <- igraph::as_adj_list(g) |> map(as.integer) |> unlist()             # <9>
  start <- c(0, cumsum(deg))[seq_len(n)]

  step <- \(s, ...) {
    n_c  <- as.vector(A %*% s)                                               # <10>
    pay  <- if_else(s == 1, n_c, b * n_c)                                    # <11>
    if (payoff_rule == "average") pay <- pay / deg                           # <12>
    j    <- nbrs[start + ceiling(runif(n) * deg)]                            # <13>
    copy <- runif(n) < 1 / (1 + exp(-(pay[j] - pay) / K))                    # <14>
    if_else(copy, s[j], s)                                                   # <15>
  }

  accumulate(seq_len(steps), step, .init = init %||% rbinom(n, 1, rho0))     # <16>
}

start_with <- \(n, defectors) sample(c(rep(0, defectors), rep(1, n - defectors)))   # <17>

coop_over_time <- \(states) tibble(                                          # <18>
  round       = seq_along(states) - 1,
  cooperation = map_dbl(states, mean)
)

# precompute.R: run once from the post's folder
pacman::p_load(tidyverse, tidygraph, Matrix)
source(here::here("projects/gaming/model.R"))
set.seed(5)

networks <- c(
  close_knit  = "Close-knit",
  small_world = "Small world",
  random      = "Random",
  scale_free  = "Hubs"
)

# All runs for one network at one setting: cooperation in every round
run_setting <- \(network, b, K, runs = 5, steps = 300) {
  map(seq_len(runs), \(run) make_network(network) |>
        simulate(b = b, K = K, steps = steps) |>
        coop_over_time() |>
        mutate(run = run)) |>
    list_rbind()
}

# Vary one parameter, keep the other fixed
experiment <- \(param, values, fixed_b = 1.2, fixed_K = 0.1) {
  expand_grid(network = names(networks), value = round(values, 4)) |>
    mutate(runs = map2(network, value, \(network, value)
                       if (param == "K") run_setting(network, b = fixed_b, K = value)
                       else              run_setting(network, b = value,   K = fixed_K)
    )) |>
    unnest(runs) |>
    mutate(network = networks[network])
}

# Two files per parameter: the evolution, and the final level (with spread across runs)
write_experiment <- \(runs, param) {
  out_dir <- here::here("projects", "gaming")

  runs |>
    summarise(cooperation = round(mean(cooperation), 4),
              .by = c(network, value, round)) |>
    write_csv(fs::path(out_dir, str_glue("evolution_{param}.csv")))

  runs |>
    filter(round > max(round) - 50) |>
    summarise(final = mean(cooperation), .by = c(network, value, run)) |>
    summarise(mean = round(mean(final), 4),
              low  = round(min(final), 4),
              high = round(max(final), 4),
              .by = c(network, value)) |>
    write_csv(fs::path(out_dir, str_glue("sensitivity_{param}.csv")))
}

experiment("K", c(0.01, 0.03, 0.1, 0.3, 1, 3, 10)) |> write_experiment("K")
experiment("b", seq(1, 2, by = 0.05))             |> write_experiment("b")

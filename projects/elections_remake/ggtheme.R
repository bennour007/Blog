

article_theme <- theme(text = element_text(family = "DejaVu Sans Mono",
                                        color = "black",
                                        margin = margin(t = 10)),
                    panel.grid.major.y = element_blank(),
                    panel.grid.minor.y = element_blank(),
                    strip.background = element_blank(),
                    axis.ticks.x  = element_blank(),
                    axis.ticks.y  = element_blank(),
                    strip.text.x = element_blank(),
                    strip.text.y = element_blank(),
                    plot.background = element_rect(fill = "#f5ffff"),
                    legend.background = element_rect(fill = "#f5ffff"),
                    legend.box.background = element_rect(fill = "#f5ffff", colour = NA),
                    legend.position ="bottom",
                    legend.key = element_rect(colour = NA, fill = NA),
                    panel.background = element_rect(fill= "#f5ffff"))

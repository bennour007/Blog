slicer <- function(x){
  x %>% 
    slice_head(n = 7)
}


arranger <- function(x){
  x %>%
    arrange(- x$total_seats)
}

n <- seq(0, 0.1, by = 0.01)
big_table <- map(n, good_data)

useful_table<- big_table %>% 
  bind_rows() %>% 
  group_by(threshold) %>% 
  nest() %>% 
  mutate(data = map(data, arranger)) %>%
  mutate(data = map(data, slicer))%>%
  unnest()%>%
  ungroup() %>%
  filter(party != 'OUTSIDER 1') %>% 
  mutate(threshold = threshold*100)


table_details <- useful_table %>% 
  mutate(status = if_else(party %in% c('ENNAHDHA', 'QALB TOUNES', 'COALITION KARAMA') == T, 'L', 'W'))


  


p1 <- table_details %>% 
  ggplot(aes(x = threshold,
             y = total_seats,
             color = party,
             label = total_seats)) +
  #geom_line() +
  geom_point() +
  ggbump::geom_bump() +
  ggrepel::geom_text_repel() +
  article_theme +
  scale_x_continuous(breaks = 0:10,
                     labels = scales::label_percent(scale = 1, accuracy = 1)) +
  scale_color_manual(values = c('TAYAR' = 'orange',
                                'COALITION KARAMA' = 'green',
                                'PDL' = 'brown',
                                'HARAKT EL CHAAB' = 'black',
                                'TAHYA TOUNES' = 'pink',
                                'ENNAHDHA' = 'blue',
                                'QALB TOUNES' = 'red')) +
  facet_wrap(status~., 
             ncol = 1, 
             scales = "free_y") +
  theme(legend.title = element_blank()) +
  labs(title = 'The effect of the THRESHOLD',
       subtitle = 'Results of top 7 parties from the 2019 election', 
       caption = 'Le Bennour',
       y = 'Seats #',
       x = 'Threshold %')




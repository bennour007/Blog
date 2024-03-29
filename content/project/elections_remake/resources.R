library(tidyverse)
library(janitor)
library(ggbump)
library(gt)
library(ggrepel)


data <- readxl::read_xlsx('data/general_results_2019.xlsx')
seats <- readxl::read_xlsx('data/seats.xlsx')


zirou <- function(x){
  x %>% 
    replace_na(., 0)
}

# preparing data 

data_clean <- data %>% 
  clean_names() %>% 
  mutate_all(.funs = zirou)

seats <-seats %>% 
  rename('state' = 'Circonscription',
         'n_of_seats' = Sièges)


data_ready <- data_clean %>% 
  pivot_longer(cols = afek_tounes:autres,
               values_to = 'votes',
               names_to = 'party') %>% 
  rename('state'='name_fr') %>% 
  left_join(seats, by = 'state') %>% 
  mutate(party = str_replace_all(party, '_',' '),
         party = str_to_upper(party))


good_data <- function(x){
  
  
  data_numbers <- data_ready %>% 
    group_by(state) %>%
    mutate(total_votes = sum(votes),
           percent = votes/total_votes) %>% 
    filter(percent >= x) %>% 
    filter(party != 'AUTRES') %>% 
    mutate(hare_quota = total_votes/n_of_seats,
           party_quota = votes/hare_quota,
           quota_seats = as.integer(party_quota),
           remains = party_quota - quota_seats, 
           remains_seats = 0) %>% 
    mutate(remaining_seat = n_of_seats - sum(quota_seats)) %>% 
    arrange(desc(remains), .by_group = T) %>% 
    ungroup()
  
  remaining_list <- data_numbers %>% 
    select(state, party, remaining_seat) %>% 
    nest_by(state, remaining_seat) %>% 
    mutate(data = map2(data, remaining_seat, function(x,y) rep(x,3)[1:y])) %>% 
    unnest(data) %>% 
    add_column(remains_seats = 0) %>% 
    mutate(remains_seats = remains_seats+1)
  
  good_data_remains <- remaining_list %>% 
    group_by(data) %>% # cna group by state fro mapping later for an anlysis for a state by state 
    summarize(r_seats = sum(remains_seats)) %>% 
    rename('party' = 'data')
  
  
  good_data_quota <- data_numbers %>% 
    group_by(party) %>%
    summarise(q_seats = sum(quota_seats))
  
  
  good_data_all <- good_data_quota %>% 
    left_join(good_data_remains, by = 'party') %>% 
    mutate(r_seats = zirou(r_seats),
           total_seats = q_seats + r_seats) %>% 
    #filter(total_seats != 0)
    mutate(threshold = x)
  
  return(good_data_all)
}


### MIGRATION DATA FROM CENSUS

library(tidycensus)
library(tidyverse)



years <- c(2015:2019,2021:2022) #2020 does no thave enough data bc of covid


# STATE POPULATION DATA

pop_data <- map_df(years, function(y) {
  get_acs(
    geography = "state",
    variables = c(total_pop = "B01003_001"), #state total pop
    year = y,
    survey = "acs1"
  ) %>%
    mutate(year = y)  
})

pop_clean <- pop_data %>% 
  dplyr::select(-c(GEOID, moe, variable)) %>% 
  rename(state = NAME, 
         total_pop = estimate)

### MIGRATION DATA

migration_vars= c(
  inflow_rented = "B07013_015",
  inflow_owned = "B07013_014",
  outflow_rented = "B07413_015",
  outflow_owned = "B07413_014",
  outflow_income = "B07411_005", #median
  inflow_income = "B07011_005",
  outflow_age = "B07402_005",
  inflow_age = "B07002_005",
  state_inflow= "B07001_065",# num people who moved in from another state (not international)
  state_outflow = "B07401_065",#num people who  left the state for another state
  median_age = "B23013_001",
  median_income = "B21004_001" ,
  median_rent = "B25113_001", #per month
  median_mortgage = "B25088_002" #per mohth
)
  	


migration_data <- map_df(years, function(y) {
  get_acs(
    geography = "state",
    variables = migration_vars,
    year = y,
    survey = "acs1"
  ) %>%
    mutate(year = y)  
})


#### DATA CLEAN UP

income_df <- migration_data %>% 
  dplyr::select(-c(GEOID, moe)) %>% 
  filter(variable %in% c("inflow_income", "outflow_income")) %>% 
  separate(variable, sep = "_", into = c("migration_type", "var")) %>% 
  rename(median_income = estimate, state = NAME) %>% 
  dplyr::select(-var)

age_df <- migration_data %>% 
  dplyr::select(-c(GEOID, moe)) %>% 
  filter(variable %in% c("inflow_age", "outflow_age")) %>% 
  separate(variable, sep = "_", into = c("migration_type", "var")) %>% 
  rename(migration_age = estimate, state = NAME) %>% 
  dplyr::select(-var)

renters_df <- migration_data %>% 
  dplyr::select(-c(GEOID, moe)) %>% 
  filter(variable %in% c("inflow_rented", "outflow_rented")) %>% 
  separate(variable, sep = "_", into = c("migration_type", "var")) %>% 
  rename(migration_renters = estimate, state = NAME) %>% 
  dplyr::select(-var)

owners_df <- migration_data %>% 
  dplyr::select(-c(GEOID, moe)) %>% 
  filter(variable %in% c("inflow_owned", "outflow_owned")) %>% 
  separate(variable, sep = "_", into = c("migration_type", "var")) %>% 
  rename(migration_owners = estimate, state = NAME) %>% 
  dplyr::select(-var)

netmigration_df <- migration_data %>% 
  dplyr::select(-c(GEOID, moe)) %>% 
  filter(variable %in% c( "state_outflow", "state_inflow")) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>% 
  mutate(net_migration = state_inflow - state_outflow) %>%   
  rename(state=NAME) %>% 
  dplyr::select(state, year, net_migration)


state_df <- migration_data %>% 
  dplyr::select(-c(GEOID, moe)) %>% 
  filter(variable %in% c("median_rent", "median_mortgage", "median_income")) %>% 
  pivot_wider(names_from = variable, values_from = estimate) %>% 
  rename(state=NAME) %>% 
  left_join(pop_clean, by=c("state", "year")) %>% 
  left_join(netmigration_df, by=c("state", "year"))
  

migration_df <- migration_data %>% 
  dplyr::select(-c(GEOID, moe)) %>% 
  filter(variable %in% c( "state_outflow", "state_inflow")) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>% 
  mutate(net_migration = state_inflow - state_outflow) %>% 
  pivot_longer(c(state_outflow, state_inflow), names_to = "variable", values_to = "migration_numbers" ) %>% 
  separate(variable, sep = "_", into = c("var", "migration_type")) %>% 
  rename( state = NAME) %>% 
  dplyr::select(-var) %>% 
  left_join(owners_df, by=c("state", "year", "migration_type")) %>% 
  left_join(income_df, by=c("state", "year", "migration_type")) %>% 
  left_join(renters_df, by=c("state", "year", "migration_type")) %>% 
  left_join(age_df, by=c("state", "year", "migration_type")) 
  

write_csv(migration_df, "migration_df.csv")
write_csv(state_df, "state_median_df.csv")
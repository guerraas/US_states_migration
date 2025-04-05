# Migration between U.S. States

exploring migration between US states using census data

*Ana Sofia Guerra, PhD*

The purpose of this repo is to get data to be used in a Tableau dashboard that visualizes migration between U.S. states (2015-2022) and explores income and cost of living data for each states for the time period.

<https://public.tableau.com/views/us_migrations/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link>

In order to source data, run the following script in R: `0_load_census_data.R`, which sources U.S. census data from the `tidycensus` package. Data are cleaned and tidied, then exported into .csv files, which are then used for creating the dashboard in Tableau.

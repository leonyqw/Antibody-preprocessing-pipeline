# process the data and collapse by clones

# setwd("/vast/projects/antibody_sequencing/PC008/use_pipeline")
library(readr)
library(tidyr)
library(dplyr)
library(stringr)

# Input and output file path locations
cols_keep_path <- "/home/users/allstaff/wang.leo/antibody_projects/leon_phd/preprocessing/data/columns_to_keep.csv"
sequences_path <- "/vast/projects/antibody_sequencing/leon_phd/preprocessing/results/riot/best/"
output_path <- "/home/users/allstaff/wang.leo/antibody_projects/leon_phd/preprocessing/results/"

# Get list of column names to keep
columns_to_keep_df <- read_csv(cols_keep_path)

columns_to_keep <- columns_to_keep_df |>
  filter(flag_keep) |>
  select(variable)

# Combine all heavy chain sequence files together, and keep only required variables
H_chains <- read_csv(
  fs::dir_ls(
    path = sequences_path,
    glob = "*_heavy.csv"),
  col_select = any_of(columns_to_keep[[1]]), 
  id = "sample") |>
  distinct(sequence_header, .keep_all = TRUE) |>
  # remove path from sample
  mutate(sample = str_replace_all(basename(sample), "_annot_heavy.csv", ""))

# Combine all light chain sequences files together, and keep only required variables
L_chains <- read_csv(
  fs::dir_ls(
    path = sequences_path,
    glob = "*_light.csv"),
  col_select = any_of(columns_to_keep[[1]]),
  id = "sample") |>
  distinct(sequence_header, .keep_all = TRUE) |>
  # remove path from sample
  mutate(sample = str_replace_all(basename(sample), "_annot_light.csv", ""))

# combine the H and L chains
both_chains <- full_join(H_chains, L_chains, by = "sequence_header", 
                         suffix = c("_H", "_L"), 
                         relationship = "one-to-one") |>
  mutate(sample = sample_H) |>
  select(-c(sample_H, sample_L)) |>
  filter(!is.na(sample)) |> 
  relocate(sample)

## Move to QC report
# # Extract productive H chains
# prod_H <- both_chains |>
#     pull(productive_H) |>
#     table() |>
#     prop.table() |>
#     as_tibble() |>
#     mutate(n = n * 100) |> # prop to percent
#     rename(productivity = ".", percentage_H = "n")
# 
# prod_L <- both_chains |>
#     pull(productive_L) |>
#     table() |>
#     prop.table() |>
#     as_tibble() |>
#     mutate(n = n * 100) |> # prop to percent
#     rename(productivity = ".", percentage_L = "n")
# 
# prod_H |> left_join(prod_L) |> write_csv()

## Move this to QC report
# how many unique clones?
# both_chains |>
#   # collapse into clones
#   filter(productive_H & productive_L) |>
#   filter(cdr3_aa_H != cdr3_aa_L) |>
#   group_by(cdr3_aa_H, cdr3_aa_L, sample) |>
#   summarise(count = n()) |>
#   ungroup() |>
#   group_by(sample) |>
#   summarise(n_clones = n()) |>
#   write_csv()

# create the per sequence clone table of only productive sequences
both_chains |>
# collapse into clones
  filter(productive_H & productive_L) |>
  filter(cdr3_aa_H != cdr3_aa_L) |> # Remove sequences where HCDR3 & LCDR3 are the same
  select(-c(sequence_header, productive_H, productive_L, complete_vdj_H, complete_vdj_L)) |> 
  summarise(
    count = n(),
    .by = any_of(colnames(both_chains))) |>
  group_by(sample) |>
  # mutate(cpm = (count / sum(count)) * 1000000) |>
  # arrange(desc(cpm)) |>
  write_csv(paste0(output_path,"sequence_table.csv"))

## Add to new analysis script for aim 2?
# # table of most common amino acid sequence for each clone 
# both_chains |>
# # collapse into clones
#   filter(productive_H & productive_L) |>
#   filter(cdr3_aa_H != cdr3_aa_L) |>
#   mutate(v_call_L = str_remove(v_call_L, "\\*.*$"),
#            v_call_H = str_remove(v_call_H, "\\*.*$")) |>
#   #filter(nchar(sequence_aa_L) > 75, nchar(sequence_aa_H) > 90) |>
#   summarise(count = n(), 
#             .by = c(cdr3_aa_H, cdr3_aa_L, v_call_H, v_call_L, sequence_aa_L, sequence_aa_H)) |>
#   summarise(
#     sequence_aa_L = sequence_aa_L[which.max(count)],
#     sequence_aa_H = sequence_aa_H[which.max(count)], 
#     .by = c(cdr3_aa_H, cdr3_aa_L, v_call_H, v_call_L)) |>
#   write_csv()
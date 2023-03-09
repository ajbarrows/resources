# Example Rscript
# Tony Barrows
# 20230309

library(dplyr)

reshape_age <- function(fpath) {
  df <- read.csv(fpath)
  
  # create long-format data
  df_long <- df %>%
    tidyr::pivot_longer(
      cols = starts_with("age"),
      names_to = "timepoint",
      values_to = "age"
    )
  
  return (df_long)
}



# main

age_reshaped <- reshape_age("../data/age_wide.csv") # use relative paths
write.csv(age_reshaped, "../out/age_reshaped.csv", row.names = FALSE)
options(repos="https://cloud.r-project.org")
library(dplyr)

write_csv <- function(var) {
  filename <- paste0("lists/", as.character(substitute(var)), ".csv")
  data.frame(package = setdiff(var, nomask)) |>
    mutate(n_revdeps = sapply(tools::package_dependencies(package, reverse=TRUE), length)) |>
    relocate(n_revdeps, .before=1) |>
    left_join(read.csv(filename, na.strings="") |> select(-n_revdeps), by="package") |>
    arrange(desc(n_revdeps)) |>
    write.csv(filename, na="", row.names=FALSE, quote=FALSE)
}

attrs <- system("grep -rE 'Rf_error *\\(' dirs/ | grep RcppExports.cpp | cut -d'/' -f 2 | uniq", intern=TRUE)
other <- system("grep -rE 'Rf_error *\\(' dirs/ | grep -E 'src|inst/include' | grep -v RcppExports.cpp | cut -d'/' -f 2 | uniq", intern=TRUE)
nomask <- system("grep -r RCPP_NO_MASK_RF_ERROR dirs/ | cut -d'/' -f 2 | uniq", intern=TRUE)

write_csv(attrs)
write_csv(other)

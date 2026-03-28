options(repos="https://cloud.r-project.org")
library(dplyr)

write_csv <- function(var) {
  filename <- paste0("lists/", as.character(substitute(var)), ".csv")

  df <- data.frame(package = var) |>
    mutate(n_revdeps = sapply(tools::package_dependencies(package, reverse=TRUE), length)) |>
    relocate(n_revdeps, .before=1)

  if (!file.exists(filename)) df$status <- NA else df <- df |> left_join(
    read.csv(filename, na.strings="") |> select(-n_revdeps), by="package")

  df |>
    arrange(desc(n_revdeps)) |>
    write.csv(filename, na="", row.names=FALSE, quote=FALSE)
}

# monitor uses of Rf_error
attrs <- system("grep -rlE 'Rf_error *\\(' dirs/ | grep RcppExports.cpp | cut -d'/' -f 2 | uniq", intern=TRUE)
other <- system("grep -rlE 'Rf_error *\\(' dirs/ | grep -E 'src|inst/include' | grep -v RcppExports.cpp | cut -d'/' -f 2 | uniq", intern=TRUE)
nomask <- system("grep -r RCPP_NO_MASK_RF_ERROR dirs/ | cut -d'/' -f 2 | uniq", intern=TRUE)
attrs <- setdiff(attrs, nomask)
other <- setdiff(other, nomask)
write_csv(attrs)
write_csv(other)

# monitor uses of forward_exception_to_r, forward_rcpp_exception_to_r
forward1 <- system("grep -rlE 'forward_exception_to_r *\\(' dirs/ | cut -d'/' -f 2 | uniq", intern=TRUE)
forward2 <- system("grep -rlE 'forward_rcpp_exception_to_r *\\(' dirs/ | cut -d'/' -f 2 | uniq", intern=TRUE)
write_csv(forward1)
write_csv(forward2)

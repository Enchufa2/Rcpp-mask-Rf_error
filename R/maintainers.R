path <- commandArgs(TRUE)
if (!length(path) == 1) {
  cat("Usage: Rscript R/maintainers.R <packages.csv>\n")
  quit(status=1)
}

df <- read.csv(path, na.strings="")
pkgs <- df[is.na(df$status), ]$package
if (length(pkgs) == 0) quit(status=0)

maint <- paste0("https://cloud.r-project.org/web/packages/", pkgs, "/DESCRIPTION") |>
  lapply(file) |> sapply(read.dcf, fields="Maintainer")
name <- sapply(strsplit(maint, " <"), "[", 1)

idx <- order(pkgs)
cat(paste(pkgs[idx], name[idx], sep=" - "), sep="\n")
cat("\n")
cat(unique(maint), sep="\n")

df[is.na(df$status), ]$status <- "email"
write.csv(df, path, na="", row.names=FALSE, quote=FALSE)

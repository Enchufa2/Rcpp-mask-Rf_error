options(repos="https://cloud.r-project.org")

deps <- unlist(tools::package_dependencies("Rcpp", reverse=TRUE), use.names=FALSE)
deps <- as.data.frame(available.packages())[deps, c("Package", "Version")]

existing <- sub("\\.tar\\.gz", "", list.files("pkgs")) |>
  strsplit("_") |>  do.call(rbind, args=_)
existing <- if (is.null(existing))
  data.frame(Package=character(0), Existing=character(0)) else
    data.frame(existing) |> `colnames<-`(c("Package", "Existing"))

df <- dplyr::full_join(deps, existing, by="Package") |>
  dplyr::mutate(remove = is.na(Version)) |>
  dplyr::mutate(download = is.na(Existing) | Version > Existing)

if (any(df$remove))
  unlink(Sys.glob(paste0(file.path("pkgs", subset(df, remove)$Package), "*")))
if (any(df$download)) {
  unlink(Sys.glob(paste0(file.path("pkgs", subset(df, download)$Package), "*")))
  download.packages(subset(df, download)$Package, destdir="pkgs")
}

# untar
unlink("dirs", recursive=TRUE, force=TRUE)
for (file in list.files("pkgs", full.names=TRUE))
  untar(file, exdir="dirs")

# author: Yan Liu
# date: 10/2/2021
# purpose: Render covidVignette.Rmd as a .md file called README.md for my repo.

rmarkdown::render(
  input="project1_v2.Rmd",
  output_format = "github_document",
  output_file = "README.md",
  runtime = "static",
  clean = TRUE,
  params = NULL,
  knit_meta = NULL,
  envir = parent.frame(),
  run_pandoc = TRUE,
  quiet = FALSE,
  encoding = "UTF-8"
)

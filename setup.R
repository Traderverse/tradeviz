# Setup script for tradeviz package development
# Run this script to set up your development environment

# Install required packages
required_packages <- c(
        "devtools",
        "roxygen2",
        "testthat",
        "ggplot2",
        "tibble",
        "dplyr",
        "tidyr",
        "rlang",
        "scales",
        "patchwork",
        "plotly",
        "RColorBrewer",
        "viridis",
        "lubridate",
        "grid",
        "gridExtra",
        "ggrepel",
        "zoo",
        "knitr",
        "rmarkdown"
)

cat("Installing required packages...\n")

for (pkg in required_packages) {
        if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
                cat("Installing", pkg, "...\n")
                install.packages(pkg)
        }
}

cat("\n✓ All required packages installed\n")

# Load development tools
library(devtools)
library(roxygen2)

# Document the package
cat("\nGenerating documentation...\n")
document()

# Run tests (if any exist)
if (dir.exists("tests")) {
        cat("\nRunning tests...\n")
        test()
}

# Check package
cat("\nChecking package...\n")
check()

cat("\n✓ tradeviz development environment ready!\n")
cat("\nNext steps:\n")
cat("  1. Load package: devtools::load_all()\n")
cat("  2. Test visualizations: source('examples/basic_plots.R')\n")
cat("  3. Run tests: devtools::test()\n")
cat("  4. Build vignettes: devtools::build_vignettes()\n")
cat("  5. View documentation: ?tradeviz\n")

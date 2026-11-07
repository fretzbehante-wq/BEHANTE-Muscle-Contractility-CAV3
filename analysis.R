
# ==========================================
# MUSCLE CONTRACTILITY LABORATORY ACTIVITY
# Student Assignment No. 45
# Gene: CAV3
# ==========================================

# Step 1. Load required packages

# Install packages only once:
install.packages(c("rentrez", "ggplot2"))

# Load packages
library(rentrez)
library(ggplot2)


# Step 2. Define assigned gene and variant

gene_symbol <- "CAV3"
transcript_accession <- "NM_033337.3"
clinvar_id <- "8283"
variant_protein <- "p.Arg27Gln"


# Step 3. Create project folders

for (x in c("data", "results", "figures")) {
  dir.create(x, showWarnings = FALSE)
}


# Step 4. Display assignment information

cat("Gene:", gene_symbol, "\n")
cat("Transcript:", transcript_accession, "\n")
cat("ClinVar ID:", clinvar_id, "\n")
cat("Protein variant:", variant_protein, "\n")

cat("\nProject setup completed!\n")

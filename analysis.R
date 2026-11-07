
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


# ==========================================
# STEP 2. RETRIEVE HUMAN CAV3 GENE RECORD
# ==========================================

# Search NCBI Gene using the exact gene symbol
# and human taxonomy ID (9606)

hits <- entrez_search(
  db = "gene",
  term = paste0(
    gene_symbol,
    "[Gene Name] AND txid9606[Organism]"
  ),
  retmax = 20
)

# Check whether the gene was found
if (length(hits$ids) == 0) {
  stop("Gene not found in NCBI")
}

# Verify the exact gene symbol
gene_id <- NA_character_

for (id in hits$ids) {
  rec <- entrez_summary(db = "gene", id = id)
  
  if (toupper(rec$name) == toupper(gene_symbol)) {
    gene_id <- id
    gene_info <- rec
    break
  }
}

if (is.na(gene_id)) {
  stop("Exact human gene not found")
}

# Display gene information
print(gene_info)

# Save gene information
writeLines(
  c(
    paste("Gene symbol:", gene_info$name),
    paste("NCBI Gene ID:", gene_id),
    paste("Official name:", gene_info$description),
    paste("Chromosome:", gene_info$chromosome)
  ),
  "results/gene_summary.txt"
)

# Display important information in console
cat("\nCAV3 GENE INFORMATION\n")
cat("Gene ID:", gene_id, "\n")
cat("Official name:", gene_info$description, "\n")
cat("Chromosome:", gene_info$chromosome, "\n")

cat("\nGene information successfully saved!\n")

# ==========================================
# STEP 3. RETRIEVE MATCHING CAV3 PROTEIN
# ==========================================

# Retrieve the exact assigned transcript from NCBI
gb <- entrez_fetch(
  db = "nuccore",
  id = transcript_accession,
  rettype = "gb",
  retmode = "text"
)

# Extract the RefSeq protein accession (NP_)
pat <- '/protein_id="NP_[0-9]+[.][0-9]+"'

fragment <- regmatches(
  gb,
  regexpr(pat, gb)
)

# Check whether protein accession was found
if (length(fragment) == 0 || length(fragment) == 1 &&
    fragment == "") {
  stop("NP protein ID not found; inspect the transcript record")
}

# Clean the extracted accession
protein_accession <- gsub(
  '^/protein_id="|"$',
  '',
  fragment
)

# Retrieve the matching protein FASTA sequence
protein_fasta <- entrez_fetch(
  db = "protein",
  id = protein_accession,
  rettype = "fasta",
  retmode = "text"
)

# Validate FASTA format
if (!startsWith(protein_fasta, ">")) {
  stop("Invalid FASTA sequence")
}

# Save protein sequence in data folder
fasta_file <- file.path(
  "data",
  paste0(gene_symbol, "_protein.fasta")
)

writeLines(protein_fasta, fasta_file)

# Save protein accession information
writeLines(
  paste("NP accession:", protein_accession),
  "results/protein_accession.txt"
)

# Display results
cat("\nMATCHED CAV3 PROTEIN\n")
cat("Transcript:", transcript_accession, "\n")
cat("Protein accession:", protein_accession, "\n")
cat("FASTA successfully saved!\n")

# ==========================================
# STEP 4. PROTEIN LENGTH AND AMINO-ACID
# COMPOSITION ANALYSIS
# ==========================================

# Read the saved protein FASTA file
fasta_lines <- readLines(fasta_file)

# Extract the amino-acid sequence
sequence <- paste(
  fasta_lines[!grepl("^>", fasta_lines)],
  collapse = ""
)

# Convert sequence into individual amino acids
aa <- strsplit(toupper(sequence), "")[[1]]

# Calculate total protein length
protein_length <- length(aa)

# Define the 20 standard amino acids
standard <- strsplit(
  "ACDEFGHIKLMNPQRSTVWY",
  ""
)[[1]]

# Count amino-acid frequencies
counts <- table(
  factor(aa, levels = standard)
)

# Create amino-acid composition table
aa_results <- data.frame(
  AminoAcid = standard,
  Count = as.integer(counts)
)

# Save frequency table as CSV
write.csv(
  aa_results,
  "results/amino_acid_composition.csv",
  row.names = FALSE
)

# Display protein length
cat("\nCAV3 PROTEIN ANALYSIS\n")
cat("Protein accession:", protein_accession, "\n")
cat("Protein length:", protein_length, "amino acids\n")

# Identify the three most abundant amino acids
top_three <- head(
  aa_results[order(-aa_results$Count), ],
  3
)

cat("\nThree most abundant amino acids:\n")
print(top_three)

# Generate amino-acid composition bar chart
fig1 <- ggplot(
  aa_results,
  aes(AminoAcid, Count)
) +
  geom_col(fill = "grey45") +
  theme_bw() +
  labs(
    title = paste(gene_symbol, "amino-acid composition"),
    x = "Amino acid",
    y = "Number of residues"
  )

# Display chart
print(fig1)

# Save chart as PNG
ggsave(
  "figures/01_amino_acid_composition.png",
  fig1,
  width = 8,
  height = 5,
  dpi = 300
)

cat("\nAmino-acid analysis completed successfully!\n")

# ==========================================
# STEP 6. CAV3 VARIANT-POSITION FIGURE
# ==========================================

# Assigned protein variant
variant_protein <- "p.Arg27Gln"

# Extract amino-acid position from the variant
matched <- regmatches(
  variant_protein,
  regexpr("[0-9]+", variant_protein)
)

position <- as.integer(matched)

# Verify the variant position
if (is.na(position) || position < 1 ||
    position > protein_length) {
  stop("Invalid variant position")
}

# Create protein-position plot
fig2 <- ggplot() +
  geom_segment(
    aes(
      x = 1,
      xend = protein_length,
      y = 0,
      yend = 0
    ),
    linewidth = 2
  ) +
  geom_point(
    aes(x = position, y = 0),
    size = 4,
    color = "red"
  ) +
  annotate(
    "text",
    x = position,
    y = 0.25,
    label = variant_protein,
    size = 4
  ) +
  xlim(0, protein_length) +
  ylim(-0.6, 0.6) +
  theme_void() +
  labs(
    title = paste(gene_symbol, "reference protein"),
    x = "Amino-acid position"
  ) +
  theme(
    axis.title.x = element_text()
  )

# Display figure
print(fig2)

# Save figure
ggsave(
  "figures/02_variant_position.png",
  fig2,
  width = 8,
  height = 2.5,
  dpi = 300
)

cat("\nVARIANT POSITION ANALYSIS\n")
cat("Protein length:", protein_length, "amino acids\n")
cat("Variant:", variant_protein, "\n")
cat("Affected amino-acid position:", position, "\n")
cat("\nVariant-position figure successfully saved!\n")

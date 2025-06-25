# Load the tidyverse library
library(tidyverse)

# --- Step 1: Define File Paths ---
r00_file <- "Data/BDCV02-1.R00"
s00_file <- "Data/BDCV02-1.S00"

# --- Step 2: Extract Metadata from the .R00 file (No changes) ---

# Read the first few lines of the R00 file
r00_lines <- readLines(r00_file, n = 6)

# Extract the Sample code from line 2
sample_code <- str_remove(r00_lines[2], "Sample=")

# Extract the Quant value from line 6 and convert it to a number
quant_value <- as.numeric(str_remove(r00_lines[6], "Quant="))

# Let's check the extracted values
print(paste("Sample Code:", sample_code))
print(paste("Quant Value:", quant_value))

# --- Step 3: Read and Process the .S00 file (FINAL, ROBUST VERSION) ---

# Read all lines from the S00 file
s00_lines <- readLines(s00_file)

# Find the starting line index for each table using pattern matching
pyro_start_idx <- grep("\\[Curves pyro\\]", s00_lines)
oxi_start_idx <- grep("\\[Curves oxi\\]", s00_lines)

# Extract the text blocks for each table
pyro_text_block <- s00_lines[(pyro_start_idx + 1):(oxi_start_idx - 1)]
oxi_text_block <- s00_lines[(oxi_start_idx + 1):length(s00_lines)]

# Filter out non-data lines
pyro_data_lines <- pyro_text_block[grepl("^\\s*\\d", pyro_text_block)]
oxi_data_lines  <- oxi_text_block[grepl("^\\s*\\d", oxi_text_block)]

# Parse the text blocks into tibbles, using a tab delimiter,
# and immediately remove columns that are entirely NA.
pyro <- read_delim(
  paste(pyro_data_lines, collapse = "\n"),
  delim = "\t",  # <-- KEY CHANGE 1: Use tab as the delimiter
  col_names = FALSE,
  col_types = cols(.default = "c") # Read as character first to avoid parsing warnings
) %>%
  select(where(~!all(is.na(.)))) %>% # <-- KEY CHANGE 2: Remove all-NA columns
  mutate(across(everything(), as.numeric)) # Convert all columns to numeric

oxi <- read_delim(
  paste(oxi_data_lines, collapse = "\n"),
  delim = "\t",  # <-- KEY CHANGE 1: Use tab as the delimiter
  col_names = FALSE,
  col_types = cols(.default = "c")
) %>%
  select(where(~!all(is.na(.)))) %>% # <-- KEY CHANGE 2: Remove all-NA columns
  mutate(across(everything(), as.numeric)) # Convert all columns to numeric


# --- Step 4: Add Metadata to Tibbles and Finalize ---

# Use mutate() to add the Sample and Quant columns
pyro <- pyro %>%
  mutate(
    Sample = sample_code,
    Quant = quant_value,
    .before = 1
  )

oxi <- oxi %>%
  mutate(
    Sample = sample_code,
    Quant = quant_value,
    .before = 1
  )

' format_segments.R

Formats segment files from COMPASS project into the a TSV containing
columns chr, start, end, lohtype, copy_number, ready for import into
HRDtools.

Usage: format_segments.R -i INPUT -o OUTPUT

Options:
    -i --input INPUT        Path to input segment file from COMPASS.
    -o --output OUTPUT      Path to output segment file for HRDtools.
' -> doc

library(docopt)
args <- docopt(doc)

library(tidyverse)

read_tsv(
    args[['input']],
    col_types = cols(labels = col_character())
)%>%
    write_tsv(args[['output']])

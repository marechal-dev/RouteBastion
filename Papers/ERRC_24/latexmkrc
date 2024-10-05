$custom_latex_opts = ' -synctex=1 -halt-on-error -file-line-error -interaction nonstopmode ';

$pdflatex = 'pdflatex' . $custom_latex_opts . '%O %S';
$lualatex = 'lualatex' . $custom_latex_opts . '%O %S';
$xelatex = 'xelatex' . $custom_latex_opts . '%O %S';

# This means "use lualatex by default"
$pdf_mode = 4;

$postscript_mode = $dvi_mode = 0;

$silent = 1;
$silence_logfile_warnings = 1;

# Make latexmk -c/-C clean *all* generated files
$cleanup_includes_generated = 1;
$cleanup_includes_cusdep_generated = 1;
$bibtex_use = 2;

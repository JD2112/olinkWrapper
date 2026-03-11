---
hide:
  - navigation
  - toc
---

# Introduction

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15098644.svg)](https://doi.org/10.5281/zenodo.15098644)
[![GitHub Invite Collaborators](https://img.shields.io/badge/Invite-Collaborators-blue?style=for-the-badge&logo=github)](https://github.com/JD2112/olinkWrapper/settings/access)
![olinkWrapper](https://img.shields.io/website?url=https%3A%2F%2Folink-wrapper.serve.scilifelab.se%2F&style=for-the-badge)



<div class="grid-container" markdown="1">

<div class="main-content" markdown="1">

**olinkWrapper** provides a user-friendly interface for performing quick analysis of Olink data using the [OlinkAnalyze package](https://github.com/Olink-Proteomics/OlinkRPackage). It allows for data upload, parameter customization, visualization of results, and exporting of analysis outputs in comprehensive PDF/HTML reports.

## olinkWrapper Features

1. **Data Preview:** Data upload, merging, and global preview
2. **Pre-processing:** Normalization, Bridge Selection, LOD handling, Outlier Detection, Manual sample/protein exclusion
3. **Statistical Tests:** Shapiro-Wilk/KS (Normality), t-test, Wilcoxon, ANOVA (with Covariates), Linear Mixed Effects (LME), and Post-hoc modules
4. **Exploratory Analysis:** PCA and UMAP with rich visualization
5. **Visualization:** Boxplot, Distribution plots, LME plots, Pathway Heatmap, QC plot, Heatmap, Volcano plots, and Violin plots.
6. **GSEA Pathway Enrichment and Pathway Heatmaps**
7. **Linear Regression analysis** with NPX values as dependent variable and covariates as independent variables.
8. Comprehensive PDF report generation capturing the entire analytical session

## Usage

### Input files

- **NPX Data file**: A CSV file containing the Olink data.
- **Variables file**: A CSV file containing the variables for the analysis.
- **Key file**: A CSV file containing the key for the analysis.

#### Example NPX Data file

```csv
SampleID,Sample_Type,Index,OlinkID,UniProt,Assay,MissingFreq,Panel,Panel_Lot_Nr,PlateID,QC_Warning,LOD,NPX,Normalization,Assay_Warning,ExploreVersion
1473924355,SAMPLE,1,OID20049,P16860,NPPB,0.156,Cardiometabolic,B23407,WB-3586_PL2_Run239,PASS,-1.7863,-1.797,Intensity,PASS,3.6.1
1472550559,SAMPLE,2,OID20049,P16860,NPPB,0.156,Cardiometabolic,B23407,WB-3586_PL2_Run239,PASS,-1.7863,2.1115,Intensity,PASS,3.6.1
1472532271,SAMPLE,3,OID20049,P16860,NPPB,0.156,Cardiometabolic,B23407,WB-3586_PL2_Run239,PASS,-1.7863,3.1012,Intensity,PASS,3.6.1
2011599093,SAMPLE,4,OID20049,P16860,NPPB,0.156,Cardiometabolic,B23407,WB-3586_PL2_Run239,PASS,-1.7863,1.1946,Intensity,PASS,3.6.1
2011538571,SAMPLE,5,OID20049,P16860,NPPB,0.156,Cardiometabolic,B23407,WB-3586_PL2_Run239,PASS,-1.7863,-1.5487,Intensity,PASS,3.6.1
```

#### Example Variables file

```csv
SUBJID,Treatment,Age,Sex
1,Control,45,Male
2,Treatment,55,Female
3,Control,65,Male
4,Treatment,75,Female
```

#### Example Key file

```csv
SampleID,SUBJID
1473924355,1
1472550559,2
1472532271,3
2011599093,4
2011538571,5
```

???+ tip "Key file"

    Using key file is optional but recommended to use as it reduces the computation time and memory usage. The NPX data file is quiet big and if you have large number of variables, it is recommended to use key file.


???+ note "Demo Data Download"
    Please download the demo data from the following link to practice with the olinkWrapper app: <a href="https://sourceforge.net/projects/olinkwrapper/" target="_blank" rel="noopener">https://sourceforge.net/projects/olinkwrapper/</a>

    **Remember: download all three files.**

### 1. Using Docker

*Requirements: `Docker`* 

```bash
docker run -p 3838:3838 jd21/shinyolink:latest
```

### 2. Using R Locally

*Requirements: `R >= 4.4`, plus system dependencies for the PDF compiler.*

```r
# from the app/ directory
shiny::runApp("app.R")
```

## olinkWrapper Output
- **PDF Report**: 1. A comprehensive PDF report that includes all selected parameters and results. 2. A separate PDF report for all preprocessing and data filtration steps.
- **CSV/Excel files**: Downloadable results for each analysis.
- **PNG/PDF files**: Downloadable plots for each analysis.

For more details about the output files and reports, please refer to the [output documentation](output.md).


## Credits

- **Main Author/Maintainer**: Jyotirmoy Das ([@JD2112](https://github.com/JD2112))

## LICENSE

[GNU General Public License v3.0](LICENSE)

## CITATION

Das, J. (2025). olinkWrappeR (v1.2.1). Zenodo. [https://doi.org/10.5281/zenodo.15098644](https://doi.org/10.5281/zenodo.15098644)

## Acknowledgement

Special thanks to the **Core Facility, Faculty of Medicine and Health Sciences, Linköping University, Linköping, Sweden** and **Clinical Genomics Linköping, Science for Life Laboratory, Sweden** for their support in building this application. We also thank the SciLifeLab Data Center for hosting the application.


## References
1. Olink Proteomics Official Website: https://www.olink.com/
2. Assarsson, E. et al. (2014). "A single-tube, quantitative technique for high-throughput protein analysis." Nature Methods, 11(6), 665–670.
3. OlinkAnalyze R Package: [https://cran.r-project.org/web/packages/OlinkAnalyze/refman/OlinkAnalyze.html](https://cran.r-project.org/web/packages/OlinkAnalyze/refman/OlinkAnalyze.html)
4. OlinkAnalyze Vigenette: [https://cran.r-project.org/web/packages/OlinkAnalyze/vignettes/Vignett.html](https://cran.r-project.org/web/packages/OlinkAnalyze/vignettes/Vignett.html) 


---

## Developer Guide

### Version Bump Automation

To increment the version in the repository across all needed locations (`VERSION`, Dockerfile labels, `version.R`, Rmd templates, and `CITATION.cff`), use the generic script provided in the root:

```bash
./bump_version.sh <version>
# Example: ./bump_version.sh 1.6.0
```

### GitHub Actions Workflow

When the `VERSION` file is updated and pushed to `main`, the `.github/workflows/release.yml` GitHub Action triggers automatically:
- Creates an annotated `vX.x.x` tag mimicking the current `VERSION`
- Uses `mike deploy` to build and deploy MkDocs documentation via GitHub Pages

</div>

<div class="side-panel" markdown="1">

## Run with
[![](https://img.shields.io/badge/Docker-29.2.1-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![](https://img.shields.io/badge/R-4.4.1-276DC3?logo=r&logoColor=white)](https://www.r-project.org)
[![](https://img.shields.io/badge/Shiny-1.13.0-4472c4?logo=shiny&logoColor=white)](https://shiny.posit.co)
[![](https://img.shields.io/badge/MkDocs-1.6.3-42A0FF?logo=mkdocs&logoColor=white)](https://www.mkdocs.org/)
![Website](https://img.shields.io/website?url=https%3A%2F%2Folink-wrapper.serve.scilifelab.se%2F&style=for-the-badge)
[![wakatime](https://wakatime.com/badge/user/fe95275f-909a-4147-a45d-624981173898/project/9c46d7c4-ca59-4065-ade6-f882d7350a5d.svg)](https://wakatime.com/badge/user/fe95275f-909a-4147-a45d-624981173898/project/9c46d7c4-ca59-4065-ade6-f882d7350a5d)

## Stats
<div class="stats-grid">
  <div class="stats-item"><span id="gh-stars" class="stats-value">--</span><span class="stats-label">stars</span></div>
  <div class="stats-item"><span id="gh-issues" class="stats-value">--</span><span class="stats-label">open issues</span></div>
  <div class="stats-item"><span id="gh-last-release" class="stats-value">--</span><span class="stats-label">last release</span></div>
  <div class="stats-item"><span id="gh-last-update" class="stats-value">--</span><span class="stats-label">last update</span></div>
</div>

## Included Tools
<div class="tag-section">
    <a href="https://shiny.posit.co/" target="_blank" rel="noopener noreferrer"><span>Shiny</span></a>
    <a href="https://rstudio.github.io/shinydashboard/" target="_blank" rel="noopener noreferrer"><span>Shinydashboard</span></a>
    <a href="https://rstudio.github.io/DT/" target="_blank" rel="noopener noreferrer"><span>DT</span></a>
    <a href="https://ggplot2.tidyverse.org/" target="_blank" rel="noopener noreferrer"><span>ggplot2</span></a>
    <a href="https://dplyr.tidyverse.org/" target="_blank" rel="noopener noreferrer"><span>dplyr</span></a>
    <a href="https://tidyr.tidyverse.org/" target="_blank" rel="noopener noreferrer"><span>tidyr</span></a>
    <a href="https://readxl.tidyverse.org/" target="_blank" rel="noopener noreferrer"><span>readxl</span></a>
    <a href="https://cran.r-project.org/package=OlinkAnalyze" target="_blank" rel="noopener noreferrer"><span>OlinkAnalyze</span></a>
    <a href="https://cran.r-project.org/package=pheatmap" target="_blank" rel="noopener noreferrer"><span>pheatmap</span></a>
    <a href="https://yihui.org/knitr/" target="_blank" rel="noopener noreferrer"><span>knitr</span></a>
    <a href="https://rmarkdown.rstudio.com/" target="_blank" rel="noopener noreferrer"><span>rmarkdown</span></a>
    <a href="https://ggrepel.slowkow.com/" target="_blank" rel="noopener noreferrer"><span>ggrepel</span></a>
</div>

## Contributors
<div id="gh-contributors" class="contrib-grid">
  <!-- Dynamically populated from GitHub API -->
</div>

## Get Help
- [GitHub Issues](https://github.com/JD2112/olinkWrapper/issues)

## Citation

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15098644.svg)](https://doi.org/10.5281/zenodo.15098644)

</div>

</div>
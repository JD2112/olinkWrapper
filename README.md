# olinkWrappeR

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15098644.svg)](https://doi.org/10.5281/zenodo.15098644)
[![GitHub Invite Collaborators](https://img.shields.io/badge/Invite-Collaborators-blue?style=for-the-badge&logo=github)](https://github.com/JD2112/olinkWrapper/settings/access)
![olinkWrapper](https://img.shields.io/website?url=https%3A%2F%2Folink-wrapper.serve.scilifelab.se%2F&style=for-the-badge)
[![wakatime](https://wakatime.com/badge/user/fe95275f-909a-4147-a45d-624981173898/project/9c46d7c4-ca59-4065-ade6-f882d7350a5d.svg)](https://wakatime.com/badge/user/fe95275f-909a-4147-a45d-624981173898/project/9c46d7c4-ca59-4065-ade6-f882d7350a5d)


**olinkWrapper** provides a user-friendly interface for performing quick analysis of Olink data using the [OlinkAnalyze package](https://github.com/Olink-Proteomics/OlinkRPackage). It allows for data upload, parameter customization, visualization of results, and exporting of analysis outputs in comprehensive PDF/HTML reports.

## Features

1. **Data Preview:** Data upload, merging, and global preview
2. **Pre-processing:** Normalization, Bridge Selection, LOD handling, Outlier Detection, Manual sample/protein exclusion
3. **Statistical Tests:** Shapiro-Wilk/KS (Normality), t-test, Wilcoxon, ANOVA (with Covariates), Linear Mixed Effects (LME), and Post-hoc modules
4. **Exploratory Analysis:** PCA and UMAP with rich visualization
5. **Visualization:** Boxplot, Distribution plots, LME plots, Pathway Heatmap, QC plot, Heatmap, Volcano plots, and Violin plots.
6. **GSEA Pathway Enrichment and Pathway Heatmaps**
7. **Linear Regression analysis** with NPX values as dependent variable and covariates as independent variables.
8. Comprehensive PDF report generation capturing the entire analytical session

---

## Getting Started

### Data Requirements

To run an analysis, you will need:

- **NPX Data (CSV)**  *(required)*: Must contain `SampleID`, `Assay`, and `NPX` columns
- **Variables File (CSV)** *(required)*: Must contain `SUBJID` and any covariates to be modeled
- **Key File (CSV)** *(Optional)*: If your NPX `SampleID` needs to be cross-referenced to `SUBJID`

*Note: Ensure your column headers do not contain spaces, trailing whitespace, or special characters (e.g., Ö, Ä, Å, `;`).*

#### Example NPX data

```bash
SampleID,Sample_Type,Index,OlinkID,UniProt,Assay,MissingFreq,Panel,Panel_Lot_Nr,PlateID,QC_Warning,LOD,NPX,Normalization,Assay_Warning,ExploreVersion
1473924355,SAMPLE,1,OID20049,P16860,NPPB,0.156,Cardiometabolic,B23407,WB-3586_PL2_Run239,PASS,-1.7863,-1.797,Intensity,PASS,3.6.1
1472550559,SAMPLE,2,OID20049,P16860,NPPB,0.156,Cardiometabolic,B23407,WB-3586_PL2_Run239,PASS,-1.7863,2.1115,Intensity,PASS,3.6.1
1472532271,SAMPLE,3,OID20049,P16860,NPPB,0.156,Cardiometabolic,B23407,WB-3586_PL2_Run239,PASS,-1.7863,3.1012,Intensity,PASS,3.6.1
2011599093,SAMPLE,4,OID20049,P16860,NPPB,0.156,Cardiometabolic,B23407,WB-3586_PL2_Run239,PASS,-1.7863,1.1946,Intensity,PASS,3.6.1
2011538571,SAMPLE,5,OID20049,P16860,NPPB,0.156,Cardiometabolic,B23407,WB-3586_PL2_Run239,PASS,-1.7863,-1.5487,Intensity,PASS,3.6.1
```

#### Example Variables file

```bash
SUBJID,Treatment,Age,Sex
1,Control,45,Male
2,Treatment,55,Female
3,Control,65,Male
4,Treatment,75,Female
```

#### Example Key file

```bash
SampleID,SUBJID
1473924355,1
1472550559,2
1472532271,3
2011599093,4
2011538571,5
```
---

## How to Run

### 1. Online Web Server (Recommended)

Try the application directly on the SciLifeLab server:  
[https://olink-wrapper.serve.scilifelab.se/](https://olink-wrapper.serve.scilifelab.se/)

### 2. Using Docker

**olinkWrappeR** is packaged into a production-ready Docker container, including a full TeX Live environment necessary for PDF reporting.

```bash
docker run --rm -p 3838:3838 jd21/shinyolink:latest
```

The app will become available at `http://localhost:3838`.

### 3. Using R Locally

*Requirements: `R >= 4.4`, plus system dependencies for the PDF compiler.*

```r
# from the app/ directory
library(shiny)
shiny::runApp("app.R")
```

## olinkWrapper Output
- **PDF Report**: 1. A comprehensive PDF report that includes all selected parameters and results. 2. A separate PDF report for all preprocessing and data filtration steps.
- **CSV/Excel files**: Downloadable results for each analysis.
- **PNG/PDF files**: Downloadable plots for each analysis.

---

## Documentation

For step-by-step user instructions and parameter configurations, please refer to the [olinkWrappeR manual](https://jd2112.github.io/olinkWrapper/).

## Credits

- **Main Author/Maintainer**: Jyotirmoy Das ([@JD2112](https://github.com/JD2112))

## LICENSE

[GNU General Public License v3.0](LICENSE)

## CITATION

Das, J. (2025). olinkWrappeR (v1.2.1). Zenodo. [https://doi.org/10.5281/zenodo.15098644](https://doi.org/10.5281/zenodo.15098644)

## Acknowledgement

Special thanks to the **Core Facility, Faculty of Medicine and Health Sciences, Linköping University, Linköping, Sweden** and **Clinical Genomics Linköping, Science for Life Laboratory, Sweden** for their support in building this application. We also thank the SciLifeLab Data Center for hosting the application.

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
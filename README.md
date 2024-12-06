# Shiny for WGCNA
(Under active development)


[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14283132.svg)](https://doi.org/10.5281/zenodo.14283132)
[![GitHub Invite Collaborators](https://img.shields.io/badge/Invite-Collaborators-blue?style=for-the-badge&logo=github)](https://github.com/JD2112/ShinyWGCNA/settings/access)

This Shiny app provides a user-friendly interface for performing **Weighted Gene Co-expression Network Analysis (WGCNA)** on **RNA-seq/Microarray** and **DNA methylation** (Array/Sequencing) data. It allows for data upload, parameter customization, visualization of results, and exporting of analysis outputs.

## Input Data
RNA-seq Data: Upload a CSV file with genes as columns and samples as rows. The first column should contain sample names.
DNA Methylation Data: Upload a CSV file with the same structure as the RNA-seq data, containing methylation values.

## How to run locally
```
R # laod R >= 4.3.1
library(shiny)
shiny::runApp("app.R")
```

### Online webserver

[https://jyotirmoydas.shinyapps.io/ShinyOlink/](https://jyotirmoydas.shinyapps.io/ShinyOlink/)

## Highlights

1. Data upload and merging
2. Data preview
3. Descriptive statistics
4. Normality tests for individual proteins
5. PCA plot with customizable options
6. T-Test with downloadable results
7. ANOVA with customizable number of covariates and downloadable results
8. Volcano plot
9. Violin plot for selected proteins

All of these features are now accessible through a modern, responsive interface using the bslib package, with a sidebar for data input and separate tabs for each analysis type.

As you continue to use the app, here are a few suggestions:

1. Thoroughly test the app with different datasets to ensure it handles various data structures and edge cases.
2. Consider adding error handling and informative messages for users if something goes wrong (e.g., if a file is in the wrong format or if an analysis can't be performed due to data characteristics).
3. If you plan to share this app with colleagues, you might want to add some documentation or help text to guide users through the different analyses.
4. Keep an eye on the performance, especially with larger datasets. If you notice any slowdowns, you might need to optimize some of the data processing or consider using reactive expressions for computations that are used in multiple places.

## Credits
- Main Author: 
    - Jyotirmoy Das ([@JD2112](https://github.com/JD2112))

- Collaborators: ()

## Citation

Das, J. (2024). ShinyOlink (v1.1). Zenodo. 

## Acknowledgement

We would like to acknowledge the **Core Facility, Faculty of Medicine and Health Sciences, Linköping University, Linköping, Sweden** and **Clinical Genomics Linköping, Science for Life Laboratory, Sweden** for their support.
---
hide:
  - navigation
---

# Parameters Management

This page explains the parameters available across the different tabs in the Shiny UI. All parameters are configured in the sidebar of their respective module and match the arguments used in the official [OlinkAnalyze](https://cran.r-project.org/web/packages/OlinkAnalyze/vignettes/Vignett.html) package.

## Analysis configuration

### Data Input 
(`ui_data_input.R`)

| Parameter | Type | Description |
|-----------|------|-------------|
| `npx_file` / `npx_file_2` | `file` | Primary and optional secondary NPX data files in CSV format. |
| `var_file` | `file` | Variables file containing sample metadata in CSV format. |
| `key_file` | `file` | Key file (Optional) for matching identifiers. |
| `merge_key` | `string` | Selection for how to match NPX and Variable data together. |

## Processing

## A. Data Preview

### Exclude QC warnings samples

Exclude QC warnings is setup to remove samples that have QC warnings in the NPX dataset. It will retain all `qc_warnings=="Pass"` samples and remove others.

???+ note "qc warnings"
     Check with [Getting started](user_guide.md#exclude-qc-warnings-samples) and [results](results.md#qc-warnings).

### Dataset Explorer

Dataset explorer contains a `search filter` to filter the data based on the variable values. Since its a big matrix, it will take a few seconds to load. Type/paste the search item and wait a few seconds for the table to update.

???+ note "Note"
     More details with [Getting started](user_guide.md#exclude-qc-warnings-samples) and [results](results.md#qc-warnings)

## B. Preprocessing

### 1 Bridge Selector:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `num_bridge_samples` | `numeric` | Target number of samples to select as bridges between plates/panels. | `8` |
| `missing_freq` | `numeric` | Maximum allowed missing data frequency for selected bridge samples. | `0.1` |

### 2 Normalization:

| Parameter | Type | Description |
|-----------|------|-------------|
| `norm_method` | `string` | Method for normalising NPX values across datasets. |
| `ref_sample` | `string` | Reference sample ID used when bridging or normalizing to a specific sample. |

### 3 LOD (Limit of Detection):

*(No configurable parameters required out of the box; execution relies on clicking the integrate LOD button.)*

### 4 Outlier Detection:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `outlier_threshold` | `numeric`| Threshold (in SD) for flagging outlier samples based on UMAP distances. | `2.5` |


## C. Statistical Analysis

### 1. Descriptive Statistics

*(Executes predefined general descriptive summaries without external parameters.)*

### 2. Normality Test

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `normality_protein` | `string` | Select specific target assay / protein or choose all. | |
| `normality_test_type` | `string` | Select `Shapiro-Wilk` or `Kolmogorov-Smirnov` tests. | |

### 3. T-test

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `ttest_var` | `string` | Grouping variable containing exactly 2 levels to compare. | |
| `ttest_var_type` | `string` | Treat the grouping variable as `Factor` or `Character`. | |

### 4. Wilcoxon Test

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `mw_variable` | `string` | Grouping variable containing exactly 2 levels to compare. | |
| `wilcox_var_type` | `string` | Treat the grouping variable as `Factor` or `Character`. | |
| `alternative` | `string` | Alternative hypothesis (`two.sided`, `less`, `greater`). | `two.sided` |

### 5. ANOVA (Analysis of Variance):

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `anova_var` | `string` | Primary grouping variable (factor) to test across multiple groups. | |
| `anova_var_type` | `string` | Type of the primary variable (`Factor` / `Character`). | |
| `anova_num_covariates`| `numeric`| Number of additional covariates to include in the model (0 to 4). | `0` |

### 6. ANOVA Post-hoc:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `posthoc_effect` | `string` | The specific term/effect from the ANOVA results to evaluate. | |
| `posthoc_outcome` | `string` | The outcome measuring variable. | |
| `use_significant_only` | `boolean`| Whether to run post-hoc tests only on assays significant in the main ANOVA. | `true` |
| `posthoc_padjust_method`| `string` | P-value adjustment method for multiple comparisons. | |
| `posthoc_mean_return` | `boolean`| Calculate and return group means in the output. | `false` |
| `posthoc_verbose` | `boolean`| Provide verbose logging during the analysis. | `true` |

### 7. Linear Mixed Effects (LME):

| Parameter | Type | Description |
|-----------|------|-------------|
| `lmer_outcome` | `string` | Outcome variable to predict (Dependent Variable). |
| `lmer_fixed` | `string` | Independent variables used as fixed effects. Supports multiple selections. |
| `lmer_random` | `string` | Grouping variables used as random effects (e.g., subject ID). |

### 8. LME Post-hoc

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `lme_posthoc_variable` | `string` | Fixed effects used in the post-hoc comparison. | |
| `lme_posthoc_random` | `string` | Level of the random effect. | |
| `lme_posthoc_effect` | `string` | The target comparison effect from the LME layout. | |
| `lme_use_significant_only` | `boolean` | Only compare assays that were significant in the LME test. | `true` |
| `lme_posthoc_padjust_method` | `string` | Multi-test correction method. | |

## D. Exploratory Analysis

### 1. PCA Plot (Principal Component Analysis):

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `Color Points By` | `string` | Variable used to color points on the PCA plot. | |
| `Variable Type` | `string` | Type of the color variable (`Character` / `Factor` / `Numeric`). | `Factor` |
| `Show Sample Labels` | `boolean`| Checkbox to display sample ID labels on the PCA plot. | `false` |

### 2. UMAP Plot (Uniform Manifold Approximation and Projection):

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `Color Samples By` | `string` | Variable used to color samples in the UMAP embedding. | |
| `Variable Type` | `string` | Type of the color variable (`Factor` / `Numeric` / `Character`). | `Factor` |
| `Show Sample IDs` | `boolean`| Show or hide sample IDs. | `false` |

## E. Visualization

### 1. Box Plot:

| Parameter | Type | Description |
|-----------|------|-------------|
| `Categorical Group` | `string` | Categorical group (e.g., Treatment) to split the x-axis. |
| `Select Assays (Proteins)` | `string` | Select specific target assay / protein. |
| `Capacity Limit` | `numeric` | Capacity limit for maximum number of boxplots displayed. Max.6; default: 6. |

- Also user can check for **"Overlay ANOVA Post-hoc P-values"** and/or **"Overlay T-test Significance"** to add additional information to the boxplot.

### 2. Distribution Plot:

| Parameter | Type | Description |
|-----------|------|-------------|
| `Color Density By` | `string` | Target variable to color the density plot. |
| `Data Type` | `string` | Type of color variable (`Factor` or `Character`). |

### 3. LME Plot:

| Parameter | Type | Description |
|-----------|------|-------------|
| `Target Assays` | `string` | Select specific target assays / proteins to visualize. |
| `X-axis (Time/Group)` | `string` | Variable defining the X-axis, typically a time point or specific group. |
| `Color Legend` | `string` | Variable used to assign colors to the curves/points. |
| `Fixed Effect Variables` | `string` | Independent variables used as fixed effects in the model (can select multiple). |
| `Random Effect Level (ID)` | `string` | Level corresponding to the Random Effect Level (e.g., Subject ID). |

### 4. Pathway Heatmap:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `Enrichment Method` | `string` | Enrichment scoring method to use (e.g., `GSEA`, `ORA`). | `GSEA` |
| `Keyword Filter`| `string` | Keyword filter to search for specific pathways (e.g., Immune). | |
| `Display Limit (Max Terms)` | `numeric` | Capacity limit for maximum terms displayed on the heatmap. | `20` |

???+ note "Note"
    Use the same `Enrichment Method` that you used in the Pathway Enrichment Analysis.

### 5. QC Plot (Quality Control):

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `Color Grouping` | `string` | Grouping variable used to color the QC plots. | `QC_Warning` |
| `Variable Type` | `string` | Treat the grouping variable as a `Factor` or `Character`. | `Character` |
| `Label Outliers` | `boolean`| Toggle whether outliers are labeled. | `true` |
| `Show Outlier Lines` | `boolean`| Show/hide lines indicating the outlier threshold. | `true` |
| `IQR Def` | `numeric`| Multiple of IQR used to define an outlier. | `3` |
| `Med Def` | `numeric`| Median deviation used to define an outlier. | `3` |
| `Rows` | `numeric`| Number of rows for facet layout. | `1` |
| `Columns` | `numeric`| Number of columns for facet layout. | `1` |

### 6. Heatmap Plot:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `Heatmap Logic` | `string` | Heatmap data logic determining what variables to map. | |
| `Plot Title` | `string` | Text string for the main plot title. | `Heatmap of Samples and Proteins` |
| `Y-axis Label` | `string` | Text string for the Y-axis label. | `Samples` |
| `X-axis Label` | `string` | Text string for the X-axis label. | `Proteins` |

### 7. Volcano Plot:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `Analysis Selection` | `string` | Data source for the volcano plot (e.g., T-test, ANOVA, Wilcoxon Test). | |
| `P-value Method` | `string` | Use raw unadjusted p-values or adjusted p-values (FDR). | `Adjusted_pval` |
| `Threshold (alpha)` | `numeric` | Alpha threshold for significance lines. | `0.05` |
| `Label significant proteins` | `boolean` | Toggle text labels for significant proteins. | `false` |

### 8. Violin Plot:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `Target Assay / Protein` | `string` | Select specific target assay / protein or choose all. | |
| `Primary Categorical Group` | `string` | Primary categorical group to split violin curves. | |
| `Data Class` | `string` | Variable data class (`Factor` or `Character`). | `Factor` |


## F. Pathway Enrichment Analysis

| Parameter | Type | Description |
|-----------|------|-------------|
| `Enrichment Method` | `string` | Enrichment scoring method to use (e.g., `GSEA`, `ORA`). Default: `GSEA` | 
| `Ontology`| `string` | Ontology database to use (e.g., `MSigDb`,`Reactome`,`KEGG`,`GO`). Default: `MSigDb` | 
| `Organism` | `string` | Organism to use for pathway enrichment (e.g., `human`, `mouse`, `rat`). Default: `human` | 
| `P-value Cutoff` | `numeric` | P-value cutoff for pathway enrichment. | 
| `Estimate Cutoff` | `numeric` | Estimate cutoff for pathway enrichment. | 


## G. Linear Regression

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `Outcome Variable` | `string` | Target outcome variable to use for the regression model (e.g. NPX). | |
| `NPX Transformation` | `string` | NPX data transformation method (`Raw NPX` or `Z-score`). | `Raw NPX` |
| `Count (max 5)` | `numeric` | Number of optional covariates to include (max 5). | `0` |

## H. Analysis Report

*Generates comprehensive automated PDF reports of all performed steps without specific parameter inputs.*

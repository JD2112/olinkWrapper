FROM rocker/r-ver:4.3.2

LABEL authors="Jyotirmoy Das" \
      description="Docker image for ShinyOlink"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libmagick++-dev \
    libharfbuzz-dev \
    cmake \
    libfribidi-dev \
    gcc \
    g++ \
    libglpk-dev \
    wget \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set C++ standard to C++14
ENV CXXFLAGS="-std=c++14"

# Install R packages
RUN R -e "install.packages(c('renv', 'shiny', 'BiocManager'))"

# Install Bioconductor
RUN R -e "BiocManager::install(version = '3.18')"

# Manually install problematic packages
RUN R -e "BiocManager::install(c('S4Vectors', 'IRanges', 'XVector', 'GenomeInfoDb', 'Biostrings', 'fgsea', 'org.Hs.eg.db'), update = FALSE, ask = FALSE)"

RUN R -e "install.packages('msigdbdf', repos = 'https://igordot.r-universe.dev')"

# Copy renv.lock file
COPY renv.lock /srv/shiny-server/renv.lock

# Set working directory
WORKDIR /srv/shiny-server

# Restore packages using renv
RUN R -e 'renv::restore()'

# Force install msigdbdf after renv::restore()
RUN R -e "install.packages('msigdbdf', repos = 'https://igordot.r-universe.dev', force = TRUE)"

# Pre-load commonly used packages
RUN R -e "library(shiny); library(msigdbdf); library(clusterProfiler); library(org.Hs.eg.db)"

# Install shiny-server
RUN R -e "install.packages('shiny', repos='https://cloud.r-project.org/')"
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb
RUN apt-get update && apt-get install -y ./shiny-server-1.5.20.1002-amd64.deb
RUN rm shiny-server-1.5.20.1002-amd64.deb

# Copy app files
COPY app/ /srv/shiny-server/

# Expose port 3838 for the Shiny app
EXPOSE 3838

# Run the Shiny app
CMD ["/usr/bin/shiny-server"]
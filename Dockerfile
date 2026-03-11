FROM jd21/shinyolink:latest

LABEL authors="Jyotirmoy Das" \
    version="1.3.0" \
    description="Production Docker image for OlinkWrappeR v1.3.0 with stable system TeX Live for PDF reporting"

# ------------------------------------------------------------------
# SYSTEM DEPENDENCIES (LaTeX + fonts + utilities)
# ------------------------------------------------------------------

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    perl \
    libfontconfig1 \
    fontconfig \
    texlive-xetex \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-pictures \
    texlive-plain-generic \
    lmodern \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# R PACKAGES (analysis + reporting)
# ------------------------------------------------------------------

RUN R -e "install.packages(c( \
    'umap', \
    'pheatmap', \
    'kableExtra', \
    'writexl', \
    'cowplot', \
    'ggrepel', \
    'broom', \
    'purrr', \
    'foreach', \
    'doParallel' \
    ), repos='https://cran.rstudio.com/', Ncpus=parallel::detectCores())"

# ------------------------------------------------------------------
# SHINY APP DEPLOYMENT
# ------------------------------------------------------------------

# Remove previous app version
RUN rm -rf /srv/shiny-server/*

# Copy updated source
COPY app/ /srv/shiny-server/

# Copy VERSION file one level above app root so version.R can find it via ../VERSION
COPY VERSION /srv/VERSION

# Fix ownership and permissions
RUN chown -R shiny:shiny /srv/shiny-server /srv/VERSION && \
    chmod -R 755 /srv/shiny-server && \
    chmod 644 /srv/VERSION

# ------------------------------------------------------------------
# RUNTIME CONFIG
# ------------------------------------------------------------------

EXPOSE 3838

USER shiny

CMD ["/usr/bin/shiny-server"]
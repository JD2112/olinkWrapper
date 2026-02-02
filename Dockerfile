FROM jd21/shinyolink:latest

LABEL authors="Jyotirmoy Das" \
    version="1.5" \
    description="Updated Docker image for OlinkWrappeR v1.5 with LOD, UMAP, and enhanced Volcano Plot integrations"

USER root

# Install missing R packages
RUN R -e "install.packages(c('umap', 'pheatmap'), repos='https://cran.rstudio.com/')"

# Clean existing app directory to ensure only new files are used
RUN rm -rf /srv/shiny-server/*

# Copy updated app files from local app/ directory
COPY app/ /srv/shiny-server/

# Ensure correct permissions
RUN chown -R shiny:shiny /srv/shiny-server && \
    chmod -R 755 /srv/shiny-server

# Expose port 3838
EXPOSE 3838

# Run the Shiny app
USER shiny
CMD ["/usr/bin/shiny-server"]

# Use rocker/shiny:4.4.1 as the base image for Shiny apps
FROM rocker/shiny:4.4.1
LABEL   authors = "Jyotirmoy Das" \
        description = "Docker image for ShinyOlink"

# Install additional system dependencies (if required)
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    git \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libmagick++-dev \
    libharfbuzz-dev \
    cmake \
    libfribidi-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Install any necessary R packages (including 'devtools' or 'renv' if needed)
RUN R -e "install.packages('renv')"

# Install required R packages
# Recreate the R environment using renv package
RUN Rscript -e 'install.packages(c("renv"))'
COPY /renv.lock /srv/shiny-server/renv.lock
RUN Rscript -e 'setwd("/srv/shiny-server/");renv::restore();'

# Set up a working directory and clone the GitHub repository
WORKDIR /srv/shiny-server
RUN rm -rf /srv/shiny-server/
COPY app/ /srv/shiny-server/ 

# Expose port 3838 for the Shiny app
USER shiny
EXPOSE 3838

# Run the Shiny app
CMD ["/usr/bin/shiny-server"]

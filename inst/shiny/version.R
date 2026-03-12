# ==============================================================================
# version.R — App-wide version constant
# ==============================================================================
# This file reads the single VERSION file at the project root and makes
# APP_VERSION available as a global variable to all server modules.
#
# To bump the version, run:   ./bump_version.sh <new_version>
# e.g.                        ./bump_version.sh 1.6.0
# ==============================================================================

# Resolve path: works both locally (app/ as CWD) and in Docker (/srv/shiny-server/)
# Docker layout:  /srv/VERSION          (COPY VERSION /srv/VERSION in Dockerfile)
# Local layout:   ../VERSION            (project root, one level above app/)
version_file <- if (file.exists("/srv/VERSION")) {
    "/srv/VERSION"
} else if (file.exists("../VERSION")) {
    "../VERSION"
} else {
    NULL
}

APP_VERSION <- if (!is.null(version_file)) {
    trimws(readLines(version_file, n = 1, warn = FALSE))
} else {
    "1.3.0" # Fallback if VERSION file is missing
}

message(paste0("[olinkWrappeR] Version: ", APP_VERSION))

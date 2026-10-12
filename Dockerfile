# syntax=docker/dockerfile:1
FROM rocker/tidyverse:4.6.1

USER root
ARG TARGETARCH
ARG BUILD_JOBS=2
ARG DEBIAN_FRONTEND=noninteractive

# The classroom server is Intel/amd64. Never copy macOS executables into it.
RUN test "${TARGETARCH}" = amd64 \
    && test "$(Rscript --vanilla -e 'cat(as.character(getRversion()))')" = 4.6.1 \
    && test -x /init && test -d /etc/cont-init.d \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential gfortran git curl ca-certificates cmake pkg-config \
       libcurl4-openssl-dev libssl-dev libxml2-dev libicu-dev \
       libfontconfig1-dev libfreetype6-dev libharfbuzz-dev libfribidi-dev \
       libpng-dev libjpeg-dev libtiff-dev libwebp-dev libdeflate-dev libgit2-dev libtbb-dev \
       libnlopt-dev zlib1g-dev fonts-lato fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

# Cache package installation independently of changes to teaching materials.
COPY renv.lock /opt/afec/renv.lock
COPY docker/package-plan.R docker/install-packages.R /opt/afec/build/
RUN BUILD_JOBS=${BUILD_JOBS} Rscript --vanilla /opt/afec/build/install-packages.R \
    && rm -rf /opt/afec/build/bootstrap /root/.cache/R/renv /root/.cache/renv

ENV ROOT=FALSE DISABLE_AUTH=FALSE \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    R_LIBS_SITE=/opt/afec/library R_LIBS_USER= \
    R_PROFILE_SITE=/opt/afec/Rprofile.site \
    RENV_CONFIG_AUTOLOADER_ENABLED=FALSE \
    CMDSTAN=/opt/cmdstan/cmdstan-2.38.0 \
    AFEC_STAN_BIN_DIR=/opt/afec/models \
    AFEC_USE_PRECOMPUTED=TRUE AFEC_CLASSROOM=TRUE \
    OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 \
    BLIS_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1 NUMEXPR_NUM_THREADS=1 \
    RCPP_PARALLEL_NUM_THREADS=1 MAKEFLAGS=-j1

COPY docker/Rprofile.site /opt/afec/Rprofile.site
RUN mkdir -p /opt/cmdstan \
    && BUILD_JOBS=${BUILD_JOBS} Rscript -e \
       'cmdstanr::install_cmdstan(version="2.38.0", dir="/opt/cmdstan", cores=as.integer(Sys.getenv("BUILD_JOBS")), cpp_options=list(PRECOMPILED_HEADERS=TRUE, STAN_THREADS=TRUE))' \
    && chmod -R a+rX,go-w /opt/cmdstan

# Only the current course is shipped. The legacy targets pipeline is not run.
COPY .here /opt/afec/template/.here
COPY day1 /opt/afec/template/day1
COPY day2 /opt/afec/template/day2
COPY day3 /opt/afec/template/day3
COPY R/course_data.R R/course_utils.R R/functions.R R/slides_setup.R /opt/afec/template/R/
COPY stan/*.stan /opt/afec/template/stan/
COPY fits /opt/afec/template/fits/
COPY images /opt/afec/template/images/
COPY assets /opt/afec/template/assets/
COPY docker/START-HERE.md /opt/afec/template/START-HERE.md
COPY docker/check-fits.R docker/build-course.R docker/verify.R /opt/afec/bin/
COPY docker/00-afec-guard.sh /etc/cont-init.d/00-afec-guard
COPY docker/03-afec-workspace.sh /etc/cont-init.d/03-afec-workspace
RUN Rscript /opt/afec/bin/build-course.R \
    && chmod 755 /etc/cont-init.d/00-afec-guard /etc/cont-init.d/03-afec-workspace \
    && chmod -R a+rX,go-w /opt/afec \
    && runuser -u rstudio -- Rscript /opt/afec/bin/verify.R /opt/afec/template \
    && rm -rf /opt/afec/build /root/.cache/R/renv /root/.cache/renv

# Inherit Rocker's /init CMD and root startup. RStudio runs student sessions
# as rstudio; Compose will mount only /home/rstudio/workspace and set PASSWORD.
EXPOSE 8787

# Dockerfile for RUMP

FROM rocker/rstudio:3.6.3

LABEL maintainer="xinsongdu@ufl.edu"

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    vim \
    libfreetype6 \
    libcairo2-dev \
    libexpat1-dev \
    libgmp3-dev \
    liblapack-dev \
    libnetcdf-dev \
    libopenbabel-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libgsl0-dev \
    libmpfr-dev \
    pkg-config \
    fftw3-dev \
    libgtk2.0-dev \
    libtiff5-dev \
    libnetcdf-dev \
    libmpfr-dev \
    libnetcdf-dev \
    liblapack-dev \
    cmake \
    default-jdk \
    python\
    python-dev\
    software-properties-common\
    python-pip\
    python3-pip\
    python-tk\
    python3-tk\
    unzip\

    libnetcdf-dev libpng-dev libbz2-dev liblzma-dev libpcre3-dev libicu-dev && \
    rm -rf /var/lib/apt/lists/*

# Install python3-based necessary dependencies for RUMP
RUN pip3 install --upgrade 'pip==20.3.3' 'setuptools==50.3.2'
# hadolint ignore=DL3013
RUN pip3 install 'wheel==0.34.2' 'numpy==1.18.1' 'scipy==1.4.1' 'matplotlib<3.0.0,>=2.1.1' 'plotly==4.5.0' 'seaborn==0.9.1' 'scikit-learn==0.22.1' matplotlib_venn 'multiqc==1.9' 'statsmodels==0.11.0' 'fastcluster==1.1.26' 'pylint==2.4.4' 'pandas==0.25.3' 'xlrd==1.2.0' 'networkx==2.4' 'graphviz==0.16' 'mongoengine==0.16.3' 'beautifulsoup4==4.5.3' 'bottle==0.12.13' 'cchardet==2.1.6' 'python-dateutil==2.6.1' 'pytz==2017.2' 'openpyxl==2.4.1' 'XlsxWriter==0.9.6' 'waitress==1.0.2' 'pymongo==3.7.2'
RUN echo "alias python=python3" >> ~/.bash_profile

ENV NETCDF_INCLUDE=/usr/include

# invalidates cache every 24 hours
ADD http://master.bioconductor.org/todays-date /tmp/

# build dirs for UFRC
RUN mkdir /ufrc /orange /bio /rlts 
RUN mkdir -p /scratch/local
RUN mkdir app

# define work dir
WORKDIR /app
COPY accessibility.properties /app

# Fix a bug for java
# RUN mv accessibility.properties /etc/java-8-openjdk/

# install R packages
COPY r_package_install.R /app
RUN Rscript r_package_install.R

# Install mummichog
# RUN python2.7 -m pip install --upgrade 'setuptools==44.0.0'
# RUN python2.7 -m pip install 'networkx==1.10' 'mummichog1==1.0.10'

# Install MS-DIAL
RUN wget http://prime.psc.riken.jp/compms/msdial/download/repository/Linux/MsdialConsole_v448_linux.zip
RUN unzip MsdialConsole_v448_linux.zip
RUN rm MsdialConsole_v448_linux.zip
RUN mv MsdialConsole_v448_linux msdial
RUN chmod +x msdial/MsdialConsoleApp
RUN cp /app/msdial/* /usr/local/bin/

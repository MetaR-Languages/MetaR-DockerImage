FROM rocker/verse:3.4.3

MAINTAINER Manuele Simi "mas2182@med.cornell.edu"

LABEL org.opencontainers.image.source='https://github.com/MetaR-Languages/MetaR-DockerImage' \
	Description='MetaR DockerImage' \
	Vendor='Clinical and Translational Science Center at Weill Cornell Medicine' \
	maintainer='Manuele Simi <mas2182@med.cornell.edu>' \
	base_image='rocker/verse' \
	base_image_version='3.4.3'

## Refresh package list and upgrade
## Remain current

RUN echo "deb http://ftp.us.debian.org/debian jessie main" >> /etc/apt/sources.list

RUN echo "deb-src http://ftp.us.debian.org/debian jessie main" >> /etc/apt/sources.list
#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

RUN apt-get update

RUN apt-get -y --allow-unauthenticated install python-software-properties

RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff
RUN Rscript -e 'R.Version()'

RUN apt-get -y --allow-unauthenticated install libhdf5-dev

RUN  Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite("edgeR", ask=FALSE);  biocLite("limma", ask=FALSE); ' \
 	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds 

RUN rm -rf /tmp/*.rds \
	&& install2.r --error \
 	checkpoint \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## This is just to set a sane container wide default and is not required
RUN mkdir -p /etc/R \
	&& touch /etc/R/Rprofile.site \
	&& echo 'options(repos = list(CRAN = "http://cran.revolutionanalytics.com/"))' >> /etc/R/Rprofile.site

RUN mkdir -p /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

RUN wget https://cran.r-project.org/src/contrib/hdf5r_1.0.1.tar.gz \
	&& R CMD INSTALL hdf5r_1.0.1.tar.gz

ADD install-Seurat.R /tmp/install-Seurat.R

RUN Rscript --verbose /tmp/install-Seurat.R && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

ADD test.R test.R

ADD install-metaR-packages.R /tmp/install-metaR-packages.R

RUN Rscript --verbose /tmp/install-metaR-packages.R \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

ADD install-metaR-packages-2.R /tmp/install-metaR-packages-2.R

RUN Rscript --verbose /tmp/install-metaR-packages-2.R \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

ADD install-GLimma.R /tmp/install-GLimma.R

RUN Rscript --verbose /tmp/install-GLimma.R


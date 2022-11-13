# Doesn't work above Node 12
FROM node:18@sha256:d09511bdb23ef545d385562689913f2b6ca82fdced95864e6cde709d91e42d26

ENV OPENSSL_CONF=/etc/ssl/

# Use a specific user to do these actions
ARG UID=12000
ARG GID=12001
ARG UNAME=highcharts

#We don't need the standalone Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium

# Install Google Chrome Stable and fonts
# Note: this installs the necessary libs to make the browser work with Puppeteer.
RUN apt-get update && \
	apt-get install -y chromium \
	fonts-ipafont-gothic \
	fonts-wqy-zenhei \
	fonts-thai-tlwg \
	fonts-kacst \
	fonts-freefont-ttf \
	libxss1 \
	wget \
	ca-certificates \
	--no-install-recommends

# Add the user with a static UID and statid GID
RUN groupadd --gid $GID $UNAME && useradd --uid $UID --gid $UNAME $UNAME && \ 
	mkdir /home/highcharts && \
	chown -R $UID:$GID /home/highcharts

# Log in as the newly created user
USER $UNAME

ENV ACCEPT_HIGHCHARTS_LICENSE 1
ENV HIGHCHARTS_USE_STYLED 0
ENV HIGHCHARTS_MOMENT 1
ENV HIGHCHARTS_USE_NPM 1
ENV HIGHCHARTS_VERSION 'latest'

WORKDIR /home/highcharts

RUN git clone https://github.com/highcharts/node-export-server.git . && \
	git checkout enhancement/puppeteer && \
	npm install 

EXPOSE 7801

COPY --chown=$UID:$GUID ./.hcexport ./.hcexport

# Migrate and start webserver
CMD ["npm", "run", "start", "--", "--loadConfig", ".hcexport"]

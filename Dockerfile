FROM node:8.16.0-jessie


EXPOSE 8080


ENV STI_SCRIPTS_PATH=/usr/libexec/s2i \
	NODEJS_VERSION=8 \
	NPM_RUN=start \
	APP_ROOT=/opt/app-root \
	HOME=/opt/app-root/src \
	NPM_CONFIG_PREFIX=$HOME/.npm-global \
	PATH=$APP_ROOT/bin:$HOME/bin:$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
	DEBUG_PORT=5858 \
	NODE_ENV=production \
	DEV_MODE=false


ENV SUMMARY="Data Supply Chain OMS API nodejs $NODEJS_VERSION S2I Build" \
	DESCRIPTION="Data Supply Chain OMS API nodejs $NODEJS_VERSION S2I Build"


LABEL summary="$SUMMARY" \
	description="$DESCRIPTION" \
	io.k8s.description="$DESCRIPTION" \
	io.k8s.display-name="Node.js $NODEJS_VERSION" \
	io.openshift.expose-services="8080:http" \
	io.openshift.tags="builder,$NAME,$NAME$NODEJS_VERSION" \
	io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
	io.s2i.scripts-url="image:///usr/libexec/s2i" \
	com.redhat.dev-mode="DEV_MODE:false" \
	com.redhat.deployments-dir="${APP_ROOT}/src" \
	com.redhat.dev-mode.port="DEBUG_PORT:5858"\
	com.redhat.component="rh-$NAME$NODEJS_VERSION-container" \
	name="gatesma/node8-grpc" \
	version="$NODEJS_VERSION" \
	maintainer="gatesma" \
	help="For more information visit https://github.com/sclorg/s2i-nodejs-container" \
	usage="s2i build <SOURCE-REPOSITORY>gatesma/node-grpc <APP-NAME>"



RUN mkdir /src && \
	mkdir /opt/usr && \
	mkdir -p $APP_ROOT && \
	mkdir -p $HOME && \
	mkdir -p $HOME/.npm-global && \
	mkdir -p $STI_SCRIPTS_PATH && \
	apt-get update && \
	apt-get -y install findutils \
		gettext \
		bash \
		python \
		make \
		gcc \
		clang \
		g++ \
		binutils-gold && \
	apt-get clean


RUN npm --proxy=http://198.161.14.25:8080 install -g nodemon  && \
	npm --proxy=http://198.161.14.25:8080 install --unsafe-perm -g @google-cloud/pubsub


COPY ./s2i/bin/ /usr/libexec/s2i
COPY ./root/ /


RUN adduser -u 1001 -S -G root -h ${HOME} -s /sbin/nologin default && \
	chown -R 1001:0 $APP_ROOT && \
	chown -R 1001:0 $STI_SCRIPTS_PATH && \
	chown -R 1001:0 /opt/usr && \
	chown -R 1001:0 /src


USER 1001


WORKDIR ${HOME}


#CMD $STI_SCRIPTS_PATH/usage


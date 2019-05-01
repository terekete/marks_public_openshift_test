FROM node:8.16.0-alpine


EXPOSE 8080


ENV \
		STI_SCRIPTS_PATH=/usr/libexec/s2i \
		HTTP_PROXY=http://198.161.14.25:8080 \
		HTTPS_PROXY=http://198.161.14.25:8080 \
		GITHUB=https://github.com/telus/marks_opensshift_test \
		NODEJS_VERSION=8.16.0 \
		NPM_RUN=start \
		APP_ROOT=/opt/app-root \
		HOME=/opt/app-root/src \
		# NPM_CONFIG_LOGLEVEL=info \
		NPM_CONFIG_PREFIX=$HOME/.npm-global \
		PATH=$APP_ROOT/bin:$HOME/bin:$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
		DEBUG_PORT=5858 \
		NODE_ENV=production \
		DEV_MODE=false



ENV SUMMARY="DSC OMS API Application - nodejs $NODEJS_VERSION" \
		DESCRIPTION="description"



LABEL summary="$SUMMARY" \
			description="$DESCRIPTION" \
			io.k8s.description="$DESCRIPTION" \
			io.k8s.display-name="Node.js $NODEJS_VERSION" \
			io.openshift.expose-services="8080:http" \
			io.openshift.tags="builder,nodejs,node$NODEJS_VERSION" \
			io.openshift.s2i.scripts-url="image://$STI_SCRIPTS_PATH" \
			io.s2i.scripts-url="image://$STI_SCRIPTS_PATH" \
			com.redhat.dev-mode="DEV_MODE:false" \
			com.redhat.deployments-dir="$HOME" \
			com.redhat.dev-mode.port="DEBUG_PORT:5858" \
			com.redhat.component="alpine-node$NODEJS_VERSION-docker" \
			name="s2i-node-alpine" \
			version="$NODEJS_VERSION" \
			maintainer="Data Supply Chain - UC2 <mark.gates@telus.com>" \
			help="For more information visit: $GITHUB" \
			usage="s2i build <SOURCE-REPOSITORY> s2i-node-alpine:$NODEJS_VERSION <APP-NAME>"



RUN mkdir /src && \
		mkdir /opt/usr && \
		mkdir -p $APP_ROOT && \
		mkdir -p $HOME && \
		mkdir -p $HOME/.npm-global && \
		mkdir -p $STI_SCRIPTS_PATH && \
		apk update && \
		apk add findutils \
				gettext \
				bash \
				python \
				make \
				gcc \
				clang \
				g++ \
				linux-headers \
				binutils-gold \
				libstdc++ && \
		rm -rf /var/cache/apk/* && \
		npm --proxy=$HTTP_PROXY install -g node-gyp && \
		npm --proxy=$HTTP_PROXY install -g grpc && \
		npm --proxy=$HTTP_PROXY install -g nodemon



# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH


# Copy extra files to the image.
COPY ./root/ /


# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=$APP_ROOT/etc/scl_enable \
		ENV=$APP_ROOT/etc/scl_enable \
		PROMPT_COMMAND=". $APP_ROOT/etc/scl_enable"


# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN adduser -u 1001 -S -G root -h ${HOME} -s /sbin/nologin default && \
		chown -R 1001:0 $APP_ROOT && \
		chown -R 1001:0 $STI_SCRIPTS_PATH && \
		chown -R 1001:0 /opt/usr && \
		chown -R 1001:0 /src


# This default user is created in the alpine image
USER 1001


# Directory with the sources is set as the working directory so all STI scripts
# can execute relative to this path.
WORKDIR ${HOME}


# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage


#!/bin/bash

set -e

source vars

package_name="${APP}_docker_ynh"
package_path="./packages/${package_name}"
git_repository_url=${GIT_REPO_URL%/}

# Copy packages template
cp -rf src/ $package_path
cp -f vars $package_path

# Download Dockerfile
if [ -z DOCKERFILE_URL ]; then
	echo "Download Dockerfile..."
	git clone DOCKERFILE_URL ${package_path}/build
	echo "Done"
fi

# Download configuration file for nginx
if [ -z NGINXCONF_URL ]; then
	echo "Download nginx configuration file..."
	git clone NGINXCONF_URL ${package_path}/conf
	echo "Done"
fi

# Copy Dockerfile
if [ -z DOCKERFILE_PATH ]; then
	echo "Download Dockerfile..."
	cp DOCKERFILE_PATH ${package_path}/build
	echo "Done"
fi

# Copy configuration file for nginx
if [ -z NGINXCONF_PATH ]; then
	echo "Download nginx configuration file..."
	cp NGINXCONF_PATH ${package_path}/conf
	echo "Done"
fi

# Generate manifest.json
echo "Generated manifest.json..."
sed -i "s@<APP>@$APP@g" ${package_path}/manifest.json
sed -i "s@<ID>@$ID@g" ${package_path}/manifest.json
sed -i "s@<URL>@$URL@g" ${package_path}/manifest.json
sed -i "s@<LICENCE>@$LICENCE@g" ${package_path}/manifest.json
sed -i "s@<NAME>@$NAME@g" ${package_path}/manifest.json
sed -i "s@<EMAIL>@$EMAIL@g" ${package_path}/manifest.json
sed -i "s@<VERSION>@$VERSION@g" ${package_path}/manifest.json
echo "Done"

# Generate install scripts
echo "Generate install script..."
sed -i "s@<REDIRECTED_PORT>@$REDIRECTED_PORT@g" ${package_path}/scripts/install
sed -i "s@<NOT_REDIRECTED_PORTS>@$NOT_REDIRECTED_PORTS@g" ${package_path}/scripts/install
sed -i "s@<MULTI_USERS>@$MULTI_USERS@g" ${package_path}/scripts/install
sed -i "s@<DOKERHUB_IMAGE>@$DOKERHUB_IMAGE@g" ${package_path}/scripts/install
echo "Done"

# Generate upgrade scripts
echo "Generate upgrade script..."
sed -i "s@<REDIRECTED_PORT>@$REDIRECTED_PORT@g" ${package_path}/scripts/upgrade
sed -i "s@<NOT_REDIRECTED_PORTS>@$NOT_REDIRECTED_PORTS@g" ${package_path}/scripts/upgrade
sed -i "s@<MULTI_USERS>@$MULTI_USERS@g" ${package_path}/scripts/upgrade
sed -i "s@<DOKERHUB_IMAGE>@$DOKERHUB_IMAGE@g" ${package_path}/scripts/upgrade
echo "Done"

# Generate remove scripts
echo "Generate remove script..."
sed -i "s@<NOT_REDIRECTED_PORTS>@$NOT_REDIRECTED_PORTS@g" ${package_path}/scripts/remove
sed -i "s@<DOKERHUB_IMAGE>@$DOKERHUB_IMAGE@g" ${package_path}/scripts/remove
echo "Done"

# Check package with linter
echo ""
echo "Check ${package_name} package with linter:"
./package_linter/package_linter.py ${package_name}

echo "Package generated in ${package_path}"

# Initiat git repository
if [[ $git_repository_url != "" ]]; then

	if [ $REMOTE_ADD ]; then
		git remote add origin ${git_repository_url}/${package_name}
	fi

    git init ${package_path}
	git add ${package_path}/*
	git commit ${package_path} -m "My first commit"
	git push  origin master

fi

echo "End"

exit 0

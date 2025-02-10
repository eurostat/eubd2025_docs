#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e


CHECKPOINT_FILE="/home/eouser/.service_install_status"


# Check where to resume
if [ ! -f "$CHECKPOINT_FILE" ] || [ "$(cat $CHECKPOINT_FILE)" == "" ]; then
    # Install cron and add this script after start
	sudo apt install cron 
	echo "@reboot /home/eouser/add_services_nogpu.sh" >> mycron
	crontab mycron
	rm mycron
	echo "task0" > "$CHECKPOINT_FILE"
    # Update & upgrade packages then reboot
	sudo apt-get update && sudo apt-get -o Dpkg::Options::="--force-confold" upgrade -y
    echo "task1" > "$CHECKPOINT_FILE"
	sudo reboot
elif [ "$(cat $CHECKPOINT_FILE)" == "task1" ]; then
    # Install additional packages
    sudo apt install -y --reinstall linux-headers-$(uname -r)
    sudo apt-get install -y \
      dselect mc xrdp xorgxrdp xterm software-properties-common apt-utils \
      apt-transport-https wget dirmngr gpg gnupg ca-certificates build-essential dkms pkg-config libglvnd-dev
    # sudo apt-get remove -y \
	  # python3-numpy python3-pandas python3-pandas-lib python3-plotly python3-py python3-scipy python3-seaborn python3-sklearn python3-sklearn-lib  
	sudo apt-get install -y \
      postgresql-postgis libpostgis-java \
      r-base libbz2-dev libtbb2-dev gfortran libgfortran-11-dev \
      gdebi-core build-essential libc-devtools libssl-dev libffi-dev libgdal-dev libcrypto++-dev libfontconfig1-dev \
      python3-dev python3-pip python3-venv libsasl2-dev libldap2-dev default-libmysqlclient-dev npm 
    echo "task2" > "$CHECKPOINT_FILE"
    # Add the 'xrdp' user to the 'ssl-cert' group and restart the 'xrdp' service
    sudo adduser xrdp ssl-cert
    sudo service xrdp restart
    echo "task3" > "$CHECKPOINT_FILE"
    # Install Visual Studio Code, RStudio, Shiny, Quarto 
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc > /dev/null
	sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" -y
	sudo apt-get update && sudo apt-get -o Dpkg::Options::="--force-confold" upgrade -y
	sudo apt-get install -y code 
	wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.34/quarto-1.6.34-linux-amd64.deb
	sudo gdebi -n quarto-1.6.34-linux-amd64.deb
	wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2024.09.1-394-amd64.deb
	sudo gdebi -n rstudio-server-2024.09.1-394-amd64.deb
	sudo su - -c "R -e \"install.packages(c('aws.s3','car','devtools','flexdashboard','forecast','lme4','mapview','patchwork','plotly','prophet','quanteda','quarto','renv','restatapi','rpostgis','RJDemetra','shiny','shinydashboard','sparklyr','tidytext','tidyverse','tm','tmap','wk','writexl'), repos='https://cran.rstudio.com/')\""
	wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.22.1017-amd64.deb
	sudo gdebi -n shiny-server-1.5.22.1017-amd64.deb
	sudo su - -c "R CMD javareconf"
	rm -f rstudio-server-2024.09.1-394-amd64.deb
	rm -f shiny-server-1.5.22.1017-amd64.deb
	rm -f quarto-1.6.34-linux-amd64.deb
	rm -f packages.microsoft.gpg
    echo "task4" > "$CHECKPOINT_FILE"
    # Install JupyterHub
	sudo python3 -m venv /opt/jupyterhub/
	sudo chmod 777 /opt/jupyterhub/lib/python3.10/site-packages
	sudo chmod 777 /opt/jupyterhub/bin
	sudo chmod 777 /opt/jupyterhub/include
	if [ ! -d "/opt/jupyterhub/share" ]; then
		sudo mkdir /opt/jupyterhub/share
	fi
	sudo chmod 777 /opt/jupyterhub/share
	if [ ! -d "/opt/jupyterhub/etc" ]; then
		sudo mkdir /opt/jupyterhub/etc
	fi
	sudo chmod 777 /opt/jupyterhub/etc
	/opt/jupyterhub/bin/python3 -m pip install wheel
	/opt/jupyterhub/bin/python3 -m pip install jupyterhub jupyterlab jupyterlab-git jupyterlab-github notebook
	/opt/jupyterhub/bin/python3 -m pip install ipywidgets
	/opt/jupyterhub/bin/python3 -m pip install scikit-learn tensorflow tensorflow_datasets matplotlib pandas gradio seaborn geopandas rasterio sentinelhub xarray ipyleaflet folium mapclassify openeo ddc_utility streamlit leafmap boto3
	sudo npm install -g configurable-http-proxy
	mkdir -p /opt/jupyterhub/etc/systemd

cat << 'EOF' > jupyterhub.service
[Unit]
Description=JupyterHub
After=syslog.target network.target

[Service]
User=root
Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/jupyterhub/bin:/home/eouser/.local/bin"
ExecStart=/opt/jupyterhub/bin/jupyterhub -f /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py

[Install]
WantedBy=multi-user.target
EOF

	sudo mv -f jupyterhub.service /opt/jupyterhub/etc/systemd/jupyterhub.service
	if [ ! -d "/opt/jupyterhub/etc/jupyterhub" ]; then
		sudo mkdir /opt/jupyterhub/etc/jupyterhub
	fi
	cd /opt/jupyterhub/etc/jupyterhub
	sudo /opt/jupyterhub/bin/jupyterhub --generate-config
	echo "c.Spawner.default_url = '/lab'" | sudo tee -a /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py > /dev/null
	echo "c.Authenticator.allow_all = True" | sudo tee -a /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py > /dev/null
	echo "c.ContentsManager.allow_hidden = True" | sudo tee -a /opt/jupyterhub/etc/jupyter/jupyter_server_config.py > /dev/null
	echo "c.ServerApp.iopub_msg_rate_limit=3000.0" | sudo tee -a /opt/jupyterhub/etc/jupyter/jupyter_server_config.py > /dev/null
	echo "c.ServerApp.rate_limit_window=10.0" | sudo tee -a /opt/jupyterhub/etc/jupyter/jupyter_server_config.py > /dev/null
	if [ ! -L "/etc/systemd/system/jupyterhub.service" ]; then
		sudo ln -s /opt/jupyterhub/etc/systemd/jupyterhub.service /etc/systemd/system/jupyterhub.service
	fi
	sudo systemctl daemon-reload
	sudo systemctl enable jupyterhub.service
	sudo systemctl start jupyterhub.service
	
	ipython3 profile create

cat << 'EOF' >> /home/eouser/.ipython/profile_default/ipython_config.py
c.InteractiveShellApp.exec_lines = [
  'import sys; sys.path.append("/usr/local/lib/python3.10/dist-packages"); sys.path.append("./.local/lib/python3.10/site-packages"); sys.path.append("/home/eouser/.local/lib/python3.10/site-packages")'
 ]
EOF

    echo "task5" > "$CHECKPOINT_FILE"
    # Install Superset
	export SUPERSET_DIR=~/superset
	python3 -m venv $SUPERSET_DIR
	$SUPERSET_DIR/bin/python3 -m pip install wheel # install wheel
	$SUPERSET_DIR/bin/python3 -m pip install --upgrade pip setuptools wheel # upgrade pip setuptools wheel
	$SUPERSET_DIR/bin/python3 -m pip install apache-superset pymysql Pillow gunicorn gevent psycopg2-binary # install superset
	export SUPERSET_SECRET_KEY=$(openssl rand -base64 42)
	export PATH=$PATH:$SUPERSET_DIR/bin
	export FLASK_APP=superset
	export SUPERSET_ADMIN_USERNAME='eouser'
	export SUPERSET_ADMIN_FIRST_NAME='Admin'
	export SUPERSET_ADMIN_LAST_NAME='User'
	export SUPERSET_ADMIN_EMAIL='admin@example.com'
	export SUPERSET_ADMIN_PASSWORD='eubdHack25'
	$SUPERSET_DIR/bin/superset db upgrade
	$SUPERSET_DIR/bin/flask fab create-admin \
	  --username $SUPERSET_ADMIN_USERNAME \
	  --firstname $SUPERSET_ADMIN_FIRST_NAME \
	  --lastname $SUPERSET_ADMIN_LAST_NAME \
	  --email $SUPERSET_ADMIN_EMAIL \
	  --password $SUPERSET_ADMIN_PASSWORD
	$SUPERSET_DIR/bin/superset init 
	export CURRENT_USER=$(whoami)
	sudo touch /etc/systemd/system/superset.service
	sudo chown $CURRENT_USER:$CURRENT_USER /etc/systemd/system/superset.service

cat <<EOF | tee /etc/systemd/system/superset.service > /dev/null
[Unit]
Description=Superset daemon
After=network.target
[Service]
PIDFile = $SUPERSET_DIR/superset.PIDFile
User=$CURRENT_USER
Group=$CURRENT_USER
Environment="PATH=$SUPERSET_DIR/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="FLASK_APP=superset"
Environment="SUPERSET_SECRET_KEY=$SUPERSET_SECRET_KEY"
WorkingDirectory=$SUPERSET_DIR
ExecStart=$SUPERSET_DIR/bin/python $SUPERSET_DIR/bin/superset run -p 8088 -h 0.0.0.0 --with-threads --reload --debugger
[Install]
WantedBy=multi-user.target
EOF

	sudo chown root:root /etc/systemd/system/superset.service
	sudo systemctl daemon-reload
	sudo systemctl enable superset.service
	sudo systemctl start superset.service

    echo "all services installed" > "$CHECKPOINT_FILE"

	# Clone the CDSE notebook examples
	cd /home/eouser/jupyter
	if [ ! -d "/home/eouser/jupyter/notebook-samples" ]; then
		git clone https://github.com/eu-cdse/notebook-samples
	fi
	# Clean up
	sudo apt autoremove -y
	echo "" > mycron
	crontab mycron
	rm mycron
    echo "everything went well" > "$CHECKPOINT_FILE"
	sudo reboot
fi
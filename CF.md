# Virtual server in the cloud with access to Earth Observation (EO) data 

In addition to the standard [CDSE services](CDSE.md) the hackathon participants can launch virtual server in the [CREODIAS](https://creodias.eu/) platform provided by CloudFerro. 

For the access to the CREODIAS platform each team will receive one Keystone credential and an SSH key to be used with the pre-configured OS-GEO live server with additional services (Rstudio, JupyterHub, Shiny, Apache Superset).

On the [Horizon Dashboard](https://horizon.cloudferro.com/) the participants have to use the option ***Keystone credentials*** and use the Domain ***cloud_078898*** and region ***WAW3-2***.  

![Horizon dashboard login screen](img/horizon-keystone.png)

After the first login the participants should be able to see the pre-launched server with GPU support. The participants from the Dashboard can terminate the preconfigured server and can launch additional service till the allowed overall limit per team:

 - max 20 instances
 - max 20 CPU cores
 - max 50 GB RAM
 - max 10 disk with a max 1000 GB storage in total
 
 
From the virtual servers you can access the CDSE resources and the additional dataset which are mentioned in the Data Catalogue.
The sample notebooks are accessible under this folder: 
 
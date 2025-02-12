# Virtual server in the cloud with access to Earth Observation (EO) data 

In addition to the standard [CDSE services](CDSE.md) the hackathon participants can launch virtual server in the [CREODIAS](https://creodias.eu/) platform provided by CloudFerro. 

For the access to the CREODIAS platform each team will receive one Keystone credential and an SSH key to be used with the pre-configured OS-GEO live server with additional services (Rstudio, JupyterHub, Shiny, Apache Superset).

On the [Horizon Dashboard](https://horizon.cloudferro.com/) the participants have to use the option ***Keystone credentials*** and use the Domain ***cloud_078898*** and region ***WAW3-2***.  

![Horizon dashboard login screen](img/horizon-keystone.png)

After the first login, the participants should be able to see the pre-launched server with GPU support. The participants from the Dashboard can terminate the preconfigured server and can launch additional service till the allowed overall limit per team, which are:

 - **max 20 instances**
 - **max 20 CPU cores** total in all instances
 - **max 50 GB RAM** total in all instances
 - **max 10 disks** with a **max 1000 GB** storage in total

From the virtual servers you can access the CDSE resources and the additional datasets which are mentioned in the [Data Catalogue](data-catalogue.md).

:::{Note}
The sample notebooks to access the datasets are availble are available in these folders:
 - [https://github.com/eurostat/eubd2025_docs/tree/main/cdse-notebooks](https://github.com/eurostat/eubd2025_docs/tree/main/cdse-notebooks)
 - [https://github.com/eurostat/eubd2025_docs/tree/main/cf-notebooks](https://github.com/eurostat/eubd2025_docs/tree/main/cf-notebooks)
:::
 
## Step by step instructions to recreate the customized image with additional services (JupyterHub,Rstudio,Shiny,Superset)

1. After login in to the [Horizon dashboard](https://horizon.cloudferro.com/) go to the ***Instances*** in the left menu and choose ***Launch Instance***.

![Horizon dashboard instances](img/launch-instance.png)
 
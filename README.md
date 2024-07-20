# H-O-S
## IBM HPC-Tile on Steroids
Offer a highly automated way to add 'add-ons' and example applications on top of an existing IBM HPC Tile.

Actually supported add-ons/example apps:
| Application     | Version  | Description                 |
| :---            | :----:   | :---                        |
| Apptainer       | 1.3.3    | An open-source container platform designed for high-performance computing (HPC) environments, emphasizing security and compatibility. It enables users to create, manage, and run portable, reproducible software containers. (https://apptainer.org)|
| Aspera          | 4.4.2    | A high-speed data transfer technology developed by IBM, designed to move large files and data sets over long distances efficiently. It utilizes a proprietary protocol to overcome traditional bottlenecks of conventional file transfer methods, ensuring faster and more reliable data delivery. (https://www.ibm.com/products/aspera)|
| BLAST           | 2.16.0   | BLAST (Basic Local Alignment Search Tool) is a bioinformatics algorithm used to compare biological sequences, such as DNA, RNA, or proteins, to sequence databases. It helps identify regions of similarity, aiding in the functional and evolutionary analysis of genes and proteins. (https://blast.ncbi.nlm.nih.gov/Blast.cgi)|
| DataManager     | 10.1     | IBM LSF Data Manager is an integrated data management solution that facilitates efficient data movement and storage for workloads in IBM's LSF (Load Sharing Facility) environment. It streamlines data access and transfer, optimizing resource usage and enhancing the performance of high-throughput computing tasks. (https://www.ibm.com/docs/spectrum-lsf/10.1.0?topic=manager-about-spectrum-lsf-data)|
| Intel-HPCKit    | 2024.1.0 | Intel-HPCKit LSF Data Manager is a comprehensive toolkit designed to optimize and manage data workflows in high-performance computing (HPC) environments utilizing IBM's LSF (Load Sharing Facility). It enhances data accessibility and transfer efficiency, thereby improving the overall performance and resource utilization of HPC applications. (https://www.intel.com/content/www/us/en/developer/tools/oneapi/hpc-toolkit.html)|
| iRODS-shell     | 0.0.3    | iRODS (integrated Rule-Oriented Data System) is an open-source data management software that provides a framework for managing, sharing, and preserving large-scale distributed data. It enables organizations to enforce data policies, ensure compliance, and automate workflows across diverse storage systems. (https://irods.org)|
| LS-DYNA         | R13.1.0  | LS-DYNA is a specialized software tool used for simulating complex, dynamic systems and analyzing their behavior under various conditions. It is widely employed in engineering and scientific research to model physical phenomena and predict the performance of structures and materials. (https://www.ansys.com/de-de/products/structures/ansys-ls-dyna)|
| MatlabRuntime   | R2023b   | MATLAB Runtime is a standalone set of shared libraries that enables the execution of compiled MATLAB applications or components without requiring a licensed copy of MATLAB. It allows users to run MATLAB-based programs on computers that do not have MATLAB installed, facilitating wider distribution and deployment of applications. (https://www.mathworks.com/products/compiler/matlab-runtime.html)|
| Nextflow        | 24.04.3  | Nextflow Runtime is a framework for managing and executing computational workflows, designed to streamline the development and execution of complex, data-driven pipelines. It provides a portable and scalable environment that ensures reproducibility and efficiency across various computing infrastructures, including local machines, clusters, and cloud platforms. (https://www.nextflow.io)|
| R               | 4.4.1    | R is a programming language and environment specifically designed for statistical computing and data analysis. It provides a wide range of statistical and graphical techniques, making it a popular choice for data scientists and statisticians to perform data manipulation, visualization, and modeling. (https://www.r-project.org)|
| Sanger-in-a-box | NA       | Collection of applications from the Git repository "cancerit/casm" that hosts the Cancer Analysis Support Matrix (CASM), a toolkit designed to facilitate cancer research through the management and analysis of genomic and clinical data. It provides tools and resources for researchers to streamline their workflows and improve reproducibility in cancer-related studies. (https://github.com/cancerit)|
| Spark           | 3.5.1    | Apache Spark is an open-source, distributed computing system that enables fast and scalable data processing across large clusters. It supports a variety of data processing tasks, including batch and stream processing, machine learning, and graph processing, with a focus on high performance and ease of use. (https://spark.apache.org)|
| Streamflow      | 0.2.0    | Streamflow is a distributed data processing framework designed for managing real-time data streams and event-driven applications. It provides a scalable and fault-tolerant infrastructure for processing and analyzing continuous data flows, often used in scenarios such as monitoring, analytics, and data integration. (https://streamflow.di.unito.it)|
| stress-ng       | 0.17.01  | Stress-ng is a versatile stress testing tool designed to evaluate and benchmark system performance by applying a range of stress tests to various system components. It can test CPU, memory, I/O, and other subsystems to help identify performance bottlenecks and ensure system stability under heavy load conditions. (https://github.com/ColinIanKing/stress-ng)|




STEP 1 : Install IBM Cloud HPC Tile

For a more detailed HowTo, look [here](HPC-Tile.md)

Example values.json:
```
{
"ibmcloud_api_key"                                 : "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
"resource_group"                                   : "XXXXXXX",
"reservation_id"                                   : "XXXXXXXXXXXXXXXXXXXXXXXXX",
"cluster_id"                                       : "XXXXXXXXX",
"bastion_ssh_keys"                                 : "[\"key-arch-ibm-hpc\"]",
"compute_ssh_keys"                                 : "[\"key-arch-ibm-hpc\"]",
"remote_allowed_ips"                               : "[\"11.22.33.44\"]",
"zones"                                            : "[\"eu-de-3\"]"
}
```



https://cloud.ibm.com/docs/allowlist/hpc-service




STEP 2: Login to LSF master as root

```
git clone https://github.com/cwesthues/HOS
cd HOS
./HOS.sh
```



Example (stress-ng):
```
[root@hpcaas0056-mgmt-1-fef0-001 HOS]# ./HOS.sh
Enter shared path (<Enter> for '/shared'):

Select Add-On's
===============
Apptainer Aspera BLAST DataManager Intel-HPCKit iRODS-shell LS-DYNA
MatlabRuntime Nextflow R Sanger-in-a-box Spark Streamflow stress-ng

Select Add-On(s) [Apptainer - stress-ng]: stress-ng

You selected stress-ng
Executing /tmp/stressng_compute.sh on hpcaas0056-mgmt-1-fef0-001

Argument 1 SHARED: /shared

Installing stress-ng
Moving to /shared
[root@hpcaas0056-mgmt-1-fef0-001 HOS]# /root/HowTo_stress-ng.sh
Submitting stress-ng job:
   sudo -i -u lsfadmin bsub -I stress-ng --cpu 8 --io 4 --vm 2 --vm-bytes 128M --fork 4 --timeout 10s

Job <1> is submitted to default queue <interactive>.
<<Waiting for dispatch ...
```

# HOS
HPC-Tile on Steroids



* A bullet
1. List 1
1. List 2

# Main 1
## Main 2
### Main 3




The intention of this GIT repository is to offer a highly automated way to
add 'add-ons' and example applications on top of an existing IBM HPC Tile.

Here is a list of actually supported add-ons/example apps:
| Application     | Version  | Description                 |
| :---            | :----:   | :---                        |
| Apptainer       | 1.3.3    | An open-source container platform designed for high-performance computing (HPC) environments, emphasizing security and compatibility. It enables users to create, manage, and run portable, reproducible software containers.|
| Aspera          | 4.4.2    | A high-speed data transfer technology developed by IBM, designed to move large files and data sets over long distances efficiently. It utilizes a proprietary protocol to overcome traditional bottlenecks of conventional file transfer methods, ensuring faster and more reliable data delivery.|
| BLAST           | 2.16.0   | BLAST (Basic Local Alignment Search Tool) is a bioinformatics algorithm used to compare biological sequences, such as DNA, RNA, or proteins, to sequence databases. It helps identify regions of similarity, aiding in the functional and evolutionary analysis of genes and proteins.|
| DataManager     | 10.1     | IBM LSF Data Manager is an integrated data management solution that facilitates efficient data movement and storage for workloads in IBM's LSF (Load Sharing Facility) environment. It streamlines data access and transfer, optimizing resource usage and enhancing the performance of high-throughput computing tasks.|
| Intel-HPCKit    | 2024.1.0 | Intel-HPCKit LSF Data Manager is a comprehensive toolkit designed to optimize and manage data workflows in high-performance computing (HPC) environments utilizing IBM's LSF (Load Sharing Facility). It enhances data accessibility and transfer efficiency, thereby improving the overall performance and resource utilization of HPC applications.|
| iRODS-shell     | 0.0.3    | iRODS (integrated Rule-Oriented Data System) is an open-source data management software that provides a framework for managing, sharing, and preserving large-scale distributed data. It enables organizations to enforce data policies, ensure compliance, and automate workflows across diverse storage systems.|
| LS-DYNA         | R13.1.0  | LS-DYNA is a specialized software tool used for simulating complex, dynamic systems and analyzing their behavior under various conditions. It is widely employed in engineering and scientific research to model physical phenomena and predict the performance of structures and materials.|
| MatlabRuntime   | R2023b   | MATLAB Runtime is a standalone set of shared libraries that enables the execution of compiled MATLAB applications or components without requiring a licensed copy of MATLAB. It allows users to run MATLAB-based programs on computers that do not have MATLAB installed, facilitating wider distribution and deployment of applications.|
| Nextflow        | 24.04.3  | Nextflow Runtime is a framework for managing and executing computational workflows, designed to streamline the development and execution of complex, data-driven pipelines. It provides a portable and scalable environment that ensures reproducibility and efficiency across various computing infrastructures, including local machines, clusters, and cloud platforms.|
| R               | 4.4.1    | R is a programming language and environment specifically designed for statistical computing and data analysis. It provides a wide range of statistical and graphical techniques, making it a popular choice for data scientists and statisticians to perform data manipulation, visualization, and modeling.|
| Sanger-in-a-box | NA       | Collection of applications from the Git repository "cancerit/casm" that hosts the Cancer Analysis Support Matrix (CASM), a toolkit designed to facilitate cancer research through the management and analysis of genomic and clinical data. It provides tools and resources for researchers to streamline their workflows and improve reproducibility in cancer-related studies.
| Spark           | 3.5.1    | Apache Spark is an open-source, distributed computing system that enables fast and scalable data processing across large clusters. It supports a variety of data processing tasks, including batch and stream processing, machine learning, and graph processing, with a focus on high performance and ease of use.|
| Streamflow      | 0.2.0    | Streamflow is a distributed data processing framework designed for managing real-time data streams and event-driven applications. It provides a scalable and fault-tolerant infrastructure for processing and analyzing continuous data flows, often used in scenarios such as monitoring, analytics, and data integration.|
| stress-ng       | 0.17.01  | Stress-ng is a versatile stress testing tool designed to evaluate and benchmark system performance by applying a range of stress tests to various system components. It can test CPU, memory, I/O, and other subsystems to help identify performance bottlenecks and ensure system stability under heavy load conditions.|




STEP 1 : Install IBM Cloud HPC Tile

STEP 2: Login to LSF master as root

        git clone https://github.com/cwesthues/HOS

        ./HOS.sh

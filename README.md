# HOS
HPC-Tile on Steroids



* A bullet
1. List 1
1. List 2

# Main 1
## Main 2
### Main 3

| Application      | Version |
| :---        |    :----:   |
| Apptainer     | 1.2.3    |
| Aspera   | aaaaa   |




The intention of this GIT repository is to offer a highly automated way to
add 'add-ons' and example applications on top of an existing IBM HPC Tile.

Here is a list of actually supported add-ons/example apps:
| Application     | Version  | Description                 |
| :---            | :----:   | :---                        |
| Apptainer       | 1.3.3    | An open-source container platform designed for high-performance computing (HPC) environments, emphasizing security and compatibility. It enables users to create, manage, and run portable, reproducible software containers.|
| Aspera          | 4.4.2    | A high-speed data transfer technology developed by IBM, designed to move large files and data sets over long distances efficiently. It utilizes a proprietary protocol to overcome traditional bottlenecks of conventional file transfer methods, ensuring faster and more reliable data delivery.|
| BLAST           | 2.16.0   | BLAST (Basic Local Alignment Search Tool) is a bioinformatics algorithm used to compare biological sequences, such as DNA, RNA, or proteins, to sequence databases. It helps identify regions of similarity, aiding in the functional and evolutionary analysis of genes and proteins.|
| DataManager     | 10.1     |
| Intel-HPCKit    | 2024.1.0 |
| iRODS-shell     | 0.0.3    |
| LS-DYNA         | R13.1.0  |
| MatlabRuntime   | R2023b   |
| Nextflow        | 24.04.3  |
| R               | 4.4.1    |
| Sanger-in-a-box | NA       |
| Spark           | 3.5.1    |
| Streamflow      | 0.2.0    |
| stress-ng       | 0.17.01  |




STEP 1 : Install IBM Cloud HPC Tile

STEP 2: Login to LSF master as root

        git clone https://github.com/cwesthues/HOS

        ./HOS.sh

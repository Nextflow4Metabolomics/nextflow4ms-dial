# Nextflow4MS-DIAL

**Nextflow pipeline for reproducible metabolomics data processing with MS-DIAL**.

[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A522.10.0-brightgreen.svg)](https://www.nextflow.io/)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/104f754fa0854cc49e7f84ce73b7c440)](https://app.codacy.com/gh/Nextflow4Metabolomics/nextflow4ms-dial/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)

## Introduction

<!-- TODO nf-core: Write a 1-2 sentence summary of what data the pipeline is for and what it does -->
**nextflow4ms-dial** is a bioinformatics best-practise analysis workflow for Liquid Chromatography-High Resolution Mass Spectrometry (LC-HRMS) metabolomics data processing

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It comes with docker containers making installation trivial and results highly reproducible.

The workflow support MacOS and Linux operating systems. Notably, the workflow has been tested successfully on: 1) A MacOS system (version 13.5.1) including a 2.6 GHz 6-Core Intel Core i7 Processor and 16GB memory; 2) A Linux system installed in a public server named HiPerGator (https://www.rc.ufl.edu/about/hipergator/) whose system version was Red Hat Enterprise 8.8.

## Installation

1. Install Java version 11+ (the author used 11.0.8).

2. Install [`nextflow`](https://nf-co.re/usage/installation)

3. Install [`Docker`](https://docs.docker.com/engine/installation/) or [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/)

## Quick Start

1. Download the pipeline repo and dirct to the folder:
	```bash
	git clone https://github.com/Nextflow4Metabolomics/nextflow4ms-dial.git && cd nextflow4ms-dial
	```

2. Run the pipeline with example data:
    ```bash
    nextflow run main.nf -profile functional_test > logs/execution.log
    ```

## Example data and Results

- Example data: https://drive.google.com/drive/folders/1atsy-TlfJSs0sw2ZCvbkqOSAbZFYRqdy, which is the publicly available data from the publication “Li, Z., Lu, Y., Guo, Y., Cao, H., Wang, Q., & Shui, W. (2018). Comprehensive evaluation of untargeted metabolomics data processing software in feature detection, quantification, and discriminating marker selection. Analytica Chimica Acta, 1029, 50–57”. The data has ten samples in total and five samples in each of the two groups. The protocol regarding processing this data is also publicly available at MetaboLights MTBLS733 (https://www.ebi.ac.uk/metabolights/editor/MTBLS733/protocols).
- Execution command: 
    ```bash
    nextflow run main.nf -profile docker > logs/execution.log
    ```
- Example results are stored in the "results" folder. Note that the file extensions of all produced ".msdial" files have been changed to ".tsv" which enables the files to be opened with Excel software.
- The execution logs for the example data are stored at "logs" folder.

## Process Your Own Data

1. Download the pipeline repo and dirct to the folder:
	```bash
	git clone https://github.com/Nextflow4Metabolomics/nextflow4ms-dial.git && cd nextflow4ms-dial
	```
2. Remove example data, put your raw data files in `.mzML` or `.abf` format in the folder `data/raw_data/`. `.mzML` format files can be converted from other formats using the software (ProteoWizard-msConvert)[https://proteowizard.sourceforge.io/download.html], and `.abf` format files can be obtained via using the software (Reifycs Abf Converter)[https://www.reifycs.com/AbfConverter/].
3. Put config files for MS-DIAL and MS-FLO to the `data/` folder, and name them `msdial_params.txt` and `msflo_params.ini` separately. Example files can be found in `functional_test/sample_data/`.
4. Put MS1 library and MS2 library to the `data/` folder, and name them `ms1_lib.txt` and `ms2_lib.msp`. Example files can be found in `functional_test/sample_data/`.
3. Run the pipeline (use "docker" as the profile when running locally, and "singularity" as the profile when running with a high-performance computing system):
    ```bash
    nextflow run main.nf -profile docker > logs/execution.log
    ```

## Configuration

- Before running for your own data files, make sure the reference file in `conf/base.config` and the MS-DIAL config file are set correctly.
- Configuration for running with Docker are set in the file `conf/base.config`.
- Configuration for running with High-Performance Computing and Singularity are set in the file `conf/HiPerGator.config`.
- Parameters for MS-DIAL and MS-FLO are set in their specific configuration files.

## FAQ

1. Why one of the process was not executed after pipeline execution?
	- To avoid unexpected error, please do not use any special characters in file names (except underscore).

2. I allocated 20 CPUs for running the pipeline using Slurm, why I got an error like `Process requirement exceed available CPUs -- req: 5; avail: 3`
	- Make sure to use `--max_cpus` instead of `--cpus` in the config file to define the allocated CPUs for each process.

## Credits

Dr. Dominick Lemas (Dr. Xinsong Du's Ph.D. advisor) and Xinsong Du play an important role on conceptulization.
The `nextflow4ms-dial` was mainly developed by Xinsong Du. 

## Semantic Annotations

- Input: mzML [EDAM:format_3244]
- Output: CSV [EDAM:format_3752]
- Operation: peak detection [EDAM:operation_3215]; chromatogram alignment [EDAM:operation_3628]; metabolite identification [EDAM:operation_3803]

## Log File Interpretation

- `execution_report.html` has information regarding run time and the use of computational resources for the workflow execution.
- `execution_timeline.html` has information about the execution timeline of each process.
- `logs/execution.log` is an example log file for a successful execution. The log file includes metadata of the execution such as the versions of the dependency (Nextflow) and the workflow, parameter information such as resource allocation and the software container, the workflow execution progress, and the execution log for each process.
- `error.txt` is an example error log for a failed execution.

## Journal Publication

Please cite the following journal publication if you use Nextflow4MS-DIAL for scientific projects:

- Du X, Dobrowolski A, Brochhausen M, Garrett TJ, Hogan WR, Lemas DJ. Nextflow4MS-DIAL: A Reproducible Nextflow-Based Workflow for Liquid Chromatography-Mass Spectrometry Metabolomics Data Processing. J Am Soc Mass Spectrom. Published online January 5, 2025. doi:10.1021/jasms.4c00364

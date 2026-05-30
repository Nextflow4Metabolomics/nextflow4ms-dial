#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/**
    A Nextflow-based reproducible pipeline for untargeted metabolomics data analysis
    Description  : RUMP: A Nextflow-based reproducible pipeline for untargeted metabolomics data processing
    Author       : Xinsong Du
    Creation Date: 11/01/2022
    License      : MIT License
          
    This script is free software: you can redistribute it and/or modify
    it under the terms of the MIT License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This script is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    MIT License for more details.
    
    You should have received a copy of the MIT License
    along with this script. If not, see <https://opensource.org/licenses/MIT>.
    
    For any bugs or problems found, please contact us at
    - xinsongdu@ufl.edu (or xinsongdu@gmail.com), djlemas@ufl.edu
    - https://github.com/Nextflow4Metabolomics/nextflow4ms-dial
*/

/**
    Process description: Process for running MS-DIAL with negative mode batchfile and data to generate peak table of negative mode.
    Inputs: MS-DIAL config file; raw .mzML data; MS1 library; MS2 library; reference file.
    Outputs: The peak table produced by MS-DIAL after processing all raw data.
*/
process peak_detection_msdial {

    debug true

    publishDir './results/'

    input:
    path msdial_config // Config file for MS-DIAL to process negative data.
    path data // Location of data files
    path ms1_lib // Location of MS1 library file for negative samples
    path ms2_lib // Location of MS2 library file for negative samples
    path ref


    output:
    path "ms-dial/AlignResult*.msdial", emit: msdial_result // MS-DIAL processing result for the data.
    stdout emit: msdial_result_log

    shell:
    """
    echo "peak detection via MS-DIAL software" &&
    mkdir "ms-dial" && mv ${msdial_config} "ms-dial" && mv ${ms1_lib} "ms-dial" && mv ${ms2_lib} "ms-dial" && mv ${ref} "ms-dial" && mv ${data} "ms-dial" && cd "ms-dial" && MsdialConsoleApp lcmsdda -i ${data} -o ./ -m ${msdial_config}
    """
}

/** 
    Process description: MS-FLO download.
    inputs: N/A.
    outputs: The MS-FLO repo.
*/
process msflo_download{
    
    publishDir './'

    output:
    path "ms-flo", emit: msflo_software

    shell:
    """
    wget https://bitbucket.org/fiehnlab/ms-flo/get/67b15bfe341c.zip && unzip 67b15bfe341c.zip && rm 67b15bfe341c.zip && mv fiehnlab-ms-flo-67b15bfe341c ms-flo
    """

}

/** 
    Process description: Post-processing with MS-FLO.
    inputs: The MS-FLO folder; the MS-FLO config file; the MS-DIAL processed peak table.
    outputs: The MS-FLO processed peak table.
*/
process msflo_processing{
    
    debug true

    publishDir './results/'
    
    input:
    path msflo // Load MS-FLO software from the channel.
    path msflo_config // Config file for MS-FLO to process negative data.
    path msdial_result // Fetch aligned result from MS-DIAL

    output:
    path "ms-flo/AlignResult*_processed.msdial", emit: msflo_result
    stdout emit: msflo_result_log

    shell:
    """
    echo "peak detection optimization via MS-FLO software" &&
    mv ${msflo_config} ${msflo} && mv ${msdial_result} ${msflo} && cd ${msflo} &&
    python3 run_msflo.py -f msdial ${msflo_config} ${msdial_result}
    """

}

workflow {
    def version = '1.0dev'
    def timestamp = '20221009'

    // Basic running information
    println "Project : $workflow.projectDir"
    println "Git info: $workflow.repository - $workflow.revision [$workflow.commitId]"
    println "Cmd line: $workflow.commandLine"
    println "Manifest's pipeline version: $workflow.manifest.version"

    // Prints help when asked for
    if (params.help) {
        System.out.println("")
        System.out.println("A Nextflow-based reproducible pipeline for untargeted metabolomics data analysis - Version: $version ($timestamp)")
        System.out.println("This pipeline is distributed in the hope that it will be useful")
        System.out.println("but WITHOUT ANY WARRANTY. See the MIT License for more details.")
        System.out.println("")
        System.out.println("Please report comments and bugs to the issue tracking on GitHub")
        System.out.println("at https://github.com/Nextflow4Metabolomics/nextflow4ms-dial/issues.")
        System.out.println("Check https://github.com/Nextflow4Metabolomics/nextflow4ms-dial for updates, and refer to")
        System.out.println("https://github.com/Nextflow4Metabolomics/nextflow4ms-dial/wiki")
        System.out.println("")
        System.out.println("Usage:  ")
        System.out.println("   nextflow run main.nf -profile [options: functional_test; docker; singularity]")
        System.out.println("")
        System.out.println("Arguments (it is mandatory to change `input_file` and `mzmine_dir` before running:")
        System.out.println("----------------------------- common parameters ----------------------------------")
        System.out.println("    -profile                                docker (run pipeline locally), singularity (run pipeline on supercomputer), or test (run test data locally with docker)")
        System.out.println("    --help                                  whether to show help information or not, default is null")
        System.out.println("Please refer to nextflow.config for more options.")
        System.out.println("")
        System.out.println("The workflow supports .mzML format files.")
        System.out.println("The workflow supports MacOS and Linux operating systems.")
        System.out.println("")
        exit 1
    }

    def custom_runName = params.name
    if (!(workflow.runName ==~ /[a-z]+_[a-z]+/)) {
        custom_runName = workflow.runName
    }

    // Header log info
    def summary = [:]
    summary['Pipeline Name']  = 'RUMP'
    if (workflow.revision) summary['Pipeline Release'] = workflow.revision
    summary['Run Name']         = custom_runName ?: workflow.runName
    summary['Input']            = params.input
    summary['Max Resources']    = "$params.max_memory memory, $params.max_cpus cpus, $params.max_time time per job"
    if (workflow.containerEngine) summary['Container'] = "$workflow.containerEngine - $workflow.container"
    summary['Output dir']       = params.outdir
    summary['Launch dir']       = workflow.launchDir
    summary['Working dir']      = workflow.workDir
    summary['Script dir']       = workflow.projectDir
    summary['User']             = workflow.userName
    if (workflow.profile.contains('awsbatch')) {
        summary['AWS Region']   = params.awsregion
        summary['AWS Queue']    = params.awsqueue
        summary['AWS CLI']      = params.awscli
    }
    summary['Config Profile'] = workflow.profile
    if (params.config_profile_description) summary['Config Profile Description'] = params.config_profile_description
    if (params.config_profile_contact)     summary['Config Profile Contact']     = params.config_profile_contact
    if (params.config_profile_url)         summary['Config Profile URL']         = params.config_profile_url
    summary['Config Files'] = workflow.configFiles.join(', ')
    if (params.email || params.email_on_fail) {
        summary['E-mail Address']    = params.email
        summary['E-mail on failure'] = params.email_on_fail
    }
    log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
    log.info "-\033[2m--------------------------------------------------\033[0m-"

    peak_detection_msdial(
        Channel.fromPath(params.msdial_config),
        Channel.fromPath(params.input_dir, type: 'dir'),
        Channel.fromPath(params.ms1_library),
        Channel.fromPath(params.ms2_library),
        Channel.fromPath(params.ref)
    )

    msflo_download()

    msflo_processing(
        msflo_download.out.msflo_software,
        Channel.fromPath(params.msflo_config),
        peak_detection_msdial.out.msdial_result
    )
}

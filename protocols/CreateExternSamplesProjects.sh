set -o pipefail
#MOLGENIS walltime=02:00:00 mem=4gb

#list seqType
#string projectRawArraytmpDataDir
#string projectRawtmpDataDir
#string projectJobsDir
#string projectLogsDir
#string intermediateDir
#string projectResultsDir
#string projectQcDir
#string groupname
#string ngsUtilsVersion
#string ngsVersion
#list sequencingStartDate
#list sequencer
#list run
#list flowcell
#string parameters_build
#string parameters_environment
#string parameters_chromosomes
#string worksheet
#string outputdir
#string workflowpath
#list externalSampleID
#string project
#string logsDir
#list barcode
#list lane

#list externalFastQ_1
#list externalFastQ_2

module load "${ngsUtilsVersion}"
module list

#
# Create project dirs.
#
mkdir -p "${projectRawArraytmpDataDir}"
mkdir -p "${projectRawtmpDataDir}"
mkdir -p "${projectJobsDir}"
mkdir -p "${logsDir}/${project}/"
mkdir -p "${projectLogsDir}"
mkdir -p "${intermediateDir}"
mkdir -p "${projectResultsDir}"
mkdir -p "${projectQcDir}"

ROCKETPOINT="${PWD}"

cd "${projectRawtmpDataDir}" || exit

#
# Create symlinks to the raw data required to analyse this project
#
# For each sequence file (could be multiple per sample):
#


max_index="${#externalSampleID[@]}"-1
for ((samplenumber = 0; samplenumber <= max_index; samplenumber++))
do
	if [[ "${seqType[samplenumber]}" == "SR" ]]
	then
		if [[ "${barcode[samplenumber]}" == "None" ]]
		then
			ln -sf "${externalFastQ_1[samplenumber]}" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz"
			ln -sf "${externalFastQ_1[samplenumber]}.md5" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz.md5"
		else
			ln -sf "${externalFastQ_1[samplenumber]}" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz"
			ln -sf "${externalFastQ_1[samplenumber]}.md5" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz.md5"
		fi
	elif [[ "${seqType[samplenumber]}" == "PE" ]]
	then
		if [[ "${barcode[samplenumber]}" == "None" ]]
		then
			ln -sf "${externalFastQ_1[samplenumber]}" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz"
			ln -sf "${externalFastQ_2[samplenumber]}" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz"
			ln -sf "${externalFastQ_1[samplenumber]}.md5" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz.md5"
			ln -sf "${externalFastQ_2[samplenumber]}.md5" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz.md5"
		else
			ln -sf "${externalFastQ_1[samplenumber]}" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz"
			ln -sf "${externalFastQ_2[samplenumber]}" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz"
			ln -sf "${externalFastQ_1[samplenumber]}.md5" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz.md5"
			ln -sf "${externalFastQ_2[samplenumber]}.md5" "${projectRawtmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz.md5"
		fi
	fi
done

cd "${ROCKETPOINT}" || exit

module load "${ngsVersion}"

cp "${worksheet}" "${projectJobsDir}/${project}.csv"

#
# Execute MOLGENIS/compute to create job scripts to analyse this project.
#


if [[ -f .compute.properties ]];
then
	rm ../.compute.properties
fi

echo "before run second rocket"
echo pwd

sh "${EBROOTMOLGENISMINCOMPUTE}"/molgenis_compute.sh \
-p "${parameters_build}" \
-p "${parameters_environment}" \
-p "${parameters_chromosomes}" \
--header "${EBROOTNGS_RNA}/templates/slurm/header.ftl" \
--footer "${EBROOTNGS_RNA}/templates/slurm/footer.ftl" \
--submit "${EBROOTNGS_RNA}/templates/slurm/submit.ftl" \
-p "${projectJobsDir}/${project}.csv" -rundir "${projectJobsDir}" \
-w "${workflowpath}" -b slurm -g -weave -runid "${runid}" \
-o "ngsVersion=${ngsVersion};groupname=${groupname};"

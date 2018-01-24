#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=03:00:00

#Parameter mapping

#string projectResultsDir
#string project
#string intermediateDir
#string projectLogsDir
#string projectQcDir
#string scriptDir
#list externalSampleID
#string contact
#string qcMatricsList
#string gcPlotList
#string seqType
#string RVersion
#string wkhtmltopdfVersion
#string fastqcVersion
#string samtoolsVersion
#string picardVersion
#string multiqcVersion
#string anacondaVersion
#string hisatVersion
#string indexFileID
#string ensembleReleaseVersion
#string logsDir
#string ngsversion
#string groupname
#string tmpName

#string jdkVersion
#string RVersion
#string htseqVersion
#string pythonVersion
#string gatkVersion
#string ghostscriptVersion
#string kallistoVersion
#string ensembleReleaseVersion


#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

SAMPLES=()

for external in "${externalSampleID[@]}"
do
        array_contains SAMPLES "$external" || SAMPLES+=("$external")    # If vcfFile does not exist in array add it
done



#genarate qcMatricsList
rm -f ${qcMatricsList}
rm -f ${gcPlotList}

 
for sample in "${SAMPLES[@]}" 
do
        echo -e "$intermediateDir/${sample}.total.qc.metrics.table" >> ${qcMatricsList}
done

#genarate gcPlotList
 
for sample in "${SAMPLES[@]}"
do
        echo -e "$intermediateDir/${sample}.GC.png" >> ${gcPlotList}
done


cat > ${intermediateDir}/${project}_QCReport.rhtml <<'_EOF'
<html>
<head>
  <title>${project} QCReport</title>
</head>
<style type="text/css">
      div.page {
	page-break-after: always;
      	padding-top: 60px;
	padding-left: 40px;
      }
</style>
<body style="font-family: monospace;">

<div class="page" style="text-align:center;">
<font STYLE="font-size: 45pt;">
<br>
<br>
<br>
<br>
<br>
<br>
  <b>Next Generation Sequencing report</b>
</font>
<font STYLE="font-size: 30pt;">
<br>
<br>
<br>
<br>
  Genome Analysis Facility (GAF), Genomics Coordination Centre (GCC)
<br>
<br>

  University Medical Centre Groningen
<script language="javascript">
	var month=new Array(12);
	month[0]="January";
	month[1]="February";
	month[2]="March";
	month[3]="April";
	month[4]="May";
	month[5]="June";
	month[6]="July";
	month[7]="August";
	month[8]="September";
	month[9]="October";
	month[10]="November";
	month[11]="December";
	var currentTime = new Date()
	var month =month[currentTime.getMonth()]
	var day = currentTime.getDate()
	var year = currentTime.getFullYear()
  document.write(month + " " + day + ", " + year)
</script>

<div style="text-align:left;">
<br>
<br>
<br>
<br>
<table align=center STYLE="font-size: 30pt;">
	<tr>
		<td><b>Report</b></td>
	</tr>
	<tr>	
		<td>Created on</td>
		<td>
<script language="javascript">
        var month=new Array(12);
        month[0]="January";
        month[1]="February";
        month[2]="March";
        month[3]="April";
        month[4]="May";
        month[5]="June";
        month[6]="July";
        month[7]="August";
        month[8]="September";
        month[9]="October";
        month[10]="November";
        month[11]="December";
        var currentTime = new Date()
        var month =month[currentTime.getMonth()]
        var day = currentTime.getDate()
        var year = currentTime.getFullYear()
  document.write(month + " " + day + ", " + year)
</script>
		</td>
	</tr>
	<tr>	
		<td>Generated by</td><td>MOLGENIS Compute</td>
	</tr>
	<tr></tr><td></td>
	<tr>
		<td><b>Project</b></td>
	</tr>
	<tr>
		<td>Project name</td><td>${project}</td>
	</tr>
	<tr>
		<td>Number of samples</td>
	</tr>
	<tr></tr><td></td>
	<tr>
		<td><b>Contact</b></td>
	</tr>
	<tr>
		<td>Name</td><td>${contact}</td>
	</tr>
	<tr>
		<td>E-mail</td><td>${contact}</td>
	</tr>
	<tr>
            	<td>Pipeline version</td><td>${ngsversion}</td>
        </tr>
</table>
</div>
</div>
</p>

<div class="page">
<p>
<h1>Introduction</h1>
<br>
<br>
<pre>
This report describes a series of statistics about your sequencing data. Together with this 
report you'll receive fastq files, qc metrics files and geneCount tables. If you, in addition, also want 
the alignment data, then please notify us via e-mail. In any case we'll delete the raw data, 
three months after</pre> <script language="javascript">
        var month=new Array(12);
        month[0]="January";
        month[1]="February";
        month[2]="March";
        month[3]="April";
        month[4]="May";
        month[5]="June";
        month[6]="July";
        month[7]="August";
        month[8]="September";
        month[9]="October";
        month[10]="November";
        month[11]="December";
        var currentTime = new Date()
        var month =month[currentTime.getMonth()]
        var day = currentTime.getDate()
        var year = currentTime.getFullYear()
  document.write(month + " " + day + ", " + year)
</script>
<pre>
Description of the RNA Isolation, Sample Preparation and sequencing and different steps used in the RNA analysis pipeline

Gene expression quantification
The trimmed fastQ files where aligned to build ${indexFileID} ensembleRelease ${ensembleReleaseVersion} reference genome using 
${hisatVersion} [1] allowing for 2 mismatches. Before gene quantification
${samtoolsVersion} [2] was used to sort the aligned reads.
The gene level quantification was performed by ${htseqVersion} [3] using --mode=union
--stranded=no and, Ensembl version ${ensembleReleaseVersion} was used as gene annotation database which is included
 in folder expression/.

Calculate QC metrics on raw and aligned data
Quality control (QC) metrics are calculated for the raw sequencing data. This is done using
the tool FastQC ${fastqcVersion} [4]. QC metrics are calculated for the aligned reads using
Picard-tools ${picardVersion} [5] CollectRnaSeqMetrics, MarkDuplicates, CollectInsertSize-
Metrics and ${samtoolsVersion} flagstat.

These QC metrics form the basis in this  final QC report. 

Used toolversions:

${jdkVersion}
${fastqcVersion}
${hisatVersion}
${samtoolsVersion}
${RVersion}
${wkhtmltopdfVersion}
${picardVersion}
${htseqVersion}
${pythonVersion}
${gatkVersion}
${multiqcVersion}
${ghostscriptVersion}

1. Dobin A, Davis C a, Schlesinger F, Drenkow J, Zaleski C, Jha S, Batut P, Chaisson M,
Gingeras TR: STAR: ultrafast universal RNA-seq aligner. Bioinformatics 2013, 29:15–21.
2. Li H, Handsaker B, Wysoker A, Fennell T, Ruan J, Homer N, Marth G, Abecasis G, Durbin R,
Subgroup 1000 Genome Project Data Processing: The Sequence Alignment/Map format and SAMtools.
Bioinforma 2009, 25 (16):2078–2079.
3. Anders S, Pyl PT, Huber W: HTSeq – A Python framework to work with high-throughput sequencing data
HTSeq – A Python framework to work with high-throughput sequencing data. 2014:0–5.
4. Andrews, S. (2010). FastQC a Quality Control Tool for High Throughput Sequence Data [Online].
Available online at: http://www.bioinformatics.babraham.ac.uk/projects/fastqc/ ${samtoolsVersion}
5. Picard Sourceforge Web site. http://picard.sourceforge.net/ ${picardVersion}

</pre>
</p>
</div>
</div>

<div>
<!--begin.rcode, engine='python', echo=FALSE, comment=NA, warning=FALSE, message=FALSE, results='asis'
# print out tables with QC stats based on the qcMetricsList

import csv

with open("${qcMatricsList}") as f:
    files = f.read().splitlines()

titles = []
arrayValues = []
isFirst = 'true'

for file in files:
    
    with open(file,'r') as f:
        reader = csv.reader(f, delimiter='\t')

        values = []

        for row in reader:
            if(len(row) > 1):
                if(isFirst == 'true'):
                    titles.append(row[0])
                values.append(row[1])

        arrayValues.append(values)
        isFirst = 'false'

filesNumber = len(arrayValues)
index = len(titles)

arrayResults = []

tableNumbers = int(len(arrayValues) /3)

count = 0

for j in range(0, filesNumber):
    if(count == 0):
        results = []
        for i in range(0, index):
            results.append('')
    for i in range(0, index):
        results[i] += arrayValues[j][i].ljust(30)
    count += 1
    if(count == 3):
        count = 0
        arrayResults.append(results)
    elif(j == filesNumber - 1):
        arrayResults.append(results)

arraySize = len(arrayResults)

print('<h1>Project analysis results</h1>')

for j in range (0, arraySize):
    print('<div class="page"><h2 style="text-align:center">Table ' + str(j+1) +': Overview statistics</h2></br><pre>')
    ress = arrayResults[j]
    for i in range(0, index):
        print(titles[i].ljust(60) + ress[i].ljust(30))
    print('</pre></div>') 

end.rcode-->
</div>

<div class="page">
<p>
<h1>Distribution of GC percentage</h1>
<br>
The following figures show the GC distribution per sample.
<br>
<br>
<!--begin.rcode, engine='bash', echo=FALSE, comment=NA, warning=FALSE, message=FALSE, results='asis'
#prints a table with GC percentage plots, 3 per row.

LIST=($(printf '%s\n' "${externalSampleID[@]}" | sort -u))

ROWS=${#LIST[@]}
COLS=3
COUNT=0

echo "<table>"
for ((RI=0; RI<=$ROWS-1; RI++))
do
  echo "<tr>"
  for ((CI=0; CI<=$COLS-1; CI++))
  do
    
    if [[ "$COUNT" -eq ${#LIST[@]} ]]
    then
    	ROWS=${#LIST[@]}
    	break
    else
    	echo "<td><img src="images/${LIST[$COUNT]}.GC.png" alt="images/${LIST[$COUNT]}.GC.png" width="600" height="600"></td>"
    	COUNT=$COUNT+1
    fi
  done
  echo "</tr>"
done
echo "</table>"

end.rcode-->
</div>
<div class="page">
<p>
<h1>Normalized position vs. coverage</h1>
<br>
The following figures show the a plot of normalized position vs. coverage. 
<br>
<!--begin.rcode, engine='bash', echo=FALSE, comment=NA, warning=FALSE, message=FALSE, results='asis'
#prints a table with coverage plots, 3 per row.


LIST=($(printf '%s\n' "${externalSampleID[@]}" | sort -u))

ROWS=${#LIST[@]}
COLS=3
COUNT=0

echo "<table>"
for ((RI=0; RI<=$ROWS-1; RI++))
do
  echo "<tr>"
  for ((CI=0; CI<=$COLS-1; CI++))
  do

    if [[ "$COUNT" -eq ${#LIST[@]} ]]
    then
        ROWS=${#LIST[@]}
        break
    else
        echo "<td><img src="images/${LIST[$COUNT]}.collectrnaseqmetrics.png" alt="images/${LIST[$COUNT]}.collectrnaseqmetrics.png" width="700" height="700"></td>"
        COUNT=$COUNT+1
    fi
  done
  echo "</tr>"
done
echo "</table>"

end.rcode-->
</div>

<!--begin.rcode, engine='bash', echo=FALSE, comment=NA, warning=FALSE, message=FALSE, results='asis'
#when seqType is PE,prints a table with insertsize plots, 3 per row.

if [ ${seqType} == "PE" ]
then

  echo "<div class="page">"
  echo "<p>"
  echo "<h1>Insert size distribution</h1>"
  echo "<br>"
  echo "The following figures show the insert size distribution per sample. Insert refers to the base pairs that are ligated between the adapters."
  echo "<br>"


  LIST=($(printf '%s\n' "${externalSampleID[@]}" | sort -u))

  ROWS=${#LIST[@]}
  COLS=3
  COUNT=0

  echo "<table>"
  for ((RI=0; RI<=$ROWS-1; RI++))
  do
  echo "<tr>"
  for ((CI=0; CI<=$COLS-1; CI++))
  do

      if [[ "$COUNT" -eq ${#LIST[@]} ]]
      then
          ROWS=${#LIST[@]}
          break
      else
          echo "<td><img src="images/${LIST[$COUNT]}.insert_size_histogram.png" alt="images/${LIST[$COUNT]}.insert_size_histogram.png" width="700" height="700"></td>"
          COUNT=$COUNT+1
      fi
    done
    echo "</tr>"
  done
  echo "</table>"
  echo "</div>"

fi

end.rcode-->

</div>
</font>
</html>
_EOF

module load ${RVersion}
module load ${wkhtmltopdfVersion}
module list

echo "generate QC report."
# generate HTML page using KnitR
R -e 'library(knitr);knit("${intermediateDir}/${project}_QCReport.rhtml","${projectQcDir}/${project}_QCReport.html")'

#remove border
sed -i 's/border:solid 1px #F7F7F7/border:solid 0px #F7F7F7/g' ${projectQcDir}/${project}_QCReport.html

# Copy images to imagefolder
mkdir -p ${projectQcDir}/images
cp ${intermediateDir}/*.collectrnaseqmetrics.png ${projectQcDir}/images
cp ${intermediateDir}/*.GC.png ${projectQcDir}/images

#only available with PE

if [ "${seqType}" == "PE" ]
then
	cp ${intermediateDir}/*.insert_size_histogram.png ${projectQcDir}/images
fi

#convert to pdf

wkhtmltopdf-amd64 --page-size A0 ${projectQcDir}/${project}_QCReport.html ${projectQcDir}/${project}_QCReport.pdf

# generate multiqc QC rapport

module load ${multiqcVersion}

multiqc -f --comment "<b>Gene expression quantification</b> <br>The trimmed fastQ files where aligned to build ${indexFileID} ensembleRelease ${ensembleReleaseVersion} reference genome using <br>${hisatVersion} [1] allowing for 2 mismatches. Before gene quantification <br>${samtoolsVersion} [2] was used to sort the aligned reads. <br>The gene level quantification was performed by ${htseqVersion} [3] using --mode=union <br>--stranded=no and, Ensembl version ${ensembleReleaseVersion} was used as gene annotation database which is included <br> in folder expression/.<br><br><b>Calculate QC metrics on raw and aligned data</b> <br>Quality control (QC) metrics are calculated for the raw sequencing data. This is done using<br>the tool FastQC ${fastqcVersion} [4]. QC metrics are calculated for the aligned reads using<br>Picard-tools ${picardVersion} [5] CollectRnaSeqMetrics, MarkDuplicates, CollectInsertSize-<br>Metrics and ${samtoolsVersion} flagstat.These QC metrics form the basis in this  final QC report.<br><br><br><b>Used toolversions:</b><br>${jdkVersion} <br>${fastqcVersion} <br>${hisatVersion} <br>${samtoolsVersion} <br>${RVersion} <br>${wkhtmltopdfVersion} <br>${picardVersion} <br>${htseqVersion} <br>${pythonVersion} <br>${gatkVersion} <br>${multiqcVersion} <br>${ghostscriptVersion} <br>" ${intermediateDir} -o ${projectResultsDir}



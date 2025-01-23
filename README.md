# rnamap.sh
This script is for mapping and counting RNA-seq reads to genome data.  
RNA-seqのリードをゲノム情報にマッピングし、カウントするためのスクリプトです。

# Download
```bash:
git clone https://github.com/KodaiGibu/rnamap.git
```

# Environment Construction
```bash:
conda create -n rnamap -y
conda activate rnamap

mamba install -c bioconda trimmomatic==0.39 -y
mamba install -c bioconda fastqc==0.12.1 -y
mamba install -c bioconda star==2.7.11b -y
mamba install -c bioconda seqfu==1.22.3 -y
mamba install -c bioconda rsem==1.3.3 -y
```
# Config
Please edit the config part of the script, and enter the paths of the necessary files and directories.
- The directory where rawdata is stored.
- Information on the adapter sequence in Read1.
- Information on the adapter sequence in Read2.
- Fasta file of the reference genome sequence.
- Reference gtf file.
- Directory where the output file is output.

```bash:
#Config
raw_data="/path/to/rawdata" 
primer_1="AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA" 
primer_2="AAGTCGGATCGTAGCCATGTCGTTCTGTGAGCCAAGGAGTTG"
ref="/path/to/genome.fna"
gtf="/path/to/genomic.gtf"
output="/path/to/output_dir"
```

# Usege
```bash:
chmod +x rnamap.sh #add permisson
bash rnamap.sh #run
```



# rnamap
This script is for mapping and counting RNA-seq reads to genome data.  
RNA-seqのリードをゲノム情報にマッピングし、カウントするためのスクリプトです。

# Environment Construction
```bash:
conda create -n rnaseq_mapping -y
conda activate rnaseq_mapping

mamba install -c bioconda trimmomatic==0.39 -y
mamba install -c bioconda fastqc==0.12.1 -y
mamba install -c bioconda star==2.7.11b -y
mamba install -c bioconda seqfu==1.22.3 -y
mamba install -c bioconda rsem==1.3.3 -y
```

# Usege
```bash:
rnamap.sh -d /path/to/rawdata -r /path/to/genome.fna -g /path/to/genomic.gtf -1 AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA -2 AAGTCGGATCGTAGCCATGTCGTTCTGTGAGCCAAGGAGTTG -o /path/to/output_dir
```

# Option
`-d`　rawdataのあるディレクトリ  
`-r`　リファレンスとなるゲノム配列のfastaファイル  
`-g`　リファレンスとなるgtfファイル  
`-1`　除去するアダプター配列情報 #1  
`-2`　除去するアダプター配列情報 #2  
`-o`　アウトプットを出力するディレクトリ



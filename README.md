# rnamap
This script is for mapping and counting RNA-seq reads to genome data.
RNA-seqのリードをゲノム情報にマッピングし、カウントするためのスクリプトです。

# Usege
```bash:
rnamap.sh -d /path/to/rawdata -r /path/to/genome.fna -g /path/to/genomic.gtf -1 AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA -2 AAGTCGGATCGTAGCCATGTCGTTCTGTGAGCCAAGGAGTTG -o /path/to/output_dir
```

# Option
`-d` rawdataのあるディレクトリ  
`-r`　リファレンスとなるゲノム配列のfastaファイル  
`-g`　リファレンスとなるgtfファイル  
`-1`　除去するアダプター配列情報 #1  
`-2`　除去するアダプター配列情報 #2  
`-o`　アウトプットを出力するディレクトリ

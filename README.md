# svnhl-pipe
Structural Variant Calling Pipeline for Canine Non-Hodgkin Lymphoma 

Structural variant calling with svnhl-pipe requires paired-end reads.  Input can either be the aligned reads, or the raw FASTQ files.  After pre-processing, the reads are piped into three separate but complementary structural variant callers: [DELLY](https://github.com/dellytools/delly), [Breakdancer](https://github.com/genome/breakdancer), and [CNVnator](https://github.com/abyzovlab/CNVnator).  Each caller processes the data and produces a file in Variant Call Format (VCF).  The three VCF files will then be merged, and high-confidence variants (those called by multiple tools) will be marked for further analysis. 

Variant calls will eventually be assembled and mapped back to the reference. See https://github.com/jblam251/svnhl-pipe/blob/master/pipe-05242019.png for a schematic of the svnhl-pipe workflow.



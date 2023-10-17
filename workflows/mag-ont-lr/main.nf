include { ANTISMASH                         } from '../../modules/antismash'
include { BRACKEN                           } from '../../modules/bracken'
include { CHECKM                            } from '../../modules/checkm'
include { DASTOOL                           } from '../../modules/dastool'
include { DASTOOL_CONTIG2BIN as METABAT_C2B } from '../../modules/dastool_contig2bin'
include { DASTOOL_CONTIG2BIN as MAXBIN_C2B  } from '../../modules/dastool_contig2bin'
include { FLYE                              } from '../../modules/flye'
include { GTDBTK                            } from '../../modules/gtdbtk'
include { KRAKEN                            } from '../../modules/kraken'
include { KRAKENTOOLS                       } from '../../modules/krakentools'
include { KRONA                             } from '../../modules/krona'
include { MAXBIN                            } from '../../modules/maxbin'
include { MAXBIN_ADJUST_EXT                 } from '../../modules/maxbin_adjust_ext'
include { MEDAKA                            } from '../../modules/medaka'
include { METABAT                           } from '../../modules/metabat'
include { MINIMAP                           } from '../../modules/minimap'
include { PRODIGAL                          } from '../../modules/prodigal'
include { SAMTOOLS                          } from '../../modules/samtools'
include { SEQKIT                            } from '../../modules/seqkit'


workflow MAG_ONT_LR {

    reads = Channel.fromPath(params.reads)
    if (params.onlyKraken) {
        KRAKEN(reads, params.krakenDB)
        BRACKEN(KRAKEN.out, params.krakenDB)
        KRAKENTOOLS(BRACKEN.out.brackenOutputForKrona)
        KRONA(KRAKENTOOLS.out)
    }
    if (params.skipKraken) {
        FLYE(reads)
        MEDAKA(reads, FLYE.out)
        PRODIGAL(MEDAKA.out)
        ANTISMASH(MEDAKA.out)
        MINIMAP(reads, MEDAKA.out)
        SAMTOOLS(MINIMAP.out)
        METABAT(MEDAKA.out, SAMTOOLS.out)
        MAXBIN(MEDAKA.out, METABAT.out.metabatDepth)
        MAXBIN_ADJUST_EXT(MAXBIN.out.maxbinBins)
        METABAT_C2B(METABAT.out.metabatBins, "metabat")
        MAXBIN_C2B(MAXBIN_ADJUST_EXT.out.renamed_maxbinBins, "maxbin")
        
        contig2bin_ch = METABAT_C2B.out.contigs2bins.
            mix(MAXBIN_C2B.out.contigs2bins).
            collect()
        bins_ch = METABAT.out.metabatBins.
            mix(MAXBIN_ADJUST_EXT.out.renamed_maxbinBins).
            collect()

        DASTOOL(bins_ch, contig2bin_ch)
        SEQKIT(DASTOOL.out.dasBins)
        CHECKM(DASTOOL.out.dasBins)
        GTDBTK(DASTOOL.out.dasBins, params.gtdbtkDB)

    } else {
        KRAKEN(reads, params.krakenDB)
        BRACKEN(KRAKEN.out, params.krakenDB)
        KRAKENTOOLS(BRACKEN.out.brackenOutputForKrona)
        KRONA(KRAKENTOOLS.out)
        FLYE(reads)
        MEDAKA(reads, FLYE.out)
        PRODIGAL(MEDAKA.out)
        ANTISMASH(MEDAKA.out)
        MINIMAP(reads, MEDAKA.out)
        SAMTOOLS(MINIMAP.out)
        METABAT(MEDAKA.out, SAMTOOLS.out)
        MAXBIN(MEDAKA.out, METABAT.out.metabatDepth)
        MAXBIN_ADJUST_EXT(MAXBIN.out.maxbinBins)
        METABAT_C2B(METABAT.out.metabatBins, "metabat")
        MAXBIN_C2B(MAXBIN_ADJUST_EXT.out.renamed_maxbinBins, "maxbin")
        
        contig2bin_ch = METABAT_C2B.out.contigs2bins.
            mix(MAXBIN_C2B.out.contigs2bins).
            collect()
        bins_ch = METABAT.out.metabatBins.
            mix(MAXBIN_ADJUST_EXT.out.renamed_maxbinBins).
            collect()

        DASTOOL(bins_ch, contig2bin_ch)
        SEQKIT(DASTOOL.out.dasBins)
        CHECKM(DASTOOL.out.dasBins)
        GTDBTK(DASTOOL.out.dasBins, params.gtdbtkDB)
    }
}

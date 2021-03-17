SHGSOC_project_root = '/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/Zhao_pipeline/input'

def get_shgsoc_snv_targets(wildcards):
    return glob_to_df(
        '/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/Zhao_pipeline/input/*/*.somatic_snvs.vcf',
        '/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/Zhao_pipeline/input/(.*?)/(.*?).somatic_snvs.vcf',
        ['patient', 'samples']
    )

def get_shgsoc_indel_targets(wildcards):
    return glob_to_df(
        '/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/Zhao_pipeline/input/*/*.somatic_indels.vcf',
        '/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/Zhao_pipeline/input/(.*?)/(.*?).somatic_indels.vcf',
        ['patient', 'samples']
    )

def get_shgsoc_segment_targets(wildcards):
    return glob_to_df(
        '/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/Zhao_pipeline/input/*/*.segments.tsv',
        '/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/Zhao_pipeline/input/(.*?)/(.*?).segments.tsv',
        ['patient', 'samples']
    )

def get_shgsoc_sv_targets(wildcards):
    return glob_to_df(
        '/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/Zhao_pipeline/input/*/*.somatic_sv.tsv',
        '/exports/igmm/eddie/HGS-OvarianCancerA-SGP-WGS/signatures/HRDetect/Zhao_pipeline/input/(.*?)/(.*?).somatic_sv.tsv',
        ['patient', 'samples']
    )

target_functions['SHGSOC'] = {
    'all': {
        'snv_signatures': get_shgsoc_snv_targets,
        'sv_signatures': get_shgsoc_sv_targets,
        'hrd_scores': get_shgsoc_segment_targets,
        'microhomology_scores': get_shgsoc_indel_targets,
    }
}

rule shgsoc_snvs:
    input:
        ancient(SHGSOC_project_root + '/{patient}/{sample}.somatic_snvs.vcf')
    output:
        snv='data/SHGSOC/all/patients/{patient}/{sample}/somatic_snvs.vcf',
    log:
        'logs/data/SHGSOC/all/patients/{patient}/{sample}/somatic_snvs.log',
    shell:
        'Rscript ' + PROJECT_DIR + '/scripts/projects/SHGSOC/vcf_to_snv_indel.R -v {input} -i {output.snv}'

rule shgsoc_indels:
    input:
        ancient(SHGSOC_project_root + '/{patient}/{sample}.somatic_indels.vcf')
    output:
        indel='data/SHGSOC/all/patients/{patient}/{sample}/somatic_indels.vcf',
    log:
        'logs/data/SHGSOC/all/patients/{patient}/{sample}/somatic_indels.log',
    shell:
        'Rscript ' + PROJECT_DIR + '/scripts/projects/SHGSOC/vcf_to_snv_indel.R -v {input} -i {output.indel}'

rule shgsoc_segments:
    input:
        ancient(SHGSOC_project_root + '/{patient}/{sample}.segments.tsv')
    output:
        'data/SHGSOC/all/patients/{patient}/{sample}/segments.tsv'
    log:
        'logs/data/SHGSOC/all/patients/{patient}/{sample}/segments.log'
    shell:
        'Rscript ' + PROJECT_DIR + '/scripts/projects/SHGSOC/format_segments.R -i {input} -o {output}'

rule shgsoc_sv:
    input:
        ancient(SHGSOC_project_root + '/{patient}/{sample}.somatic_sv.tsv')
    output:
        'data/SHGSOC/all/patients/{patient}/{sample}/somatic_sv.tsv'
    log:
        'logs/data/SHGSOC/all/patients/{patient}/{sample}/somatic_sv.log'
    shell:
        'Rscript ' + PROJECT_DIR + '/scripts/projects/SHGSOC/format_sv.R -i {input} -o {output}'


# =============================================================================
# create_archive.cmake
# Create a Zstd-compressed archive from a single file.
# =============================================================================
#
# Expected variables:
#   INPUT_FILE    – Path to the file to compress
#   OUTPUT_FILE   – Path to the compressed output file
#   DO_COMPRESS   – ON/OFF flag to enable compression

if(DO_COMPRESS)
    message(STATUS "Compress ${INPUT_FILE} ...")
    file(ARCHIVE_CREATE
        OUTPUT            "${OUTPUT_FILE}"
        PATHS             "${INPUT_FILE}"
        FORMAT            raw
        COMPRESSION       Zstd
        # Zstd accepts 0-19 since CMake 3.26; other formats cap at 9, which is
        # why this stays at 9 rather than the Zstd maximum.
        COMPRESSION_LEVEL 9
    )
endif()

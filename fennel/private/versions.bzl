"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
FENNEL_VERSIONS = {
    "1.2.1": "4ab3f10816777b73daa2cf7f0855a86e31315fdf2adc21c894f208c27f0150cf",
}

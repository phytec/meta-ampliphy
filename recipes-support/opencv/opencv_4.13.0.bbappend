# NOTE: Backport of upstream meta-openembedded commit fdfca71954f5 ("opencv:
# rewrite build-tree paths in all CPU-dispatch stub files" to opencv_4.13.0.bb
do_install:append() {
    find ${B}/modules -name "*.cpp" | xargs -r grep -l "${S}" | while read -r fn; do
        sed -i -e 's,${S},/usr/src/debug/${PN}/${PV},g' "$fn"
    done
}

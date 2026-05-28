inherit deploy

do_deploy() {
    tar -czf ${DEPLOYDIR}/${PN}.tar.gz -C ${D} . --owner=0 --group=0
}
addtask deploy after do_install before do_build

do_image_complete() {
    # Provide a dummy do_image_complete function, so the bundle.bbclass can
    # automatically add a dependency on the recipe using this bbclass
    :
}
addtask image_complete after do_deploy

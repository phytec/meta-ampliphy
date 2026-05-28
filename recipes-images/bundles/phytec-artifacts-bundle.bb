require phytec-base-bundle.inc

RAUC_BUNDLE_SLOTS = "artifacts/example"

RAUC_SLOT_artifacts/example ?= "rauc-artifact-example"
RAUC_SLOT_artifacts/example[file] ?= "rauc-artifact-example.tar.gz"

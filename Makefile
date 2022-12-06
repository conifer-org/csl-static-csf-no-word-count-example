SHELL=/bin/bash

CURDIR=$(shell pwd)

RELEASE_TYPE?=release
CARGO_BUILD_FLAGS?=

WASM32_TARGET_DIR:=target/wasm32-unknown-unknown/${RELEASE_TYPE}/
WASI_TARGET_DIR:=target/wasm32-wasi/${RELEASE_TYPE}/
LOCAL_TARGET_DIR:=target/${RELEASE_TYPE}/
WORD_COUNT_ROOT:=$(CURDIR)/
WORD_COUNT_WASM:=$(WORD_COUNT_ROOT)/${WASM32_TARGET_DIR}/word_count.wasm

ifeq ($(RELEASE_TYPE),release)
	override CARGO_BUILD_FLAGS += --release
endif

# The reason as to why `$(WORD_COUNT_WASM)` phony targets are being used is: we need to force recompile stuff each time
# This will slow down compilation, but it's a necessary evil :(, we compile the same target again and again with different features
# A solution will be found soon
# using the rust feature of conditional compilation, requiring multiple compilations.
# THOUGH, it can be solved using workspaces???
.PHONY: run build bond $(WORD_COUNT_WASM) $(WORD_COUNT_WASI) \
test_install_word_count \
publish_conpkg_word_count_local \
publish_conpkg_word_count_remote \
build_word_count_main \
build_word_count_map \
build_word_count_reduce


$(WORD_COUNT_WASM): $(WORD_COUNT_ROOT)/src/* $(WORD_COUNT_ROOT)/.cargo/ \
		$(WORD_COUNT_ROOT)/Cargo.toml $(WORD_COUNT_ROOT)/build.rs
	# nothing to be done

build: $(WORD_COUNT_WASM)
	@echo "Building word_count :: (${CARGO_BUILD_FLAGS})"
	cargo build ${CARGO_BUILD_FLAGS}
	@echo "Building done"


### more specific commands

build_word_count_main: $(WORD_COUNT_WASM)
	@echo "Building word_count_main (${RELEASE_TYPE})"
	cargo build ${CARGO_BUILD_FLAGS} --lib --no-default-features --features word_count_main
	@echo "Building done"

build_word_count_map: $(WORD_COUNT_WASM)
	@echo "Building word_count_map (${RELEASE_TYPE})"
	cargo build ${CARGO_BUILD_FLAGS} --lib --no-default-features --features word_count_map
	@echo "Building done"

build_word_count_reduce: $(WORD_COUNT_WASM)
	@echo "Building word_count_reduce (${RELEASE_TYPE})"
	cargo build ${CARGO_BUILD_FLAGS} --lib --no-default-features --features word_count_reduce
	@echo "Building done"


### Bond stuff

TEST_ARTIFACTS_INSTALL_DIR:=$(CURDIR)/../artifacts/
CPR_PUBLISH_DIR?=$(CURDIR)/../../conifer-runtime/conifer-package-registry/artifacts/

$(TEST_ARTIFACTS_INSTALL_DIR):
	@mkdir -p $@

$(CPR_PUBLISH_DIR):
	@mkdir -p $@


## _word_count

# installs locally
test_install_word_count: $(TEST_ARTIFACTS_INSTALL_DIR)
	bond install --app-config ${CURDIR}/conpkg_config_files/word_count.ron \
 	--install-dir ${TEST_ARTIFACTS_INSTALL_DIR}


# copies directly into CPR (locally)
publish_conpkg_word_count_local: test_install_word_count $(CPR_PUBLISH_DIR)
	bond publish local --conpkg ${TEST_ARTIFACTS_INSTALL_DIR}/word-count.conpkg \
	--publish-dir ${CPR_PUBLISH_DIR}

# publishes to a remote CPR (from local test directory)
publish_conpkg_word_count_remote: test_install_word_count
	bond publish remote --conpkg ${TEST_ARTIFACTS_INSTALL_DIR}/word-count.conpkg

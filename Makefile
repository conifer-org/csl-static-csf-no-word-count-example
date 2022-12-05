SHELL=/bin/bash

CURDIR=$(shell pwd)

RELEASE_TYPE?=release
CARGO_BUILD_FLAGS?=--no-default-features --features multi_app_thread

WASM32_TARGET_DIR:=target/wasm32-unknown-unknown/${RELEASE_TYPE}/
WASI_TARGET_DIR:=target/wasm32-wasi/${RELEASE_TYPE}/
LOCAL_TARGET_DIR:=target/${RELEASE_TYPE}/
RANDOM_EXAMPLES_ROOT:=$(CURDIR)/
RANDOM_EXAMPLES_WASM:=$(RANDOM_EXAMPLES_ROOT)/${WASM32_TARGET_DIR}/random_examples.wasm
RANDOM_EXAMPLES_WASI:=$(RANDOM_EXAMPLES_ROOT)/${WASI_TARGET_DIR}/random_examples.wasm

ifeq ($(RELEASE_TYPE),release)
	override CARGO_BUILD_FLAGS += --release
endif

# The reason as to why `$(RANDOM_EXAMPLES_WASM)` phony targets are being used is: we need to force recompile stuff each time
# This will slow down compilation, but it's a necessary evil :(, we compile the same target again and again with different features
# A solution will be found soon
# using the rust feature of conditional compilation, requiring multiple compilations.
# THOUGH, it can be solved using workspaces???
.PHONY: run build bond $(RANDOM_EXAMPLES_WASM) build_wasi $(RANDOM_EXAMPLES_WASI) \
test_install_multi_app_thread \
publish_conpkg_multi_app_thread_local \
publish_conpkg_multi_app_thread_remote \
test_install_decorate_string \
publish_conpkg_decorate_string_local \
publish_conpkg_decorate_string_remote \
build_decorate_string_atom1 \
build_decorate_string_atom2 \
build_multi_app_thread \
expand_macro

$(RANDOM_EXAMPLES_WASM): $(RANDOM_EXAMPLES_ROOT)/src/* $(RANDOM_EXAMPLES_ROOT)/.cargo/ \
		$(RANDOM_EXAMPLES_ROOT)/Cargo.toml $(RANDOM_EXAMPLES_ROOT)/build.rs
	# nothing to be done

build: $(RANDOM_EXAMPLES_WASM)
	@echo "Building random_examples :: (${CARGO_BUILD_FLAGS})"
	cargo build ${CARGO_BUILD_FLAGS}
	@echo "Building done"

$(RANDOM_EXAMPLES_WASI): $(RANDOM_EXAMPLES_ROOT)/src/* $(RANDOM_EXAMPLES_ROOT)/.cargo/ \
		$(RANDOM_EXAMPLES_ROOT)/Cargo.toml $(RANDOM_EXAMPLES_ROOT)/build.rs
	@echo "Building random_examples (${RELEASE_TYPE})"
	cargo build ${CARGO_BUILD_FLAGS} --bins --target wasm32-wasi
	@echo "Building done"

build_wasi: $(RANDOM_EXAMPLES_WASI)


### more specific commands

build_decorate_string_atom1: $(RANDOM_EXAMPLES_WASM)
	@echo "Building decorate_string_atom1 (${RELEASE_TYPE})"
	cargo build ${CARGO_BUILD_FLAGS} --lib --no-default-features --features decorate_string_atom1
	@echo "Building done"

build_decorate_string_atom2: $(RANDOM_EXAMPLES_WASM)
	@echo "Building decorate_string_atom2 (${RELEASE_TYPE})"
	cargo build ${CARGO_BUILD_FLAGS} --lib --no-default-features --features decorate_string_atom2
	@echo "Building done"

build_multi_app_thread: $(RANDOM_EXAMPLES_WASM)
	@echo "Building multi_app_thread (${RELEASE_TYPE})"
	cargo build ${CARGO_BUILD_FLAGS} --lib --no-default-features --features multi_app_thread
	@echo "Building done"

expand_macro: $(RANDOM_EXAMPLES_WASM)
	cargo expand --lib

### Bond stuff

TEST_ARTIFACTS_INSTALL_DIR:=$(CURDIR)/../artifacts/
CPR_PUBLISH_DIR?=$(CURDIR)/../../conifer-runtime/conifer-package-registry/artifacts/

$(TEST_ARTIFACTS_INSTALL_DIR):
	@mkdir -p $@

$(CPR_PUBLISH_DIR):
	@mkdir -p $@

## _multi_app_thread

# installs locally
test_install_multi_app_thread: $(TEST_ARTIFACTS_INSTALL_DIR)
	bond install --app-config ${CURDIR}/conpkg_config_files/multi_app_thread.ron \
 	--install-dir ${TEST_ARTIFACTS_INSTALL_DIR}


# Installs directly in CPR (locally)
publish_conpkg_multi_app_thread_local: test_install_multi_app_thread $(CPR_PUBLISH_DIR)
	bond publish local --conpkg ${TEST_ARTIFACTS_INSTALL_DIR}/random-examples-multi-app-thread.conpkg \
	--publish-dir ${CPR_PUBLISH_DIR}

# publishes to a remote CPR (from local test directory)
publish_conpkg_multi_app_thread_remote: test_install_multi_app_thread
	bond publish remote --conpkg ${TEST_ARTIFACTS_INSTALL_DIR}/random-examples-multi-app-thread.conpkg


## _decorate_string

# installs locally
test_install_decorate_string: $(TEST_ARTIFACTS_INSTALL_DIR)
	bond install --app-config ${CURDIR}/conpkg_config_files/decorate_string.ron \
 	--install-dir ${TEST_ARTIFACTS_INSTALL_DIR}


# copies directly into CPR (locally)
publish_conpkg_decorate_string_local: test_install_decorate_string $(CPR_PUBLISH_DIR)
	bond publish local --conpkg ${TEST_ARTIFACTS_INSTALL_DIR}/random-examples-decorate-string.conpkg \
	--publish-dir ${CPR_PUBLISH_DIR}

# publishes to a remote CPR (from local test directory)
publish_conpkg_decorate_string_remote: test_install_decorate_string
	bond publish remote --conpkg ${TEST_ARTIFACTS_INSTALL_DIR}/random-examples-decorate-string.conpkg

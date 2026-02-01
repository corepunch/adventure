APP_NAME = orca
BUILD_DIR = /Users/igor/Developer/ui-framework/build/bin
DATA_DIR = /Users/igor/Developer/zil-engine
LIB_PATH = $(BUILD_DIR)

# Targets
.PHONY: run clean test test-all test-unit test-integration test-zork1 test-parser test-containers test-directions test-light test-pronouns test-take test-horror-helpers test-horror-partial test-horror test-horror-failures test-horror-all help

help:
	@echo "Available targets:"
	@echo "  run               - Run the game in GUI mode"
	@echo "  run-text          - Run the game in text mode"
	@echo "  clean             - Clean up build artifacts"
	@echo ""
	@echo "Test targets:"
	@echo "  test              - Run all tests (unit + integration)"
	@echo "  test-all          - Alias for 'test'"
	@echo "  test-unit         - Run unit tests only"
	@echo "  test-integration  - Run all integration tests"
	@echo "  test-zork1        - Run Zork1 integration tests"
	@echo "  test-parser       - Run all parser/runtime tests"
	@echo "  test-containers   - Run container interaction tests"
	@echo "  test-directions   - Run direction/movement tests"
	@echo "  test-light        - Run light source tests"
	@echo "  test-pronouns     - Run pronoun tests"
	@echo "  test-take         - Run TAKE command tests"
	@echo "  test-horror-helpers - Run horror test helpers"
	@echo "  test-horror-partial - Run horror partial walkthrough"
	@echo "  test-horror-failures - Run horror failing conditions tests"
	@echo "  test-horror       - Run horror complete walkthrough"
	@echo "  test-horror-all   - Run all horror tests"

run:
	@echo "Setting DYLD_LIBRARY_PATH to $(LIB_PATH) and running $(APP_NAME)..."
	DYLD_LIBRARY_PATH=$(LIB_PATH) $(BUILD_DIR)/$(APP_NAME) $(DATA_DIR)

run-text:
	lua main.lua

cluster:
	@echo "Setting DYLD_LIBRARY_PATH to $(LIB_PATH) and running $(APP_NAME)..."
	DYLD_LIBRARY_PATH=$(LIB_PATH) $(BUILD_DIR)/$(APP_NAME) -lib=$(BUILD_DIR) -data=$(CLUSTER_DIR)

copy-resources:
	@echo "Copying contents of current directory to $(RESOURCES_DIR)..."
	@mkdir -p $(RESOURCES_DIR)  # Ensure the target directory exists
	@cp -r ./* $(RESOURCES_DIR)

clean:
	@echo "Cleaning up..."
	# Add cleaning commands here if needed

# Test targets
test: test-unit test-integration
	@echo "All tests completed successfully!"

test-all: test
	@echo "All tests completed successfully!"

test-unit:
	@echo "Running unit tests..."
	lua tests/unit/run_all.lua

test-integration: test-zork1 test-parser test-horror-all
	@echo "All integration tests completed!"

test-zork1:
	@echo "Running Zork1 integration tests..."
	lua tests/run_tests.lua tests/zork1_walkthrough.lua

test-parser: test-containers test-directions test-light test-pronouns test-take
	@echo "All parser/runtime tests completed!"

test-containers:
	@echo "Running container tests..."
	lua tests/run_tests.lua tests/test-containers.lua

test-directions:
	@echo "Running direction tests..."
	lua tests/run_tests.lua tests/test-directions.lua

test-light:
	@echo "Running light tests..."
	lua tests/run_tests.lua tests/test-light.lua

test-pronouns:
	@echo "Running pronoun tests..."
	lua tests/run_tests.lua tests/test-pronouns.lua

test-take:
	@echo "Running take command tests..."
	lua tests/run_tests.lua tests/test-take.lua

test-horror-helpers:
	@echo "Running horror test helpers..."
	lua tests/run_tests.lua tests/horror-test-helpers.lua

test-horror-partial:
	@echo "Running horror partial walkthrough tests..."
	lua tests/run_tests.lua tests/horror-partial.lua

test-horror:
	@echo "Running horror complete walkthrough tests..."
	lua tests/run_tests.lua tests/horror-walkthrough.lua

test-horror-failures:
	@echo "Running horror failing conditions tests..."
	lua tests/run_tests.lua tests/horror-failures.lua

test-horror-all: test-horror-helpers test-horror-partial test-horror-failures test-horror
	@echo "All horror tests completed!"

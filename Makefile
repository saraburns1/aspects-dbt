format:
	sqlfmt models macros

coverage:
	dbt-coverage compute doc --cov-fail-under 1.0

unit-tests:
	mv unit-test-seeds ci-seeds
	dbt seed --full-refresh --exclude event_sink
	dbt run --full-refresh --selector all_tests
	dbt test --selector all_tests
	mv ci-seeds unit-test-seeds

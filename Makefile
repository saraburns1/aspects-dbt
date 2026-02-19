format:
	sqlfmt models macros

coverage:
	dbt-coverage compute doc --cov-fail-under 1.0

unit-test:
	@read -p "This will REPLACE all event_sink and xapi tables with seed data. Are you sure you want to continue? [y/N] " -n 1 -r; echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		mv unit-test-seeds ci-seeds; \
		dbt seed --full-refresh --selector all_tests; \
		dbt run --full-refresh --selector all_tests; \
		dbt test --selector all_tests; \
		mv ci-seeds unit-test-seeds; \
	else \
		echo "Aborting unit tests."; \
	fi

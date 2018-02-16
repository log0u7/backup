.PHONY: backup-dir mirror-s3 rotate delete check-ready check-live

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Required parameter is missing: $1$(if $2, ($2))))

days ?= 7
zip ?= ""
exclude ?= ""
mark = ""
nice ?= 10
ionice ?= 7

default: backup-dir

backup-dir:
	$(call check_defined, dir, filepath)
	backup-dir.sh $(dir) $(filepath) $(zip) "$(exclude)" "$(mark)" $(nice) $(ionice)

mirror-s3:
	$(call check_defined, key_id, access_key, bucket, region, filepath)
	AWS_ACCESS_KEY_ID=$(key_id) AWS_SECRET_ACCESS_KEY=$(access_key) \
		nice -n $(nice) ionice -c2 -n $(ionice) \
		aws s3 cp $(filepath) s3://$(bucket)/ --region $(region)

rotate:
	$(call check_defined, dir)
	find $(dir) -mindepth 1 -mtime +$(days) -delete

delete:
	$(call check_defined, filepath)
	rm -f $(filepath)

check-ready:
	exit 0

check-live:
	@echo "OK"

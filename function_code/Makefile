.PHONY: all
all:
	make clean
	make startstop_func
	make register_dns_record_func

.PHONY: startstop_func
startstop_func:
	cd instance-start-stop-function && \
		zip -r ../instance-start-stop-function.zip .

.PHONY: register_dns_record_func
register_dns_record_func:
	cd register-dns-record-function && \
		zip -r ../register-dns-record-function.zip .

.PHONY: clean
clean:
	rm -f instance-start-stop-function.zip
	rm -f register-dns-record-function.zip
